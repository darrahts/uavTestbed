
rng('shuffle');
rand_num = randi(9999999);
rng(rand_num);
disp(rand_num);

s = dbstack();
file_id = regexp(s(1).file, '(\d*)', 'match');
file_id = int32(str2double(file_id{1}));
disp(file_id)

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
% disp(conn)

stop_code_tb = select(conn, "select * from stop_code_tb;");

group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
if isempty(group_id)
    execute(conn, sprintf('insert into group_tb("info") values(''%s'')', experiment_info));
    group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
end

disp('loading uav');

% check out what UAVs are in the db
uav_tb = select(conn, api.matlab.assets.LOAD_ALL_UAVS);
uav_tb = sortrows(uav_tb, {'id', 'version'});


% serial_number = char(uav_tb(strcmp(uav_tb.common_name, 'tarot t18 uav'), :).serial_number);
% serial_number = string(serial_number(1,:));
% version = max(uav_tb(strcmp(uav_tb.common_name, 'tarot t18 uav'), :).version);
% uav = load_uav(conn, serial_number, version, api);
disp(uav_id)
uav = uav_tb(uav_tb.id==uav_id, :);
uav = load_uav_id(conn, api, uav)


if check_stops == 1
    stop_count = table2array(select(conn, sprintf('select count(*) from session_tb where stop_code != 4 and uav_id = %d', uav.id)));
    disp(sprintf('stop count: %d', stop_count))
    if stop_count == 8
        disp('stop count reached. exiting');
        exit;
    end
else
    stop_count = 0;
    disp('skipping stop check');
end

% get the start time
dt_last = table2array(select(conn, 'select mt.dt_stop from session_tb mt order by dt_stop desc limit 1;'));
if ~isempty(dt_last)
    dt_last = datetime(dt_last);
end

if isempty(dt_last)
    % the first entry into flight_summary_tb is now
    dt_start = datetime(now, 'ConvertFrom', 'datenum');
else
    % this entry into flight_summary_tb is the last entry + 1 minute
    dt_start = dt_last + minutes(1);
end
dt_start = datetime(dt_start, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
dt_start = dateshift(dt_start, 'start', 'second');


% the flight number of the selected uav (i.e. how many flights it has gone
% previously + 1 for the upcomming flight)
flight_num = table2array(select(conn, sprintf('select flight_num from session_tb where uav_id = %d order by dt_start desc limit 1;', uav.id))) + 1;
if isempty(flight_num)
    flight_num = 1;
end

% load the trajectory information
trajectory_tb = readtable('trajectories/trajectories_exported.csv');
trajectory_tb = trajectory_tb(trajectory_tb.path_time < 1300, :);
trajectory_tb = trajectory_tb(trajectory_tb.path_time > 950, :);
trajectory_tb = sortrows(trajectory_tb, "path_time", 'descend');

setup_sim_params;

load_process_data;


% initialize the degradation parameters to randomly sampled values
   %[TODO] implement estimators and pull covariance 
Q_mu = polyval(uav.battery.q_coef, uav.battery.age);
Q_std = .02*Q_mu;

R0_mu = polyval(uav.battery.r_coef, uav.battery.age);
R0_std = .02*R0_mu;

uav.battery.Q = normrnd(Q_mu, Q_std);
uav.battery.Q = min(22.5, uav.battery.Q);

uav.battery.R0 = normrnd(R0_mu, R0_std);
uav.battery.R0 = max(.00105, uav.battery.R0);

%the battery never charges to the same output voltage level
uav.battery.v = pearsrnd(uav.battery.v-.25, uav.battery.v*.01, -1, 12);
uav.battery.z = min(1.01, pearsrnd(uav.battery.z-.0025, uav.battery.z*.01, -1, 12));

for i = 1:length(uav.motors)
    m_mu = polyval(uav.motors(i).r_coef, uav.motors(i).age);
    m_std = .02*m_mu;
    uav.motors(i).Req = normrnd(m_mu, m_std);
     % min bound on motor resistance
    uav.motors(i).Req = max(.265, uav.motors(i).Req) + normrnd(.002, .001);
    if uav.motors(i).age < 800 
        uav.motors(i).Req = min(.28, uav.motors(i).Req + normrnd(.002, .001));
    elseif uav.motors(i).age >=800 && uav.motors(i).age < 1200
        uav.motors(i).Req = min(.31, uav.motors(i).Req + normrnd(.002, .001));
    end
end

% k = 1;
t1 = tic
while stop_count < 8

    %% set constant wind
    rng(round(rand*1000000));
    constant_x_wind = normrnd(1.5, .75);
    if rand > .5
        constant_x_wind = -constant_x_wind;
    end
    constant_y_wind = normrnd(1.5, .75);
    if rand > .5
        constant_y_wind = -constant_y_wind;
    end
    constant_z_wind = normrnd(0, .4);
    if rand > .5
        constant_z_wind = -constant_z_wind;
    end


    trajectory = get_trajectory(trajectory_tb, randi(height(trajectory_tb)));
    disp(trajectory)
    
    sim_params.initial_conditions.X = trajectory.start(1);
    sim_params.initial_conditions.Y = trajectory.start(2);

    disp('sim true');
    sim(sprintf('simulink/uav_simulation_tarot%d.slx', file_id));


    z_start = battery.battery_true.z.Data(1);
    z_end = battery.battery_true.z.Data(end);
    v_start = battery.battery_true.v.Data(1);
    v_end = battery.battery_true.v.Data(end);

    uav.battery.v = v_end;
    uav.battery.z = z_end;

    dt_stop = dt_start + minutes(time.Data(end, 1));

    stop_code = max(find(any(stop_codes.Data(:,:))));


    disp('checking constraints')
    if mean(errors.euclidean_pos_err.Data) > sim_params.perf_param_thresh.avg_pos_err
        stop_code = stop_code_tb.id(strcmp(stop_code_tb.description, 'average position error'));
        disp('position error violation');
    end

    if  uav.battery.Q < sim_params.perf_param_thresh.min_soh_batt
        stop_code = stop_code_tb.id(strcmp(stop_code_tb.description, 'low soh (battery)'));
        disp('low charge capacitance, no longer safe to fly');
    end  

    if stop_code ~= 4
        stop_count = stop_count + 1;
        fprintf("Threshold violation or failure indicated by stop_code %d, stop count: %d\n", stop_code, stop_count);
    end


    disp('charge battery');
    charge_battery;

    disp('update component degradation');
    update_component_degradation;

    disp('update component degradation parameters');
    update_component_parameters;

    disp('update asset age');
    update_assets_age;

    disp('insert flight data');
    insert_flight_data;

    execute(conn, sprintf('insert into true_age_tb ("flight_id", "stop_code", "trajectory_id", "uav_age", "battery_age", "m1_age","m2_age","m3_age","m4_age","m5_age","m6_age","m7_age","m8_age") values (%d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f);', ...
        flight_id, stop_code, trajectory.id, uav.uav.age, uav.battery.age, uav.motors(1).age, uav.motors(2).age, uav.motors(3).age, uav.motors(4).age, uav.motors(5).age, uav.motors(6).age, uav.motors(7).age, uav.motors(8).age));

    dt_start = dt_stop + minutes(120);
    flight_id = flight_id + 1;
    flight_num = flight_num + 1;
    
%    k = k + 1;
%     if k == 3
%         break;
%     end
end

t2 = tic

fprintf("elapsed time: %f", (double(t2 - t1)/10000000.0))

close(conn);
conn.close();
clear conn;

disp('exiting');
exit;








