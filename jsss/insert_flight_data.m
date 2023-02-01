velocity.true.Data(:,4) = sqrt(velocity.true.Data(:,1).^2 + velocity.true.Data(:,2).^2);
velocity.true.Data(:,5) = sqrt(acceleration.Data(:,1).^2 + acceleration.Data(:,2).^2);

var_names = get_column_names(conn, 'session_tb');
var_names = cellstr(var_names(1,2:end));
flight_summary_tb = table(stop_code, ...
                          z_start, ...
                          z_end, ...
                          v_start, ...
                          v_end, ...
                          mean(motors.m1.current), ...
                          mean(motors.m2.current), ...
                          mean(motors.m3.current), ...
                          mean(motors.m4.current), ...
                          mean(motors.m5.current), ...
                          mean(motors.m6.current), ...
                          mean(motors.m7.current), ...
                          mean(motors.m8.current), ...
                          mean(velocity.true.Data(:,4)), ...
                          std(velocity.true.Data(:,4)), ...
                          mean(velocity.true.Data(:,5)), ...
                          std(velocity.true.Data(:,5)), ...
                          mean(errors.euclidean_pos_err), ...
                          max(errors.euclidean_pos_err), ...
                          std(errors.euclidean_pos_err), ...
                          mean(sqrt(errors.ctrl_err.x_error.Data.^2 + errors.ctrl_err.y_error.Data.^2)), ...
                          max(sqrt(errors.ctrl_err.x_error.Data.^2 + errors.ctrl_err.y_error.Data.^2)), ...
                          std(sqrt(errors.ctrl_err.x_error.Data.^2 + errors.ctrl_err.y_error.Data.^2)), ...
                          round(calculatedistance([position.true.Data(:,1) position.true.Data(:,2)]), 4), ...
                          time.Time(end)/60, ...
                          mean(battery.battery_true.i.Data), ...
                          mean(battery.battery_true.i.Data)*time.Time(end)/60/60, ...
                          dt_start, ...
                          dt_start + minutes(time.Time(end)/60), ...
                          trajectory.id, ...
                          uav.id, ...
                          uav.version, ...
                          flight_num, ...
                          group_id, ...
                          'VariableNames',  var_names);
% write the data to the database
sqlwrite(conn, 'session_tb', flight_summary_tb);



flight_id = select(conn, 'select id from session_tb order by id desc limit 1').id;
var_names = {'flight_id' 'q_deg' 'r_deg' 'm1_deg' 'm2_deg' 'm3_deg' 'm4_deg' 'm5_deg' 'm6_deg' 'm7_deg' 'm8_deg'};
flight_degradation_tb = table(flight_id, ...
                              uav.battery.Q, ...
                              uav.battery.R0, ...
                              uav.motors(1).Req, ...
                              uav.motors(2).Req, ...
                              uav.motors(3).Req, ...
                              uav.motors(4).Req, ...
                              uav.motors(5).Req, ...
                              uav.motors(6).Req, ...
                              uav.motors(7).Req, ...
                              uav.motors(8).Req, ...
                              'VariableNames', var_names);
                          
% write the data to the database
sqlwrite(conn, 'degradation_tb', flight_degradation_tb);

flight_telemetry_tb = timetable;
sample_rate = 1;
try
    battery_tt = sync_telemetry_data(battery, sample_rate, time.Time(:));
    flight_telemetry_tb = [flight_telemetry_tb battery_tt];
    clear('battery_tt');
catch me
    disp('could not sync battery data')
    fprintf('%s', string(me.message))
end
try
    errors_tt = sync_telemetry_data(errors, sample_rate, time.Time(:));
    errors_tt.Properties.VariableNames{'ctrl_err_x_error'}  = 'x_ctrl_err';
    errors_tt.Properties.VariableNames{'ctrl_err_y_error'}  = 'y_ctrl_err';
    flight_telemetry_tb = [flight_telemetry_tb errors_tt];
    clear('errors_tt');
catch me
    disp('could not sync errors data')
    fprintf('%s', string(me.message))
end
try
    environment_tt = sync_telemetry_data(environment, sample_rate, time.Time(:));
    environment_tt.Properties.VariableNames{'wind_gust-1'}  = 'wind_gust_x';
    environment_tt.Properties.VariableNames{'wind_gust-2'}  = 'wind_gust_y';
    environment_tt.Properties.VariableNames{'wind_gust-3'}  = 'wind_gust_z';
    environment_tt.Properties.VariableNames{'constant_wind-1'}  = 'wind_const_x';
    environment_tt.Properties.VariableNames{'constant_wind-2'}  = 'wind_const_y';
    environment_tt.Properties.VariableNames{'constant_wind-3'}  = 'wind_const_z';
    flight_telemetry_tb = [flight_telemetry_tb environment_tt];
    clear('environment_tt');
catch me
    disp('could not sync environment data')
    fprintf('%s', string(me.message))
end

try
    motors_tt = sync_telemetry_data(motors, sample_rate, time.Time(:));
    flight_telemetry_tb = [flight_telemetry_tb motors_tt];
    clear('motors_tt');
catch me
    disp('could not sync motor data')
    fprintf('%s', string(me.message))
end
try
    position_tt = sync_telemetry_data(position, sample_rate, time.Time(:));
    position_tt.Properties.VariableNames{'gps-1'}  = 'x_pos_gps';
    position_tt.Properties.VariableNames{'gps-2'}  = 'y_pos_gps';
    position_tt.Properties.VariableNames{'gps-3'}  = 'z_pos_gps';
    position_tt.Properties.VariableNames{'true-1'}  = 'x_pos_true';
    position_tt.Properties.VariableNames{'true-2'}  = 'y_pos_true';
    position_tt.Properties.VariableNames{'true-3'}  = 'z_pos_true';
    flight_telemetry_tb = [flight_telemetry_tb position_tt];
    clear('position_tt');
catch me
    disp('could not sync position data')
    fprintf('%s', string(me.message))
end
try
    velocity_tt = sync_telemetry_data(velocity, sample_rate, time.Time(:));
    velocity_tt.Properties.VariableNames{'gps-1'}  = 'x_vel_gps';
    velocity_tt.Properties.VariableNames{'gps-2'}  = 'y_vel_gps';
    velocity_tt.Properties.VariableNames{'gps-3'}  = 'z_vel_gps';
    velocity_tt.Properties.VariableNames{'true-1'}  = 'x_vel_true';
    velocity_tt.Properties.VariableNames{'true-2'}  = 'y_vel_true';
    velocity_tt.Properties.VariableNames{'true-3'}  = 'z_vel_true';
    velocity_tt.Properties.VariableNames{'true-4'}  = 'velocity';
    velocity_tt.Properties.VariableNames{'true-5'}  = 'acceleration';
    flight_telemetry_tb = [flight_telemetry_tb velocity_tt];
    clear('velocity_tt');
catch me
    disp('could not sync velocity data')
    fprintf('%s', string(me.message))
end

try
    flight_telemetry_tb.Properties.DimensionNames{1} = 'dt';
    dt_start.Format = 'MM-dd-uuuu HH:mm:ss.SSS';
    dt_stop.Format = 'MM-dd-uuuu HH:mm:ss.SSS';
    time_vec = datetime([dt_start: seconds(1/sample_rate) : dt_stop]');
    flight_telemetry_tb.dt = time_vec;
    nrows = size(flight_telemetry_tb,1);
    flight_telemetry_tb.flight_id = double(flight_id)+zeros(nrows,1);
    
    flight_telemetry_tb = timetable2table(flight_telemetry_tb);
    flight_telemetry_tb = fillmissing(flight_telemetry_tb, 'previous');
    flight_telemetry_tb.flight_id = repmat(flight_id, height(flight_telemetry_tb), 1);
    
    sqlwrite(conn, 'telemetry_tb', flight_telemetry_tb);
catch me
    disp('could not insert telemetry data')
    fprintf('%s', string(me.message))
end

