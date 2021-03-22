

conn = database('uavtestbed2', 'postgres', get_password('#4KRx39Dn@09'));

%% load UAV airframe
uav_sern = 'X001';
octomodel = get_airframe(conn, uav_sern);

%% load battery
battery_sern = 'B001';
battery = get_battery(conn, battery_sern);

%% load motors
[Motor1, Motor2, Motor3, Motor4, Motor5, Motor6, Motor7, Motor8] = get_motors(conn, octomodel.id);


%% load rest of simulation parameters

IC= load('params/IC_HoverAt10ftOcto.mat').IC;
%octomodel=load('params/octoModel.mat').octomodel;

controllers=load('params/controllers.mat').controllers;

% state estimators
load('positionestimator');
load('ukfBatteryParams');
load('MotorEstimator');

% normal degradation
load 'params/mdeg.mat';
load 'params/rdeg.mat';
load 'params/qdeg.mat';

IC.X = 50;
IC.Y = 25;
IC.Z = 3;

warning('off');

octomodel.sampletime = .01;
twin_sample_rate = .05;
true_sample_rate = .025;

posNoise = [.15 .15];
mu_wind = normrnd(.5, .8);


