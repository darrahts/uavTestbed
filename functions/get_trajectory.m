function trajectory = get_trajectory(file_name, max_flight_time)
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
        trajectory = table2struct(trajectory_tb(1,:));
    end
    
    trajectory.x_waypoints = str2double(regexp(trajectory.x_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.y_waypoints = str2double(regexp(trajectory.y_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.waypoints = [trajectory.x_waypoints' trajectory.y_waypoints'];
    trajectory.x_ref_points = str2double(regexp(trajectory.x_ref_points,'[+-]?\d+\.?\d*','match'))';
    trajectory.y_ref_points = str2double(regexp(trajectory.y_ref_points,'[+-]?\d+\.?\d*','match'))';
    trajectory = rmfield(trajectory, {'x_waypoints', 'y_waypoints'});
    times = [1:1:length(trajectory.x_ref_points)]';
    trajectory.x_ref_points = [times trajectory.x_ref_points];
    trajectory.y_ref_points = [times trajectory.y_ref_points];
    
    % these two parameters should match with what was used when the
    % trajectories were generated. 
%    trajectory.sample_rate = 1.0; % s
%    trajectory.velocity = 1.3; % m/s
end

