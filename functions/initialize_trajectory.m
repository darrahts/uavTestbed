function [trajectory, prm] = initialize_trajectory(waypoints, velocity)
    
    num_nodes = 2000;
    conn_dist = 25;

    trajectory.waypoints = waypoints;
    trajectory.start = waypoints(1,:);
    trajectory.destination = waypoints(end,:);
    trajectory.velocity = velocity;

    map = load('trajectories/complexmap2.mat');
    map = map.complexMap;
    resolution = .1;
    radius = 2;
    map = binaryOccupancyMap(map, resolution);
    inflate(map, radius);
    prm = mobileRobotPRM('Map', map);
%     prm.Map = map;
    prm.NumNodes = num_nodes;
    prm.ConnectionDistance = conn_dist;
    
    pth = findpath(prm, waypoints(1,:), waypoints(2,:));
    for i = 3:length(waypoints(:,1))
       p = findpath(prm, waypoints(i-1,:), waypoints(i,:));
       pth = [pth; p];
    end
    
    idx = find(~any(diff(pth), 2))+1;
    pth(idx, :) = [];
    
    path_distance = calculatedistance(pth);
    time_interval = calculatetime(path_distance,velocity); 
    flight_time = time_interval(2);
    
    arr_t = zeros(length(pth),1);
    arrival_times = zeros(length(waypoints),1);
    j = 2;
    for i=1:length(pth)-1
        dist = calculatedistance(pth(i:i+1,1:2));
        t = calculatetime(dist, velocity);
        arr_t(i+1) = arr_t(i) + t(2)*1.0;
        res = find(ismember(waypoints, pth(i+1,:), 'row'));
        if length(res) > 0
            arrival_times(j) = arr_t(i+1);
            j = j + 1;
        end
    end
    clear arr_t;
    
    time_samples = 1:1:time_interval(2);
    [q,qd,qdd,pp] = bsplinepolytraj(pth',time_interval,time_samples);
    qd(3,:) = sqrt(qd(1,:).^2 + qd(2,:).^2);
    qdd(3,:) = sqrt(qdd(1,:).^2 + qdd(2,:).^2);
    x_ref_points = [time_samples' q(1,:)'];
    y_ref_points = [time_samples' q(2,:)'];
    
    trajectory.x_ref_points = x_ref_points;
    trajectory.y_ref_points = y_ref_points;
    trajectory.velocity_profile = qd;
    trajectory.acceleration_profile = qdd;
    
    trajectory.path = pth;
    trajectory.flight_time = flight_time;
    trajectory.path_distance = path_distance;
    trajectory.arrival_times = arrival_times;

    trajectory.id = 8;

end
