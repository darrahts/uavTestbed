function uav = load_uav(conn, serial_number, api)
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
    uav_tb = select(conn, eval(api.matlab.assets.LOAD_UAV_BY_SERIAL));
 
    % load the airframe associated with the UAV
    airframe_tb = select(conn, eval(api.matlab.assets.LOAD_UAV_AIRFRAME));
    
    % load the battery associated with the UAV
    battery_tb = select(conn, eval(api.matlab.assets.LOAD_UAV_BATTERY));
    
    % load the gps associated with the UAV
    gps_tb = select(conn, eval(api.matlab.assets.LOAD_UAV_GPS));
    
    % the motors are a bit different, first see how many motors there are
    % either 8, 6, 4, or 3 motors are valid motor numbers.
    if uav_tb.m8_id > 0
        num_motors = 8;
    elseif uav_tb.m6_id > 0
        num_motors = 6;
    elseif uav_tb.m4_id > 0
        num_motors = 4;
    else
        num_motors = 3;
    end
 
    % next the query is dynamically generated based on the number of motors
    LOAD_UAV_MOTORS = eval(api.matlab.assets.LOAD_UAV_MOTORS);
    for i=2:num_motors
         s = sprintf(' or mt.id = %d', uav_tb.(sprintf('m%d_id', i)));
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
    uav.gps = table2struct(gps_tb);
    
    % check if there are any new components and if so sample the the
    % initial degradation parameter values
    % battery
    if uav.battery.age == 0
       uav.battery.Q = normrnd(uav.battery.Q, .02*uav.battery.Q);
       uav.battery.R0 = normrnd(uav.battery.R0, .02*uav.battery.R0);
    end
    % motors
    for i = 1:num_motors
       if uav.motors(i).age == 0
           uav.motors(i).Req = normrnd(uav.motors(i).Req, .02*uav.motors(i).Req);
       end
    end
    
    % the Jb matrix is stored as a double array in postgres, but matlab
    % reads it as a char array / string
    uav.airframe.Jb = erase(uav.airframe.Jb, "{");
    uav.airframe.Jb = erase(uav.airframe.Jb, "}");
    uav.airframe.Jb = reshape(str2num(uav.airframe.Jb), [3,3]);
    
    if contains(uav.uav.common_name, 'tarot')
    % this is the relationship between state of charge and voltage
    % here for backwards compatability, to be removed in the future
        res = jsondecode(uav.battery.soc_ocv);
        if contains(fieldnames(res), 'z_coef')
           uav.battery.z_coef = res.z_coef'; 
           uav.battery = rmfield(uav.battery, 'soc_ocv');
        end
    else
        if uav.battery.v0 > 4.1 && uav.battery.v0 < 4.3
            uav.battery.soc_ocv = load('degradation/soc_ocv.mat').soc_ocv;
            
        end
    end
    
    % load the sensors
    
    
    % easier access to some variable
    uav.max_flight_time = uav.uav.max_flight_time;
    uav.id = uav.uav.id;
    
    % sample rate for the airframe dynamics
    uav.dynamics_srate = .025;
    
    % the current implementation assumes the entire mass value is captured in
    % the airframe (a mass field could be added to the asset class...)
    uav.mass = uav.airframe.mass;
    
    
    
end

