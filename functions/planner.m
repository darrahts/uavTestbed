function [ref_points, x_ref_points, y_ref_points] = planner(prm, waypoints, velocity)

    prm = trajectory.prm;
    pth = findpath(prm, waypoints(1,:), waypoints(2,:));
    for i = 3:length(waypoints(:,1))
       p = findpath(prm, waypoints(i-1,:), waypoints(i,:));
       pth = [pth; p];
    end
    
    path_distance = calculatedistance(pth);
    time_interval = calculatetime(path_distance,velocity); 

    time_samples = 1:1:time_interval(2);
    [q,~,~,~] = bsplinepolytraj(pth',time_interval,time_samples);
    x_ref_points = [time_samples' q(1,:)'];
    y_ref_points = [time_samples' q(2,:)'];
    ref_points = [q(1,:)' q(2,:)'];

end

