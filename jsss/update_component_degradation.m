
avg_current = abs(mean(battery.battery_true.i.Data(:)));
flight_time = time.Data(end)/60; % this is in minutes
amp_hours = avg_current * flight_time;
uav.battery.age = uav.battery.age + amp_hours;

%[TODO] implement estimators and pull covariance 
Q_mu = polyval(uav.battery.q_coef, uav.battery.age);
Q_std = .02*Q_mu;

R0_mu = polyval(uav.battery.r_coef, uav.battery.age);
R0_std = .02*R0_mu;

uav.battery.Q = normrnd(Q_mu, Q_std);
uav.battery.R0 = normrnd(R0_mu, R0_std);

uav.battery.Q = min(22.5, uav.battery.Q);
uav.battery.R0 = max(.00105, uav.battery.R0);

for i = 1:length(uav.motors)
    avg_current = abs(mean(motors.(sprintf('m%d',i)).current.Data(:)));
    uav.motors(i).age = uav.motors(i).age + avg_current * flight_time;
    m_mu = polyval(uav.motors(i).r_coef, uav.motors(i).age);
    m_std = .02*m_mu;
    uav.motors(i).Req = normrnd(m_mu, m_std);
    
    % min bound on motor resistance
    uav.motors(i).Req = max(.265, uav.motors(i).Req) + normrnd(.002, .001);
    if uav.motors(i).age < 200 
        uav.motors(i).Req = min(.28, uav.motors(i).Req) + normrnd(.002, .003);

    elseif uav.motors(i).age >= 200 && uav.motors(i).age < 300
        uav.motors(i).Req = min(.295, uav.motors(i).Req) + normrnd(.002, .003);

    elseif uav.motors(i).age >= 300 && uav.motors(i).age < 400
        uav.motors(i).Req = min(.31, uav.motors(i).Req) + normrnd(.002, .001);
    end
end

uav.uav.age = uav.uav.age +  trajectory.flight_time;
uav.uav.total_distance = uav.uav.total_distance + trajectory.path_distance;
uav.uav.total_flight_time = uav.uav.total_flight_time + trajectory.flight_time;