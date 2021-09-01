function uav = create_default_uav(conn, owner, type_id, serial_number, age, units, airframe, battery, motors)
    %%
    %       @brief: creates a uav
    %
    %       @params: 
    %           conn - the database connection object
    %           owner - the username of the object creator
    %           type_id - the id of the asset type
    %           serial_number - the unique identifier of the asset
    %           age - a unitless quantity that expresses age
    %           units - the unit of measurement for age
    %           airframe - the airframe model for the uav
    %           battery - the battery model for the uav
    %           motors - the motor models for the uav
    %
    %       @constraints: 
    %           unique(serial_number)
    %           exists(type_id)      
    %%

    % create the asset first
    asset = create_asset(conn, owner, type_id, serial_number, age, units);

    % The uav asset is different than the components in that the component
    % assets are parameterized models whereas the uav is not. The UAV as it
    % is stored in the database is a record of asset ids. The UAV as it is
    % used in experiments is a struct with the component models. So get the
    % ids first
    airframe_id   = airframe.id;
    battery_id    = battery.id;
    motor_list    = fieldnames(motors);
    motor_ids     = zeros(length(motor_list), 1);

    for i = 1:numel(motor_list)
        motor_ids(i) = motors.(motor_list{i}).id;
    end
    
    % the motors can be variable in length, from 3 to 8 depending on the
    % exact configuration. Since this is dynamic, we need to generate the
    % variable names (column names) 
    num_motors = length(motor_ids);
    motor_names = string.empty;
    for i=1:num_motors
        motor_names(i) = sprintf("m%d_id", i);
    end
    
    % these are column names in the table, this table does not autopopulate
    % other parameters. To create a UAV with other components (such as
    % ESCs, a camera, lidar, etc... the UAV table needs to first be updated
    % with the additional column(s), and then that column name can be
    % included below, then concatenate the lists
    var_names = ["id", "airframe_id", "battery_id"];
    var_names = [var_names, motor_names];
    
    % these are the values associated to the var_names (one-to-one
    % correspondence). When changing parameters, include the value in this
    % list
    vars = [asset.id, airframe_id, battery_id];
    vars = [vars, motor_ids'];
    
    % database table for the dc motor model
    table_name = "uav_tb";
        
    % convert the lists to a table
    uav = array2table(vars, 'VariableNames', var_names);
    
    % insert into the database
    sqlwrite(conn, table_name, uav);
    
    % read back from the database what was just entered to validate its
    % entry 
    uav_tb = sqlread(conn, 'uav_tb');
    
    % only return this asset
    uav_tb = uav_tb(uav_tb.id == asset.id,:);
    
    % the uav asset only contains the ids of the components and a default
    % max_flight_time value of 18 (minutes). 
    uav_struct = table2struct(uav_tb);
    
    % the uav model contains the component models, so we only need to keep
    % the id field from uav_ids, and then populate the uav struct with the
    % models
    uav = struct;
    uav.id = uav_struct.id;
    uav.airframe = airframe;
    uav.battery = battery;
    uav.motors = motors;
    uav.max_flight_time = uav_struct.max_flight_time;
    
end

