
execute(conn, eval(api.matlab.assets.UPDATE_BATTERY_AGE));
execute(conn, eval(api.matlab.assets.UPDATE_UAV_AGE));
for i = 1:length(uav.motors)
    execute(conn, eval(api.matlab.assets.UPDATE_MOTOR_AGE))
end

clear('charge', 'avg_current', 'charge_time', 'amp_hours', 'Q_mu', 'Q_std', 'R0_mu', 'R0_std', 'm_mu', 'm_std', 'u', 'flight_time');


