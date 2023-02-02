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

    % trajectory.destination = str2double(regexp(trajectory.destination,'[+-]?\d+\.?\d*','match'));
    % trajectory.destination = [trajectory.destination];
    trajectory.destination = trajectory.start;
    trajectory.sample_time = 1;
    if sum(strcmp(fieldnames(trajectory), 'path')) == 0
        map = load(sprintf('trajectories/%s.mat', trajectory.map)).map;
        inflate(map, 2);
        prm = mobileRobotPRM;
        prm.Map = map;
        prm.NumNodes = 8000;
        prm.ConnectionDistance = 25;

        trajectory.path = findpath(prm, trajectory.start, trajectory.waypoints(1,:));
        for i = 2:length(trajectory.waypoints(:,1))
           p = findpath(prm, trajectory.waypoints(i-1,:), trajectory.waypoints(i,:));
           trajectory.path = [trajectory.path; p];
        end
        p = findpath(prm, trajectory.waypoints(i,:), trajectory.destination);
        trajectory.path = [trajectory.path; p];
    end

    if isempty(trajectory.x_ref_points) | isnan(trajectory.x_ref_points)
        trajectory.velocity = max(2.1, min(2.9, normrnd(2.45, .15)));        
        trajectory.path_distance = calculatedistance(trajectory.path); % total distance to be covered
        time_interval = calculatetime(trajectory.path_distance,trajectory.velocity); 
        trajectory.flight_time = time_interval(2)/60;
        time_samples = 1:trajectory.sample_time:time_interval(2);
        [q, qd, qdd, pp] = bsplinepolytraj(trajectory.path', time_interval, time_samples);
        qd(3,:) = sqrt(qd(1,:).^2 + qd(2,:).^2);
        qdd(3,:) = sqrt(qdd(1,:).^2 + qdd(2,:).^2);

        trajectory.x_ref_points = [time_samples' q(1,:)'];
        trajectory.y_ref_points = [time_samples' q(2,:)'];
        trajectory.velocity_profile = qd;
        trajectory.acceleration_profile = qdd;


        arr_t = zeros(length(trajectory.path),1);
        arrival_times = zeros(length(trajectory.waypoints),1);
        j = 2;
        for i=1:length(trajectory.path)-1
            dist = calculatedistance(trajectory.path(i:i+1,1:2));
            t = calculatetime(dist, trajectory.velocity);
            arr_t(i+1) = arr_t(i) + t(2)*1.0;
            res = find(ismember(trajectory.waypoints, trajectory.path(i+1,:), 'row'));
            if length(res) > 0
                arrival_times(j) = arr_t(i+1);
                j = j + 1;
            end
        end
        clear arr_t;
        
        trajectory.arrival_times = arrival_times;

    else
        time_samples = [1:trajectory.sample_time:trajectory.path_time*60]';
        trajectory.x_ref_points = str2double(regexp(trajectory.x_ref_points,'[+-]?\d+\.?\d*','match'))';
        trajectory.y_ref_points = str2double(regexp(trajectory.y_ref_points,'[+-]?\d+\.?\d*','match'))';
        trajectory.x_ref_points = [time_samples trajectory.x_ref_points];
        trajectory.y_ref_points = [time_samples trajectory.y_ref_points];
    end
    trajectory = rmfield(trajectory, {'x_waypoints', 'y_waypoints'});
    %trajectory.waypoints = [trajectory.start; trajectory.waypoints; trajectory.destination];
end

