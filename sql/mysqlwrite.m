function [columntypes] =  sqlwrite(conn,tablename,data,varargin)
%SQLWRITE write a MATLAB table to a database table
% sqlwrite(conn,tablename,data)
%   Writes a MATLAB table to a database table. If the table is exisitng on
%   the database, sqlwrite inserts (appends) data to the table. If the
%   table is non-existent on the database, sqlwrite creates a new
%   database table and inserts data to the table.
%
% sqlwrite(conn,tablename,data,Name,Value)
%   writes MATLAB table to a database table with additional options
%   specified by one or more name-value arguments. For example, you can
%   specify Catalog or Schema where table is stored in the database.
%
% EXAMPLE:
%
% T = table(...);
% sqlwrite(conn,'inventoryTable',T);
%   Inserts T to an already existing table 'inventoryTable' in database.
%
% T = table(...);
% sqlwrite(conn,'newtable',T);
%   Creates a new table 'newtable' in the database and inserts T in the
%   table.
%
% T = table(...);
% sqlwrite(conn,'salesvolume','Catalog','mycatalog','Schema','myschema')
%   Inserts T to an already existing table 'salesvolume' located in Catalog
%   'mycatalog' and Schema 'myschema'.

%   Copyright 2018 The MathWorks, Inc.

p = inputParser;

p.addRequired("conn",@(x)validateattributes(x,["database.odbc.connection" "database.jdbc.connection"],{'scalar'}));
p.addRequired("tablename",@(x)validateattributes(x,["string" "char"],{'scalartext'}))
p.addRequired("data",@(x)validateattributes(x,"table",{}))
p.addParameter("Catalog","",@(x)validateattributes(x,["string" "char"],{'scalartext'}));
p.addParameter("Schema","",@(x)validateattributes(x,["string" "char"],{'scalartext'}));
p.addParameter("EscapeCharacter","",@(x)validateattributes(x,["string" "char"],{'scalartext'}));
p.addParameter("ColumnType","",@(x)validateattributes(x,["string" "char" "cell"],{}));

p.parse(conn,tablename,data,varargin{:});

if ~isopen(conn)
    error(message("database:database:invalidConnection"));
end
   
escapechar = string(p.Results.EscapeCharacter);
catalog = string(p.Results.Catalog);
schema = string(p.Results.Schema);
tablename = string(p.Results.tablename);
columnnames = string(data.Properties.VariableNames);
columntypes = string(p.Results.ColumnType);

% g1781499 - Split tablename to see if there is catalog and/or schema name attached
temp_tablename = strsplit(tablename,".");
tablename = string(temp_tablename(end));
otherparts = "";
switch numel(temp_tablename)
    case 1
        % do nothing
    case 2
        if strcmpi(conn.DatabaseProductName,'mysql')
            catalog = string(temp_tablename(end-1));
        else
            schema = string(temp_tablename(end-1));
        end
    otherwise
        if strcmpi(conn.DatabaseProductName,'mysql')
            catalog = string(temp_tablename(end-1));
            otherparts = string(strjoin(temp_tablename(1:end-2)));
        else
            schema = string(temp_tablename(end-1));
            catalog = string(temp_tablename(end-2));
            otherparts = string(strjoin(temp_tablename(1:end-3)));
        end
end

tabledata = sqlfind(conn,tablename,"Catalog",catalog,"Schema",schema);

if ~isempty(tabledata.Table)
    tabledata(cellfun(@(x)~strcmpi(x,char(tablename)),tabledata.Table),:) = [];
end

if height(tabledata) > 1
    error(message('database:database:MultipleTableEntries',tablename,"Catalog","Schema"));
end

if schema.strlength ~= 0
    tablename = schema + "." + tablename;
end

if catalog.strlength ~= 0
    tablename = catalog + "." + tablename;
end

% g1781499 - This is needed if using fully qualified table-name. Generally fully
% qualified table-name has only 3 parts, but with cloud solutions one can
% add server-name as well for certain databases.
if numel(temp_tablename) > 3
    tablename = otherparts + "." + tablename;
end

if escapechar.strlength ~= 0
    for i=1:length(columnnames)
        columnnames(i) = escapechar + columnnames(i) + escapechar;
    end
end

querybuilder = database.internal.utilities.SQLQueryBuilder;
newTableCreated = false;

if height(tabledata) == 0

    if isempty(data) && all(columntypes.strlength) == 0
        error(message('database:database:EmptyTableCreation',char(tablename)));
    end
    
    if ~(all(columntypes.strlength) == 0)        
        if numel(columntypes) ~= numel(data.Properties.VariableNames)
            error(message('database:database:ColumnTypeNeeded'));
        end    
        query = querybuilder.create(tablename,columnnames,columntypes).SQLQuery;
        newTableCreated = true;
    else
        [data,columntypes] = database.internal.utilities.TypeMapper.matlabToDatabaseTypes(data,conn.DatabaseProductName);
        if ismember('timestamp', columntypes)
            idx = find(strcmp(columntypes, 'timestamp'))
            columntypes(idx) = 'timestamp(3)';
        end
        [data,columntypes,columnnames] = database.internal.utilities.TypeMapper.modifyData(data,columntypes,columnnames)
        query = querybuilder.create(tablename,columnnames,columntypes).SQLQuery;
        newTableCreated = true;
    end
    
    try
        execute(conn,query);
    catch ME
        error(message("database:database:WriteTableDriverError","JDBC",string(ME.message)));
    end
    
    if isempty(data)
        return;
    end
end

if isempty(data)
    validateattributes(data,"table",{"nonempty"});
end
    
querybuilder.SQLQuery = "";
metaStmt = conn.Constructor.prepareStatement(querybuilder.select(columnnames).from(tablename).SQLQuery);
c = onCleanup(@()close(metaStmt));

rmetadata = com.mathworks.toolbox.database.DatabaseResultsetMetaData(metaStmt);
if(~isempty(rmetadata.getErrorMessage()))
    error(message("database:database:WriteTableDriverError","JDBC",rmetadata.getErrorMessage()));
end

coltypes = rmetadata.getAllColumnTypes;

numberofrows = height(data);
numberofcols = width(data);

insertStmt = com.mathworks.toolbox.database.DatabaseStatement(conn.Handle,conn.Constructor.prepareStatement(querybuilder.preparedInsert(columnnames,tablename).SQLQuery));
c = onCleanup(@()closeStatement(insertStmt));
coltypes
transformedTable = database.internal.utilities.TypeMapper.dataTypeConverter(conn,coltypes,data);

oldState = string(conn.AutoCommit);
conn.AutoCommit = "off";

insertStmt.insert(numberofcols,numberofrows,coltypes,transformedTable);
    
if isempty(char(insertStmt.getErrorExecutingStatement))    
    % If INSERT succeeds, first COMMIT whatever was written and then
    % reset preferences if one of four databases
    if strcmpi(oldState,"on")
        try
            commit(conn);
        catch
        end
    end
    
    % Reset auto-commit to original value
    conn.AutoCommit = oldState;
    
else
    if strcmpi(oldState,"on")
        try
            rollback(conn);
        catch
        end
    end
    
    if newTableCreated
        try
            execute(conn,['DROP TABLE ' char(tablename)]);
        catch
        end
    end
    
    % Reset auto-commit to original value
    conn.AutoCommit = oldState;    
    error(message("database:database:WriteTableDriverError","JDBC",string(insertStmt.getErrorExecutingStatement)))
    
end

end

