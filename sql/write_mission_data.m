

stop_code_res = max(find(any(stop_code.Data(:,:))));
distance = calculatedistance([pos_observed.Data(:,1) pos_observed.Data(:,2)]);
z_end = battery_actual.Data(end, 2);
v_end = battery_actual.Data(end, 1);
avg_pos_err = mean(euclidean_pos_err.Data(:,1));
max_pos_err = max(euclidean_pos_err.Data(:,1));
std_pos_err = std(euclidean_pos_err.Data(:,1));
avg_ctrl_err = mean([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);
max_ctrl_err = max([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);
std_ctrl_err = std([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);

mission_tb_cols = {'dt_start', 'dt_stop', 'stop_code', 'prior_rul', 'flight_time', 'distance', ...
                   'z_end', 'v_end', 'avg_pos_err', 'max_pos_err', 'std_pos_err', 'avg_ctrl_err', ...
                   'max_ctrl_err', 'std_ctrl_err', 'battery_id', 'uav_id'};
mission_tb = table(start, stop, stop_code_res, round(rul_hat, 4), round(flight_time.Data(end),4), round(distance, 4), round(z_end, 4), ...
                   round(v_end, 4), round(avg_pos_err, 4), round(max_pos_err, 4), round(std_pos_err, 4), round(avg_ctrl_err, 4), ...
                   round(max_ctrl_err, 4), round(std_ctrl_err, 4), battery.id, octomodel.id, 'VariableNames', mission_tb_cols);

sqlwrite(conn, 'mission_tb', mission_tb);

clear('stop_code_res', 'distance', 'z_end', 'v_end', 'avg_pos_err', 'max_pos_err', 'std_pos_err');
clear('avg_ctrl_err', 'max_ctrl_err', 'std_ctrl_err', 'mission_tb_cols', 'mission_tb');