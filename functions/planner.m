function trajectory = planner(waypoints, velocity)
   
    map = load('trajectories/complexmap2.mat');
    map = map.complexMap;
    resolution = .1;
    radius = 2;
    map = binaryOccupancyMap(map, resolution);
    prm = mobileRobotPRM;
    prm.Map = map;
    prm.NumNodes = 2000;
    prm.ConnectionDistance = 25;

    path = findpath(prm, waypoints(1,:), waypoints(2,:));
    for i = 3:length(waypoints(:,1))
       p = findpath(prm, waypoints(i-1,:), waypoints(i,:));
       path = [path; p];
    end
    
    path_distance = calculatedistance(path);
    time_interval = calculatetime(path_distance,velocity); 
    flight_time = time_interval(2);

    arrival_times = zeros(length(path),1);
    for i=1:length(path)-1
        dist = calculatedistance(path(i:i+1,1:2));
        t = calculatetime(dist, velocity);
        arrival_times(i+1) = arrival_times(i) + t(2)*1.0;
    end

    time_samples = 1:1:time_interval(2);
    [q,qd,qdd,pp] = bsplinepolytraj(path',time_interval,time_samples);
    qd(3,:) = sqrt(qd(1,:).^2 + qd(2,:).^2);
    qdd(3,:) = sqrt(qdd(1,:).^2 + qdd(2,:).^2);
    x_ref_points = [time_samples' q(1,:)'];
    y_ref_points = [time_samples' q(2,:)'];

    trajectory.x_ref_points = x_ref_points;
    trajectory.y_ref_points = y_ref_points;
    trajectory.velocity_profile = qd;
    trajectory.acceleration_profile = qdd;
    trajectory.waypoints = waypoints;
    trajectory.path = path;
    trajectory.flight_time = flight_time;
    trajectory.path_distance = path_distance;
    trajectory.arrival_times = arrival_times;
end

