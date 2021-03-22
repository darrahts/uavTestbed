function airframe = get_airframe(conn, uav_sern)
    airframe_tb = sqlread(conn, 'uav_tb');
    airframe_tb = airframe_tb(strcmp(airframe_tb.serial_number, uav_sern),:);
    airframe = table2struct(airframe_tb);
    airframe.Jb = reshape(str2num(airframe.Jb(2:end-1)), [3,3]);
    airframe.Jbinv = reshape(str2num(airframe.Jbinv(2:end-1)), [3,3]);
    clear airframe_tb;
end

