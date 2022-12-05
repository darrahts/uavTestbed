% stop measure on the simulation, in general it should stop before this
sim_params.max_sim_time = 4000;

% performance thresholds %%%% max_pos_err calculation is incorrect (does
% not account for time offset, needs updated)
sim_params.perf_param_thresh.max_pos_err  = 10; % this is check in the simulation
sim_params.perf_param_thresh.min_soc      = .2; % this is check in the simulation
sim_params.perf_param_thresh.min_v        = uav.battery.EOD * 1.1; % this is checked in the simulation
sim_params.perf_param_thresh.min_soh_batt = uav.battery.Q * .6; % this is checked after %% can this even be done?
sim_params.perf_param_thresh.avg_pos_err  = 2.8; % this is checked after
sim_params.perf_param_thresh.pos_err_var  = 10; % check this 

% controller and filter estimation parameters, initial conditions for the UAV
sim_params.controllers         = load('params/controllers.mat').controllers;
sim_params.initial_conditions  = load('params/IC_HoverAt10ftOcto.mat').IC;

sim_params.battery_estimator   = load('estimation/batteryestimator').batteryestimator;
sim_params.battery_estimator.Qinit = uav.battery.Q;
if uav.battery.v0 < 4.3
    sim_params.battery_estimator.soc_ocv = interp1([sim_params.battery_estimator.soc_ocv(1) sim_params.battery_estimator.soc_ocv(end)], [3.04 4.2], sim_params.battery_estimator.soc_ocv);
end

if strcmp(uav.uav.common_name, 'default')
    sim_params.position_estimator  = load('estimation/positionestimator').PositionEstimator;
    sim_params.motor_estimator     = load('estimation/MotorEstimator').MotorEstimator;
end

sim_params.initial_conditions.X = 50; %trajectory.start(1);
sim_params.initial_conditions.Y = 25; %trajectory.start(2);