

sensor_sample_rate = 1;

battery_observed_rs = resample_ts(battery_observed, sensor_sample_rate, start);
battery_actual_rs = resample_ts(battery_actual, sensor_sample_rate, start);
time_vec = [start: seconds(sensor_sample_rate) : stop]';
time_vec.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
bid_ts = timeseries(repmat(battery.id, [length(time_vec), 1]));
uid_ts = timeseries(repmat(octomodel.id, [length(time_vec), 1]));
mid_ts = timeseries(repmat(mission_id, [length(time_vec), 1]));
battery_tb_cols = {'v', 'z', 'r0', 'q', 'v_prime', 'v_hat', 'z_hat', 'z_bound', 'r0_hat', 'r0_bound', 'battery_id', 'uav_id', 'mission_id'};
battery_tb = timetable(time_vec, round(battery_actual_rs.Data(:,1), 4), round(battery_actual_rs.Data(:,2), 4), ...
    round(battery_actual_rs.Data(:,3), 6), round(battery_actual_rs.Data(:,6), 4), round(battery_observed_rs.Data(:,1), 4), ...
    round(battery_observed_rs.Data(:,2), 4), round(battery_observed_rs.Data(:,3), 4), round(battery_observed_rs.Data(:,4), 4), ...
    round(battery_observed_rs.Data(:,5), 6), round(battery_observed_rs.Data(:,6), 6), bid_ts.Data(:,1), uid_ts.Data(:,1), ...
    mid_ts.Data(:,1), 'VariableNames', battery_tb_cols);
battery_tb = timetable2table(battery_tb);
battery_tb.Properties.VariableNames(1) = {'dt'};
battery_tb.dt.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
battery_tb.dt = cellstr(battery_tb.dt);

sqlwrite(conn, 'battery_sensor_tb', battery_tb);
clear('battery_observed_rs', 'battery_actual_rs', 'bid_ts', 'uid_ts', 'mid_ts', 'battery_tb_cols', 'battery_tb');
