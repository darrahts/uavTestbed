function asset_type = create_asset_type(conn, type, subtype, description)
    %%
    %       @brief: creates an asset type
    %
    %       @params: 
    %           conn - the database connection object
    %           type - the type of asset (airframe, motor, battery, ...)
    %           subtype - the subtype of asset (octorotor, dc, eqc, ...) 
    %           description - other info
    %
    %           ex: ("airframe", "octorotor", "dji-s1000")
    %               ("motor", "bldc", "shivraj_2014")
    %               ("battery", "eqc", "plett_2015")
    %               ("battery", "chem", "daigle_2013") ....
    %
    %       @returns: asset_type as a struct
    %
    %       @constraints: unique(type, subtype, description)
    %%
    table_name = "asset_type_tb";
    var_names = ["type", "subtype", "description"];
    asset_type = table(type, subtype, description, 'VariableNames', var_names);
    sqlwrite(conn, table_name, asset_type);
    
    asset_type_tb = sqlread(conn, 'asset_type_tb');
    asset_type_tb = asset_type_tb(asset_type_tb.type == type,:);
    asset_type_tb = asset_type_tb(strcmp(asset_type_tb.subtype, subtype),:);
    asset_type_tb = asset_type_tb(strcmp(asset_type_tb.description, description),:);
    asset_type = table2struct(asset_type_tb);
end

