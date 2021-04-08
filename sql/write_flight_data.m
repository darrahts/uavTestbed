



sensor_sample_rate = .25;

time_vec = [start: seconds(sensor_sample_rate) : stop]';
time_vec.Format = 'uuuu-MM-dd HH:mm:ss.SSS';

current_rs = resample_ts(current, sensor_sample_rate, start);
ctrl_err_rs = resample_ts(ctrl_err, sensor_sample_rate, start);
pos_err_rs = resample_ts(euclidean_pos_err, sensor_sample_rate, start);
pos_observed_rs = resample_ts(pos_observed, sensor_sample_rate, start);
motors_rs = resample_ts(motors, sensor_sample_rate, start);
bid_ts = timeseries(repmat(battery.id, [length(time_vec), 1]));
uid_ts = timeseries(repmat(octomodel.id, [length(time_vec), 1]));
mid_ts = timeseries(repmat(mission_id, [length(time_vec), 1]));


flight_sensor_tb_cols = {'current', 'x_ctrl_err', 'y_ctrl_err', 'pos_err', ...
    'x_pos', 'y_pos', 'm2_res', 'm4_res', 'm5_res', 'battery_id', 'uav_id', 'mission_id'};
flight_sensor_tb = timetable(time_vec, round(current_rs.Data(:,1),3), round(ctrl_err_rs.Data(:,1),4), round(ctrl_err_rs.Data(:,2),4), ...
    round(pos_err_rs.Data(:,1),2), round(pos_observed_rs.Data(:,1),2), round(pos_observed_rs.Data(:,2),2), round(motors_rs.Data(:,1),6), ...
    round(motors_rs.Data(:,2),6), round(motors_rs.Data(:,3),6), bid_ts.Data(:,1), uid_ts.Data(:,1), mid_ts.Data(:,1), ...
    'VariableNames',flight_sensor_tb_cols);
flight_sensor_tb = timetable2table(flight_sensor_tb);
flight_sensor_tb.Properties.VariableNames(1) = {'dt'};
flight_sensor_tb.dt.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
flight_sensor_tb.dt = cellstr(flight_sensor_tb.dt);

sqlwrite(conn, 'flight_sensor_tb', flight_sensor_tb);

clear('ctrl_err_rs', 'bid_ts', 'uid_ts', 'mid_ts', 'flight_sensor_tb_cols', 'flight_sensor_tb');
clear('pos_err_rs', 'pos_observed_rs', 'motors_rs');   


