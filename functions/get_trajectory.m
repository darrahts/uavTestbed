function trajectory = get_trajectory(file_name, max_flight_time, desired_velocity)
%%
%
%       TODO: function comments, refactor into the api folder. update.
%       clean. 
%
%       discuss briefly how the trajectories are generated and what they
%       are
%
%%
    
    trajectory_tb = readtable(file_name);
    
    trajectory_tb = trajectory_tb(trajectory_tb.path_time < max_flight_time, :);
    trajectory_tb = sortrows(trajectory_tb, "path_time", 'descend');

    if height(trajectory_tb) < 1
        disp("[INFO] returning empty table")
        trajectory = table();
        return;
    else
        idx = randi(height(trajectory_tb));
        trajectory = table2struct(trajectory_tb(idx,:));
    end
    
    trajectory.x_waypoints = str2double(regexp(trajectory.x_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.y_waypoints = str2double(regexp(trajectory.y_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.waypoints = [trajectory.x_waypoints' trajectory.y_waypoints'];
    
    if isempty(trajectory.x_ref_points)
        map = load('trajectories/test_map.mat');
        map = map.test_map;
        Resolution=0.1; % meters
        map = binaryOccupancyMap(map,Resolution);
        uavRadius = .5;
        start = [50 50];    
        % inflate map
        inflate(map,uavRadius);
        prm = mobileRobotPRM;
        prm.Map = map;

        prm.NumNodes = 5000;
        prm.ConnectionDistance = 100;
        waypoints = [start];
        waypoints2 = [trajectory.x_waypoints' trajectory.y_waypoints'];
        waypoints = [waypoints; waypoints2];
        path = findpath(prm, start, waypoints(1,:));
        for i = 2:length(waypoints(:,1))
           p = findpath(prm, waypoints(i-1,:), waypoints(i,:));
           path = [path; p];
        end

        path_distance = calculatedistance(path); % total distance to be covered
        time_interval = calculatetime(path_distance,desired_velocity); 
        % generate smooth time stamped trajectory
        sampletimetraj=.25; % 0.5 seconds by default
        tSamples = sampletimetraj:sampletimetraj:time_interval(2);
        [q,qd,qdd,pp] = bsplinepolytraj(path',time_interval,tSamples);
        x_ref_points = [tSamples',q(1,:)'];
        y_ref_points = [tSamples',q(2,:)'];
        trajectory.x_ref_points = x_ref_points(:,2);
        trajectory.y_ref_points = y_ref_points(:,2);
        
    else
        trajectory.x_ref_points = str2double(regexp(trajectory.x_ref_points,'[+-]?\d+\.?\d*','match'))';
        trajectory.y_ref_points = str2double(regexp(trajectory.y_ref_points,'[+-]?\d+\.?\d*','match'))';
        sampletimetraj=1;
    end
    
    trajectory = rmfield(trajectory, {'x_waypoints', 'y_waypoints'});
    times = [1:1:length(trajectory.x_ref_points)]'*sampletimetraj;
    trajectory.x_ref_points = [times trajectory.x_ref_points];
    trajectory.y_ref_points = [times trajectory.y_ref_points];
    
    % these two parameters should match with what was used when the
    % trajectories were generated. 
%    trajectory.sample_rate = 1.0; % s
%    trajectory.velocity = 1.3; % m/s
end

