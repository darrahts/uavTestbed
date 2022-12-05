% get the root directory
file_path = strsplit(fileparts(matlab.desktop.editor.getActiveFilename), '\');
idx = find(strcmp(file_path, 'uavtestbed'));
root_directory = strjoin(file_path(1:idx), '\');
% switch to the root directory
cd(root_directory);

% load the workspace paths
addpath(genpath(root_directory));
clear('file_path', 'idx', 'root_directory');

% load the api
api = jsondecode(fileread('sql/api.json'));


% the database connection
conn = db_connect('nasadb');

% check out what UAVs are in the db
uav_tb = select(conn, api.matlab.assets.LOAD_ALL_UAVS);
uav = load_uav(conn, uav_tb.serial_number{3}, api);


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

group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
if isempty(group_id)
    execute(conn, sprintf('insert into group_tb("info") values(''%s'')', experiment_info));
    group_id = select(conn, sprintf("select id from group_tb where info ilike '%%%s%%';", experiment_info)).id;
end




% close the connection and clear the table (the data is in the uav struct now)
conn.close();
clear('uav_tb', 'conn');


% load the trajectory information
trajectory_tb = readtable('trajectories/trajectories_exported.csv');
trajectory_tb = trajectory_tb(trajectory_tb.path_time < uav.max_flight_time, :);
trajectory_tb = trajectory_tb(trajectory_tb.path_time > uav.max_flight_time - 5, :);
trajectory_tb = sortrows(trajectory_tb, "path_time", 'descend');