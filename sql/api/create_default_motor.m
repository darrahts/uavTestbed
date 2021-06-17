function dc_motor = create_default_motor(conn, owner, type_id, serial_number, age, units)
    %%
    %       @brief: Creates a default dc motor. To be replaced by
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
    %       @returns: battery model as a struct
    %
    %       @constraints: 
    %           unique(serial_number)
    %           exists(type_id)
    %%
    
    % create the asset first
    asset = create_asset(conn, owner, type_id, serial_number, age, units);

    % database table for the dc motor model
    table_name = "dc_motor_tb";
    
    % these are column names in the table, this table auto populates the
    % other parameters. To use different parameter values include the
    % parameter name in this list
    var_names = ["id"];
    
    % these are the values associated to the var_names (one-to-one
    % correspondence). When changing parameters, include the value in this
    % list
    vars = [asset.id];
    
    % convert the lists to a table
    dc_motor = array2table(vars, 'VariableNames', var_names);
    
    % insert into the database
    sqlwrite(conn, table_name, dc_motor);
    
    % read back from the database what was just inserted. This is to verify
    % the operation was successful. 
    dc_motor_tb = sqlread(conn, 'dc_motor_tb');
    
    % only return this asset
    dc_motor_tb = dc_motor_tb(dc_motor_tb.id == asset.id,:);
    dc_motor = table2struct(dc_motor_tb);
end

