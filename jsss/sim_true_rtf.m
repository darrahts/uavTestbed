rng('shuffle');
rand_num = randi(999999);
rng(rand_num);

addpath(genpath('C:\Users\darrahts\Desktop\uavtestbed\'));

api = jsondecode(fileread('sql/api.json'));
conn = db_connect('nasadb');

experiment_info = "run to failure true system v2";

group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
if isempty(group_id)
    execute(conn, sprintf('insert into group_tb("info") values(''%s'')', experiment_info));
    group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
end

uav = create_and_load_uav(conn, api)
%uav_tb = select(conn, api.matlab.assets.LOAD_ALL_UAVS);
%uav = load_uav(conn, uav_tb.serial_number{2}, api);
%clear uav_tb;

% get the start time
dt_last = table2array(select(conn, 'select mt.dt_stop from flight_summary_tb mt order by dt_stop desc limit 1;'));
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
% get the flight_id (the unique id in the data table)
flight_id = table2array(select(conn, 'select id from flight_summary_tb order by id desc limit 1;')) + 1;
if isempty(flight_id)
    flight_id = 1;
end

% the flight number of the selected uav (i.e. how many flights it has gone
% previously + 1 for the upcomming flight)
flight_num = table2array(select(conn, sprintf('select flight_num from flight_summary_tb where uav_id = %d order by dt_start desc limit 1;', uav.id))) + 1;
if isempty(flight_num)
    flight_num = 1;
end

% close the connection and clear the table (the data is in the uav struct now)
conn.close();
clear('uav_tb', 'conn');

% load the trajectory information
trajectory_tb = readtable('trajectories/trajectories_exported.csv');
trajectory_tb = trajectory_tb(trajectory_tb.path_time < uav.max_flight_time, :);
trajectory_tb = trajectory_tb(trajectory_tb.path_time > uav.max_flight_time - 5, :);
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

for i = 1:length(uav.motors)
    m_mu = polyval(uav.motors(i).r_coef, uav.motors(i).age);
    m_std = .02*m_mu;
    uav.motors(i).Req = normrnd(m_mu, m_std);
    % min bound on motor resistance
    uav.motors(i).Req = max(.265, uav.motors(i).Req);
end


stop_count = 0;
k = 1;
t1 = tic
while stop_count < 10
 fprintf("%f, %f, %f, %d, %d, %d\n", uav.battery.Q, uav.battery.R0, uav.motors(1).Req, flight_num, flight_id, stop_count)
    
    trajectory = get_trajectory(trajectory_tb, randi(height(trajectory_tb)));
    disp('sim true');

    sim('simulink/uav_simulation_tarot.slx');

    dt_stop = dt_start + minutes(time.Data(end, 1));

    stop_code = max(find(any(stop_codes.Data(:,:))));
    
    disp('update component degradation');
    update_component_degradation;
    
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
        fprintf("Threshold violation or failure indicated by stop_code %d\n", stop_code);
        stop_count = stop_count + 1;
    end
    
    disp('charge battery');
    charge_battery;
    
    %the battery never charges to the same output voltage level
    uav.battery.v = pearsrnd(uav.battery.v-.25, uav.battery.v*.01, -1, 12);
    
    disp('update asset age');
    update_assets_age;
    
    disp('insert flight data');
    insert_flight_data;

    dt_start = dt_stop + minutes(1);
    flight_id = flight_id + 1;
    flight_num = flight_num + 1;
    
    k = k + 1;
end

t2 = tic

fprintf("elapsed time: %f", (double(t2 - t1)/10000000.0))



