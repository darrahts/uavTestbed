function eqc_battery = create_default_battery(conn, owner, type_id, serial_number, age, units)
    %%
    %       @brief: creates a battery asset
    %
    %       @params: 
    %           conn - the database connection object
    %           owner - the username of the object creator
    %           type_id - the id of the asset type
    %           serial_number - the unique identifier of the asset
    %           age - a unitless quantity that expresses age
    %           units - the unit of measurement for age
    %
    %       @constraints: 
    %           unique(serial_number)
    %           exists(type_id)
    %%
    
    % create the asset first
    asset = create_asset(conn, owner, type_id, serial_number, age, units);

    % database table for the eqc (equivalent circuit) battery model
    table_name = "eqc_battery_tb";
    
    % these are column names in the table, this table auto populates the
    % other parameters. To use different parameter values include the
    % parameter name in this list
    var_names = ["id"];
    
    % these are the values associated to the var_names (one-to-one
    % correspondence). When changing parameters, include the value in this
    % list
    vars = [asset.id];
    
    % convert the lists to a table
    eqc_battery = table(asset.id, 'VariableNames', var_names);
    
    % insert into the database
    sqlwrite(conn, table_name, eqc_battery);
    
    % read back from the database what was just inserted. This is to verify
    % the operation was successful. 
    eqc_battery_tb = sqlread(conn, 'eqc_battery_tb');
    
    % only return this asset
    eqc_battery_tb = eqc_battery_tb(eqc_battery_tb.id == asset.id,:);
    eqc_battery = table2struct(eqc_battery_tb);
end

