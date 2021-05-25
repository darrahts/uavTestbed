
conn = database(datasource_name, user_name, password);

stop_code_res = max(find(any(stop_code.Data(:,:))));
z_end = battery_actual.Data(end, 2);
v_end = battery_actual.Data(end, 1);
avg_pos_err = mean(euclidean_pos_err.Data(:,1));
max_pos_err = max(euclidean_pos_err.Data(:,1));
std_pos_err = std(euclidean_pos_err.Data(:,1));
avg_ctrl_err = mean([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);
max_ctrl_err = max([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);
std_ctrl_err = std([ctrl_err.Data(:,1); ctrl_err.Data(:,2)]);
%sprintf("%f, %f", distance, flight_time.Data(end))
mission_tb_cols = {'dt_start', 'dt_stop', 'trajectory_id', 'stop_code', 'prior_rul', 'flight_time', 'distance', ...
                   'z_end', 'v_end', 'avg_pos_err', 'max_pos_err', 'std_pos_err', 'avg_ctrl_err', ...
                   'max_ctrl_err', 'std_ctrl_err', 'battery_id', 'uav_id', 'idx'};
mission_tb = table(start, stop, trajectory.id, stop_code_res, round(rul_hat, 4), round(flight_time.Data(end),4), round(distance, 4), round(z_end, 4), ...
                   round(v_end, 4), round(avg_pos_err, 4), round(max_pos_err, 4), round(std_pos_err, 4), round(avg_ctrl_err, 4), ...
                   round(max_ctrl_err, 4), round(std_ctrl_err, 4), battery.id, octomodel.id, mission_idx, 'VariableNames', mission_tb_cols);

sqlwrite(conn, 'mission_tb', mission_tb);
conn.commit();
conn.close();
clear('stop_code_res', 'distance', 'z_end', 'v_end', 'avg_pos_err', 'max_pos_err', 'std_pos_err');
clear('avg_ctrl_err', 'max_ctrl_err', 'std_ctrl_err', 'mission_tb_cols', 'mission_tb');