function airframe = create_default_airframe(conn, owner, type_id, serial_number, num_motors, age, units)
    %%
    %       @brief: Creates a default airframe asset. To be replaced by
    %       <create_default_component.m> in a future update.
    %
    %       @params: 
    %           conn - the database connection object
    %           owner - the username of the object creator
    %           type_id - the id of the asset type
    %           serial_number - the unique identifier of the asset
    %           age - a unitless quantity that expresses age
    %           units - the unit of measurement for age
    %
    %       @returns: airframe model as a struct
    %
    %       @constraints: 
    %           unique(serial_number)
    %           exists(type_id)
    %%
    
    % create the asset first
    asset = create_asset(conn, owner, type_id, serial_number, age, units);

    % database table for the default airfame model
    table_name = "default_airframe_tb";
    
    % these are column names in the table, this table auto populates the
    % other parameters. To use different parameter values include the
    % parameter name in this list
    var_names = ["id", "num_motors"];
    
    % these are the values associated to the var_names (one-to-one
    % correspondence). When changing parameters, include the value in this
    % list
    vars = [asset.id, num_motors];
    
    % convert the lists to a table
    airframe = array2table(vars, 'VariableNames', var_names);
    
    % insert into the database
    sqlwrite(conn, table_name, airframe);
    
    % read back from the database what was just inserted. This is to verify
    % the operation was successful. 
    airframe_tb = sqlread(conn, 'default_airframe_tb');
    
    % only return this asset
    airframe_tb = airframe_tb(airframe_tb.id== asset.id,:);
    airframe = table2struct(airframe_tb);
end

