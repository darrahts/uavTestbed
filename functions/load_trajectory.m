%load trajectories/short1/path.mat
%load trajectories/short1/path_points.mat
%load trajectories/short1/waypoints.mat
trajectory = get_trajectory('trajectories.csv', rul_hat);

sampletimetraj=1; % seconds by default
desiredvelocity=1.3; % 1 m/s

if ~isempty(trajectory)
    % initial conditions
    IC.X=trajectory.x_ref_points(1,2);
    IC.Y=trajectory.y_ref_points(1,2);
    IC.state(1)=trajectory.x_ref_points(1,2);
    IC.state(2)=trajectory.y_ref_points(1,2);
else
    end_sim = 1;
end

