function trajectory = get_trajectory(trajectory_tb, idx)
%%
%
%       TODO: function comments
%
%       
%
%%
    trajectory = table2struct(trajectory_tb(idx,:));
    trajectory.x_waypoints = str2double(regexp(trajectory.x_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.y_waypoints = str2double(regexp(trajectory.y_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.waypoints = [trajectory.x_waypoints' trajectory.y_waypoints'];
    trajectory.start = str2double(regexp(trajectory.start,'[+-]?\d+\.?\d*','match'));
    trajectory.start = [trajectory.start];

    trajectory.destination = str2double(regexp(trajectory.destination,'[+-]?\d+\.?\d*','match'));
    trajectory.destination = [trajectory.destination];
    
    if sum(strcmp(fieldnames(trajectory), 'path')) == 0
        map = load(sprintf('trajectories/%s.mat', trajectory.map)).(sprintf('%s', trajectory.map));
        prm = mobileRobotPRM;
        prm.Map = map;
        prm.NumNodes = 1000;
        prm.ConnectionDistance = 50;

        trajectory.path = findpath(prm, trajectory.start, trajectory.waypoints(1,:));
        for i = 2:length(trajectory.waypoints(:,1))
           p = findpath(prm, trajectory.waypoints(i-1,:), trajectory.waypoints(i,:));
           trajectory.path = [trajectory.path; p];
        end
    end

    if isempty(trajectory.x_ref_points) | isnan(trajectory.x_ref_points)
        trajectory.reference_velocity = 1.0;        
        trajectory.path_distance = calculatedistance(trajectory.path); % total distance to be covered
        time_interval = calculatetime(trajectory.path_distance,trajectory.reference_velocity); 
        trajectory.path_time = time_interval(2)/60;
        time_samples = 1:trajectory.sample_time:time_interval(2);
        [q, qd, qdd, pp] = bsplinepolytraj(trajectory.path', time_interval, time_samples);

        trajectory.x_ref_points = [time_samples' q(1,:)'];
        trajectory.y_ref_points = [time_samples' q(2,:)'];
    else
        time_samples = [1:trajectory.sample_time:trajectory.path_time*60]';
        trajectory.x_ref_points = str2double(regexp(trajectory.x_ref_points,'[+-]?\d+\.?\d*','match'))';
        trajectory.y_ref_points = str2double(regexp(trajectory.y_ref_points,'[+-]?\d+\.?\d*','match'))';
        trajectory.x_ref_points = [time_samples trajectory.x_ref_points];
        trajectory.y_ref_points = [time_samples trajectory.y_ref_points];
    end
    trajectory = rmfield(trajectory, {'x_waypoints', 'y_waypoints'});

end

