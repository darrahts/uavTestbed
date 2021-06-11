function trajectory = get_trajectory(file_name, max_flight_time)

    %trajectory_tb = sqlread(conn, 'trajectory_tb');
    trajectory_tb = readtable(file_name);
    
    if rand > 1.0
        flight_duration = max_flight_time + 3;
        limit = 2;
    else
        flight_duration = max_flight_time;
        limit = 1;
    end
    trajectory_tb = trajectory_tb(trajectory_tb.path_time < flight_duration, :);
    trajectory_tb = sortrows(trajectory_tb, "path_time", 'descend');
    % randomly select one of the top <limit> missions, or the first
    if height(trajectory_tb) < 1
        disp("[INFO] returning empty table")
        trajectory = table();
        return;
    elseif height(trajectory_tb) > limit
        idx = randi(limit,1);
    else
        idx = 1;
    end
    
    trajectory = table2struct(trajectory_tb(idx,:));
    trajectory.x_waypoints = str2double(regexp(trajectory.x_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.y_waypoints = str2double(regexp(trajectory.y_waypoints,'[+-]?\d+\.?\d*','match'));
    trajectory.waypoints = [trajectory.x_waypoints' trajectory.y_waypoints'];
    trajectory.x_ref_points = str2double(regexp(trajectory.x_ref_points,'[+-]?\d+\.?\d*','match'))';
    trajectory.y_ref_points = str2double(regexp(trajectory.y_ref_points,'[+-]?\d+\.?\d*','match'))';
    trajectory = rmfield(trajectory, {'x_waypoints', 'y_waypoints'});
    times = [1:1:length(trajectory.x_ref_points)]';
    trajectory.x_ref_points = [times trajectory.x_ref_points];
    trajectory.y_ref_points = [times trajectory.y_ref_points];
    clear('trajectory_tb', 'times', 'idx');
end

