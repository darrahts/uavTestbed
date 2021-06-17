function component = create_default_component(conn, owner, type, serial_number, age, units)
    %%
    %       @brief: 
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
%    asset = create_asset(conn, owner, type.id, serial_number, age, units);

    component = 1;
    
    table_name = sprintf("%s_%s_tb", type.subtype, type.type);
    
   switch table_name
        case "dc_motor_tb"
            disp('dc_motor_tb')
        case "discrete-eqc_battery_tb"
            table_name = 'eqc_battery_tb';
            disp('eqc_battery_tb')
        case "continuous-eqc_battery_tb"
            table_name = 'eqc_battery_tb';
            disp('eqc_battery_tb')
        case "default_airframe_tb"
            disp('default_airframe_tb')
        otherwise
            disp('other value')
    end
    
    
%     % database table for the dc motor model
%     table_name = "dc_motor_tb";
%     
%     % these are column names in the table, this table auto populates the
%     % other parameters. To use different parameter values include the
%     % parameter name in this list
%     var_names = ["id"];
%     
%     % these are the values associated to the var_names (one-to-one
%     % correspondence). When changing parameters, include the value in this
%     % list
%     vars = [asset.id];
%     
%     % convert the lists to a table
%     component = array2table(vars, 'VariableNames', var_names);
%     
%     % insert into the database
%     sqlwrite(conn, table_name, component);
%     
%     % read back from the database what was just inserted. This is to verify
%     % the operation was successful. 
%     dc_motor_tb = sqlread(conn, 'dc_motor_tb');
%     
%     % only return this asset
%     dc_motor_tb = dc_motor_tb(dc_motor_tb.id == asset.id,:);
%     component = table2struct(dc_motor_tb);
end

