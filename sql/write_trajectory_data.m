function write_trajectory_data(conn, start, path_distance, path_time, waypoints)
%%
%
%       TODO: function comments
%
%       
%
%%
    start = convert_for_insert(start);
    destination = convert_for_insert(waypoints(end,:));
    x_waypoints = convert_for_insert([waypoints(:,1)']);
    y_waypoints = convert_for_insert([waypoints(:,2)']);
    % x_points = convert_for_insert(round(x_ref_points(:,2), 2));
    % y_points = convert_for_insert(round(y_ref_points(:,2), 2));
    % trajectory_tb_cols = {'path_distance', 'path_time', 'start', 'destination', 'x_waypoints', 'y_waypoints', 'x_ref_points', 'y_ref_points'};
    % trajectory_tb = table(path_distance, ...
    %                     path_time, ...
    %                     start, ...
    %                     destination, ...
    %                     x_waypoints, ...
    %                     y_waypoints, ...
    %                     x_points, ...
    %                     y_points, ...
    %                     'VariableNames', trajectory_tb_cols)

    % DOES NOT WORK - gives malformed literal error, could be due to the double
    % qotes vs single quotes that postgres wants
    %sqlwrite(conn, 'trajectory_tb', trajectory_tb);

    %qer = sprintf("insert into trajectory_tb (path_distance, path_time, x_waypoints, y_waypoints, x_ref_points, y_ref_points) values (%.2f, %.2f, '%s', '%s', '%s', '%s');", path_distance, path_time, x_waypoints, y_waypoints, x_points, y_points)
    qer = sprintf("insert into trajectory_tb (path_distance, path_time, start, destination, x_waypoints, y_waypoints) values (%.2f, %.2f, '%s', '%s', '%s', '%s');", path_distance, path_time, start, destination, x_waypoints, y_waypoints);
    execute(conn, qer);
    
end

