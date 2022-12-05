% get the variable names, but note "id" isn't used
var_names = get_column_names(conn, 'session_tb');
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
                          'VariableNames',  cellstr(var_names(1,2:end)));
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


sample_rate = 1;

battery_tt = sync_telemetry_data(battery, sample_rate, time.Time(:));
errors_tt = sync_telemetry_data(errors, sample_rate, time.Time(:));
errors_tt.Properties.VariableNames{'pos_err_x_pos_err'} = 'x_pos_err';
errors_tt.Properties.VariableNames{'pos_err_y_pos_err'} = 'y_pos_err';
errors_tt.Properties.VariableNames{'ctrl_err_x_error'}  = 'x_ctrl_err';
errors_tt.Properties.VariableNames{'ctrl_err_y_error'}  = 'y_ctrl_err';
environment_tt = sync_telemetry_data(environment, sample_rate, time.Time(:));
environment_tt.Properties.VariableNames{'wind_gust-1'}  = 'wind_gust_x';
environment_tt.Properties.VariableNames{'wind_gust-2'}  = 'wind_gust_y';
environment_tt.Properties.VariableNames{'wind_gust-3'}  = 'wind_gust_z';
motors_tt = sync_telemetry_data(motors, sample_rate, time.Time(:));
position_tt = sync_telemetry_data(position, sample_rate, time.Time(:));
position_tt.Properties.VariableNames{'gps-1'}  = 'x_pos_gps';
position_tt.Properties.VariableNames{'gps-2'}  = 'y_pos_gps';
position_tt.Properties.VariableNames{'gps-3'}  = 'z_pos_gps';
position_tt.Properties.VariableNames{'true-1'}  = 'x_pos_true';
position_tt.Properties.VariableNames{'true-2'}  = 'y_pos_true';
position_tt.Properties.VariableNames{'true-3'}  = 'z_pos_true';
velocity_tt = sync_telemetry_data(velocity, sample_rate, time.Time(:));
velocity_tt.Properties.VariableNames{'gps-1'}  = 'x_vel_gps';
velocity_tt.Properties.VariableNames{'gps-2'}  = 'y_vel_gps';
velocity_tt.Properties.VariableNames{'gps-3'}  = 'z_vel_gps';
velocity_tt.Properties.VariableNames{'true-1'}  = 'x_vel_true';
velocity_tt.Properties.VariableNames{'true-2'}  = 'y_vel_true';
velocity_tt.Properties.VariableNames{'true-3'}  = 'z_vel_true';
flight_telemetry_tb = [battery_tt environment_tt motors_tt errors_tt position_tt velocity_tt];
clear('battery_tt', 'environment_tt', 'motors_tt', 'errors_tt', 'position_tt', 'velocity_tt');
flight_telemetry_tb.Properties.DimensionNames{1} = 'dt';
dt_start.Format = 'MM-dd-uuuu HH:mm:ss.SSS';
dt_stop.Format = 'MM-dd-uuuu HH:mm:ss.SSS';
time_vec = datetime([dt_start: seconds(1/sample_rate) : dt_stop]');
flight_telemetry_tb.dt = time_vec;
nrows = size(flight_telemetry_tb,1);
flight_telemetry_tb.flight_id = double(flight_id)+zeros(nrows,1);

% poly_v = polyfit(1:1:length(flight_telemetry_tb.battery_true_v), flight_telemetry_tb.battery_true_v, 4);
% poly_z = polyfit(1:1:length(flight_telemetry_tb.battery_true_z), flight_telemetry_tb.battery_true_z, 4);
% poly_i = polyfit(1:1:length(flight_telemetry_tb.battery_true_i), flight_telemetry_tb.battery_true_i, 4);

% idx_v = find(ismissing(flight_telemetry_tb.battery_true_v));
% idx_z = find(ismissing(flight_telemetry_tb.battery_true_z));
% idx_i = find(ismissing(flight_telemetry_tb.battery_true_i));

% for i = 1:length(idx_z)
%     flight_telemetry_tb.battery_true_v(idx_v(i)) = polyval(poly_v, i);
%     flight_telemetry_tb.battery_true_z(idx_z(i)) = polyval(poly_z, i);
%     flight_telemetry_tb.battery_true_i(idx_i(i)) = polyval(poly_i, i);
% end

flight_telemetry_tb = timetable2table(flight_telemetry_tb);
flight_telemetry_tb.flight_id = repmat(flight_id, height(flight_telemetry_tb), 1);


sqlwrite(conn, 'telemetry_tb', flight_telemetry_tb);
