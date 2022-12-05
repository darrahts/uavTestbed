
execute(conn, eval(api.matlab.components.UPDATE_BATTERY_PARAMETERS));
for i = 1:length(uav.motors)
    execute(conn, eval(api.matlab.components.UPDATE_MOTOR_PARAMETERS));
end
