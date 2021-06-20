function uav = load_uav(conn, serial_number)
    %%
    %       @brief: Loads a complete UAV model by serial number
    %
    %       @params: 
    %           conn - the database connection object
    %           serial_number - the unique identifier of the asset
    %
    %       @returns: a UAV struct containing the airframe, battery, and
    %       motors
    %
    %       @constraints: 
    %           exists(serial_number)
    %
    %       @bugs:
    %           does not properly read NULL value, reads as -2147483648
    %%
    
    % load the UAV record from the db
    LOAD_UAV_BY_SERIAL = sprintf("select ast.*, ut.* from asset_tb ast inner join uav_tb ut on ast.id = ut.id where ast.serial_number like '%s';", serial_number);
    uav_tb = select(conn, LOAD_UAV_BY_SERIAL);
 
    % load the airframe associated with the UAV
    LOAD_UAV_AIRFRAME = sprintf("select af.* from default_airframe_tb af inner join uav_tb ut on ut.airframe_id = af.id where af.id = %d;", uav_tb.airframe_id);
    airframe_tb = select(conn, LOAD_UAV_AIRFRAME);
    
    % load the battery associated with the UAV
    LOAD_UAV_BATTERY = sprintf("select bt.* from eqc_battery_tb bt inner join uav_tb ut on ut.battery_id = bt.id where bt.id = %d;", uav_tb.battery_id);
    battery_tb = select(conn, LOAD_UAV_BATTERY);
    
    % the motors are a bit different, first see how many motors there are
    % either 8, 6, 4, or 3 motors are valid motor numbers.
    if uav_tb.motor8_id > 0
        num_motors = 8;
    elseif uav_tb.motor6_id > 0
        num_motors = 6;
    elseif uav_tb.motor4_id > 0
        num_motors = 4;
    else
        num_motors = 3;
    end
 
    % next the query is dynamically generated based on the number of motors
    LOAD_UAV_MOTORS = sprintf("select ast.*, mt.* from asset_tb ast inner join dc_motor_tb mt on mt.id = ast.id where mt.id = %d", uav_tb.motor1_id);
    for i=2:num_motors
         s = sprintf(" or mt.id = %d", uav_tb.(sprintf("motor%d_id", i)));
         LOAD_UAV_MOTORS = join([LOAD_UAV_MOTORS s]);
    end
    % all sql queries should end with a ;
    LOAD_UAV_MOTORS.append(";");
    motors_tb = select(conn, LOAD_UAV_MOTORS);
    
    % convert all tables to structs
    uav.uav = table2struct(uav_tb); 
    uav.airframe = table2struct(airframe_tb);
    uav.battery = table2struct(battery_tb);
    uav.motors = table2struct(motors_tb);
    
    % the Jb matrix is stored as a double array in postgres, but matlab
    % reads it as a char array / string
    uav.airframe.Jb = erase(uav.airframe.Jb, "{");
    uav.airframe.Jb = erase(uav.airframe.Jb, "}");
    uav.airframe.Jb = reshape(str2num(uav.airframe.Jb), [3,3]);
    
    % this is the relationship between state of charge and voltage
    uav.battery.soc_ocv = load('degradation/soc_ocv.mat').soc_ocv;
    
    % easier access to some variable
    uav.max_flight_time = uav.uav.max_flight_time;
    uav.id = uav.uav.id;
    
    % the current implementation assumes the entire mass value is captured in
    % the airframe (a mass field could be added to the asset class...)
    uav.mass = uav.airframe.mass;
    
    
    
end

