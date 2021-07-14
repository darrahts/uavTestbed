function cols = get_column_names(conn, table_name)
    %%
    %       @brief: get all column names of a given table as a list of
    %       strings
    %
    %       @params: 
    %           conn - the database connection object
    %           table_name - the table to get the columns of
    %
    %       @returns: a list of column names as strings
    %
    %       @constraints: 
    %           exists(table_name)
    %%
    cols = table2array(select(conn, sprintf("select array(select ''''||column_name||'''' column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = '%s')", table_name)));
    cols = [string(cols{1}).replace('{', '').replace('}', '').replace('''', '').split(',')]';
    %cols = cellstr(cols);
end

