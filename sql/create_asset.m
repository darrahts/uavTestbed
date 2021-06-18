function asset = create_asset(conn, owner, type_id, serial_number, age, units)
    %%
    %       @brief: creates an asset
    %
    %       @params: 
    %           conn - the database connection object
    %           name - name of the asset, for user purposes 
    %           type_id - the type_id (asset_type must already exist)
    %           serial_number - must be unique among all entries
    %           age - quantity to express the age of the asset
    %           units - the unit of measurement for age
    %
    %           ex: ("tims asset", 1, x00001, 0, "cumulative amp hours"),
    %               ("lab 236 airframe", 1, x003421, 2.2, "flight hours"),
    %        
    %       @returns: the asset as a struct
    %
    %       @constraints: 
    %           unique(serial_number)
    %           exists(type_id)
    %%
    table_name = "asset_tb";
    var_names = ["owner", "type_id", "serial_number", "age", "units"];
    asset = table(owner, type_id, serial_number, age, units, 'VariableNames', var_names);
    sqlwrite(conn, table_name, asset);
    
    asset_tb = sqlread(conn, 'asset_tb');
    asset_tb = asset_tb(strcmp(asset_tb.serial_number, serial_number),:);
    asset = table2struct(asset_tb);
    
end

