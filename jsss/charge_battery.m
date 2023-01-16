
u = -22; %-uav.battery.Q;  % Q degrades but u should remain the factory value of 22 for the case of the tarot
charge = sim('continuous_battery.slx');
uav.battery.v = charge.battery_state_params.v.Data(end);
uav.battery.z = charge.battery_state_params.z.Data(end);
avg_current = abs(mean(charge.u.Data));
charge_time = charge.time.Data(end)/3600; % this is in seconds
amp_hours = avg_current * charge_time;
charge_discount = .9;
uav.battery.age = uav.battery.age + (amp_hours * charge_discount);

Q_mu = polyval(uav.battery.q_coef, uav.battery.age);
Q_std = .02*Q_mu;

R0_mu = polyval(uav.battery.r_coef, uav.battery.age);
R0_std = .02*R0_mu;

uav.battery.Q = normrnd(Q_mu, Q_std);
uav.battery.R0 = normrnd(R0_mu, R0_std);

uav.battery.Q = min(22.5, uav.battery.Q);
uav.battery.R0 = max(.00105, uav.battery.R0);

%the battery never charges to the same output voltage level
uav.battery.v = pearsrnd(uav.battery.v-.25, uav.battery.v*.01, -1, 12);
uav.battery.z = min(1.01, pearsrnd(uav.battery.z-.0025, uav.battery.z*.01, -1, 12));