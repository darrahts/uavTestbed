function airframe = get_airframe(conn, uav_sern)
    airframe_tb = sqlread(conn, 'uav_tb');
    airframe_tb = airframe_tb(strcmp(airframe_tb.serial_number, uav_sern),:);
    airframe = table2struct(airframe_tb);
    clear airframe_tb;
end

