function [m1, m2, m3, m4, m5, m6, m7, m8] = get_motors(conn, uav_id)

    motors_tb = sqlread(conn, 'eq_motor_tb');
    motors_tb = motors_tb(motors_tb.uav_id == uav_id, :);
    m1 = table2struct(motors_tb(1,:));
    m2 = table2struct(motors_tb(2,:));
    m3 = table2struct(motors_tb(3,:));
    m4 = table2struct(motors_tb(4,:));
    m5 = table2struct(motors_tb(5,:));
    m6 = table2struct(motors_tb(6,:));
    m7 = table2struct(motors_tb(7,:));
    m8 = table2struct(motors_tb(8,:));
    clear motors_tb;
end

