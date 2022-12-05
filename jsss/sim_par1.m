rng('shuffle');
session_num = randi(99999999);
rng(session_num);
disp(session_num);



% % get the root directory
% file_path = strsplit(fileparts(matlab.desktop.editor.getActiveFilename), filesep);
% idx = find(strcmp(file_path, 'uavtestbed'));
% root_directory = strjoin(file_path(1:idx), filesep);
% % switch to the root directory

username = char(java.lang.System.getProperty('user.name'));

root_directory = sprintf('/home/%s/uavtestbed', username);

cd(root_directory);

% load the workspace paths
addpath(genpath(root_directory));
clear('file_path', 'idx', 'root_directory');

% load the api
api = jsondecode(fileread('sql/api.json'));

% username=input('username: ', 's');
% password=input('password: ', 's');

password = 'Ch0colate!';
db_name = 'uav2_db';

%the database connection
conn = database(db_name, username, password);
stop_code_tb = select(conn, "select * from stop_code_tb;");
load('uav.mat');
%the battery never charges to the same output voltage level
uav.battery.v = pearsrnd(uav.battery.v-.25, uav.battery.v*.01, -1, 12);

uav.battery.z = min(1.01, pearsrnd(uav.battery.z-.0025, uav.battery.z*.01, -1, 12));

flight_id = select(conn, "select flight_id from true_age_tb order by id desc limit 1;").flight_id;


process_type = 'environment';
process_tb = select(conn, eval(api.matlab.process.LOAD_ALL_PROCESSES)) ; 

for i = 1:height(process_tb)
    params = process_tb(i, 'parameters').parameters{1};
    res = jsondecode(string(params));
    fn = fieldnames(res);
    for j = 1:length(fn)
        processes.(sprintf("%s", process_type)).(sprintf("%s", process_tb(i, 'subtype').subtype{1})).(sprintf("%s", process_tb(i, 'subtype2').subtype2{1})).(sprintf("%s", fn{j})) = res.(fn{j});
    end
end
clear i;

conn.close();
clear conn;

% load the trajectory information
trajectory_tb = readtable('trajectories/trajectories_exported.csv');
trajectory_tb = trajectory_tb(trajectory_tb.path_time < uav.max_flight_time - 1.95, :);
trajectory_tb = trajectory_tb(trajectory_tb.path_time > uav.max_flight_time - 5, :);
trajectory_tb = sortrows(trajectory_tb, "path_time", 'descend');

trajectory = get_trajectory(trajectory_tb, randi(height(trajectory_tb)));

clear trajectory_tb;

setup_sim_params;


   %[TODO] implement estimators and pull covariance 
Q_mu = polyval(uav.battery.q_coef, uav.battery.age);
Q_std = .02*Q_mu;

R0_mu = polyval(uav.battery.r_coef, uav.battery.age);
R0_std = .02*R0_mu;

uav.battery.Q = normrnd(Q_mu, Q_std);
uav.battery.Q = min(22.5, uav.battery.Q);

uav.battery.R0 = normrnd(R0_mu, R0_std);
uav.battery.R0 = max(.00105, uav.battery.R0);

for i = 1:length(uav.motors)
    m_mu = polyval(uav.motors(i).r_coef, uav.motors(i).age);
    m_std = .02*m_mu;
    uav.motors(i).Req = normrnd(m_mu, m_std);
    % min bound on motor resistance
    uav.motors(i).Req = max(.265, uav.motors(i).Req);
end
clear i;
counter = 0;

flight_num = 1;
while 1

    if  uav.battery.Q < sim_params.perf_param_thresh.min_soh_batt
        stop_code = stop_code_tb.id(strcmp(stop_code_tb.description, 'low soh (battery)'));
        disp('low charge capacitance, no longer safe to fly')
        break;
    end

    sim('simulink/tarot_model1.slx');

    z_start = battery.battery_true.z.Data(1);
    z_end = battery.battery_true.z.Data(end);
    v_start = battery.battery_true.v.Data(1);
    v_end = battery.battery_true.v.Data(end);

    stop_code = max(find(any(stop_codes.Data(:,:))));

    if mean(errors.euclidean_pos_err.Data) > sim_params.perf_param_thresh.avg_pos_err
        stop_code = stop_code_tb.id(strcmp(stop_code_tb.description, 'average position error'));
    end

    update_component_degradation;

    charge_battery;

    password = 'Ch0colate!';
    db_name = 'uav2_db';
    
    %the database connection
    conn = database(db_name, username, password);


    var_names = get_column_names(conn, 'stochastic_summary_tb');
    flight_summary_tb = table(max(find(any(stop_codes.Data(:,:)))), ...
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
                              trajectory.id, ...
                              uav.id, ...
                              uav.version, ...
                              flight_id, ...
                              flight_num, ...
                              session_num, ...
                              'VariableNames',  cellstr(var_names(1,2:end)));
    % write the data to the database
    sqlwrite(conn, 'stochastic_summary_tb', flight_summary_tb);


    var_names = get_column_names(conn, 'stochastic_degradation_tb');

    flight_degradation_tb = table(uav.battery.Q, ...
                                  uav.battery.R0, ...
                                  uav.motors(1).Req, ...
                                  uav.motors(2).Req, ...
                                  uav.motors(3).Req, ...
                                  uav.motors(4).Req, ...
                                  uav.motors(5).Req, ...
                                  uav.motors(6).Req, ...
                                  uav.motors(7).Req, ...
                                  uav.motors(8).Req, ...
                                  uav.id, ...
                                  uav.version, ...
                                  flight_id, ...
                                  flight_num, ...
                                  session_num, ...
                                  'VariableNames', cellstr(var_names(1,2:end)));
                              
    % write the data to the database
    sqlwrite(conn, 'stochastic_degradation_tb', flight_degradation_tb);

    conn.close();
    clear conn;

    flight_num = flight_num + 1;
    
    if flight_num == 3
        break
    end

    if stop_code ~= 4
        counter = counter + 1;
        if counter == 4
            break;
        end
    end

end

%uav.uav.age = 1.0;

password = 'Ch0colate!';
db_name = 'uav2_db';

%the database connection
conn = database(db_name, username, password);

execute(conn, sprintf('insert into stochastic_tb ("flight_id", "stop_code", "trajectory_id", "uav_age", "battery_age", "m1_age","m2_age","m3_age","m4_age","m5_age","m6_age","m7_age","m8_age", "session_num") values (%d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d);', ...
    flight_id, stop_code, trajectory.id, uav.uav.age, uav.battery.age, uav.motors(1).age, uav.motors(2).age, uav.motors(3).age, uav.motors(4).age, uav.motors(5).age, uav.motors(6).age, uav.motors(7).age, uav.motors(8).age, session_num))

conn.close();
clear conn;



