function battery = get_battery(conn, battery_sern)
    
    battery_tb = sqlread(conn, 'eqc_battery_tb');
    battery_tb = battery_tb(strcmp(battery_tb.serial_number, battery_sern), :);
    battery = table2struct(battery_tb);
    battery.soc_ocv = load('params/soc_ocv.mat').soc_ocv;
    battery.dt = double(battery.dt);
    clear battery_tb;
    
end

