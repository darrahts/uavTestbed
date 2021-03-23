function stop = write_battery_data(conn, battery_actual, battery_observed, start, battery_id, uav_id, mission_id)


    stop = start + seconds(battery_observed.Time(end, 1));
    battery_observed_rs = resample_ts(battery_observed, 1, start);
    battery_actual_rs = resample_ts(battery_actual, 1, start);
    time_vec = [start: seconds(1) : stop]';
    time_vec.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
    bid_ts = timeseries(repmat(battery_id, [length(time_vec), 1]));
    uid_ts = timeseries(repmat(uav_id, [length(time_vec), 1]));
    mid_ts = timeseries(repmat(mission_id, [length(time_vec), 1]));
    battery_tb_cols = {'v', 'z', 'r0', 'q', 'v_prime', 'v_hat', 'z_hat', 'z_bound', 'r0_hat', 'r0_bound', 'battery_id', 'uav_id', 'mission_id'};
    battery_tb = timetable(time_vec, round(battery_actual_rs.Data(:,1), 4), round(battery_actual_rs.Data(:,2), 4), ...
        round(battery_actual_rs.Data(:,3), 6), round(battery_actual_rs.Data(:,6), 4), round(battery_observed_rs.Data(:,1), 4), ...
        round(battery_observed_rs.Data(:,2), 4), round(battery_observed_rs.Data(:,3), 4), round(battery_observed_rs.Data(:,4), 4), ...
        round(battery_observed_rs.Data(:,5), 6), round(battery_observed_rs.Data(:,6), 6), bid_ts.Data(:,1), uid_ts.Data(:,1), mid_ts.Data(:,1), 'VariableNames', battery_tb_cols);
    battery_tb = timetable2table(battery_tb);
    battery_tb.Properties.VariableNames(1) = {'dt'};

    sqlwrite(conn, 'battery_sensor_tb', battery_tb);
    clear('battery_observed_rs', 'battery_actual_rs', 'bid_ts', 'uid_ts', 'mid_ts', 'battery_tb_cols', 'battery_tb');

end

