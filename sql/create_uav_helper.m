function serial_number = create_uav_helper(conn, owner, serial_number_in)
    %%
    %       @brief: helper function to create a UAV
    %
    %       @params: 
    %           conn - the database connection object
    %           owner - the username of the owner
    %           serial_number - the unique identifier of the UAV
    %
    %       @returns: the serial number with 'u' appended to the front for
    %       UAV. Then the user can call load_uav(conn, serial_number)
    %
    %       @constraints: 
    %           ~exists(serial_number)
    %
    %%
    type_id       = 1; % airframe
    serial_number = sprintf("x%06d", serial_number_in);
    num_motors    = 8;
    age           = 0;
    units         = "flight hours";


    airframe = create_default_airframe(conn, ...
                                       owner, ...
                                       type_id, ...
                                       serial_number, ...
                                       num_motors, ...
                                       age, ...
                                       units);


    type_id       = 2; % motor   
    for i=1:airframe.num_motors
        serial_number = sprintf("m%06d-%d", serial_number_in, i);
        motor = create_default_motor(conn, ...
                                     owner, ...
                                     type_id, ...
                                     serial_number, ...
                                     age, ... 
                                     units);
       motors.(sprintf("motor_%d", i)) = motor;
    end                               
                               
    type_id       = 3; % battery 
    serial_number = sprintf("b%06d", serial_number_in);
    units         = "cumulative amp hours";
    battery = create_default_battery(conn, ...
                                     owner, ...
                                     type_id, ...
                                     serial_number, ...
                                     age, ...
                                     units);
    
    type_id       = 4; % uav
    units         = "flight hours";
    serial_number = sprintf("u%06d", serial_number_in);
    uav = create_default_uav(conn, ...
                         owner, ...
                         type_id, ...
                         serial_number, ...
                         age, ...
                         units, ...
                         airframe, ...
                         battery, ...
                         motors);
                     
  
end

