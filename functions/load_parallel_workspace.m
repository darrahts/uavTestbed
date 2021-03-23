
seed = randi(9999);
rng(seed);
addpath(genpath(pwd));
conn = database('uavtestbed2', 'postgres', get_password('#4KRx39Dn@09'));
load_trajectory;

% load UAV airframe
uav_sern = 'X001';
octomodel = get_airframe(conn, uav_sern);

% load battery
battery_sern = 'B001';
batterytwin = get_battery(conn, battery_sern);

% load motors
[Motortwin1, Motortwin2, Motortwin3, Motortwin4, Motortwin5, Motortwin6, Motortwin7, Motortwin8] = get_motors(conn, octomodel.id);

IC= load('params/IC_HoverAt10ftOcto.mat').IC;

% normal degradation
load 'params/mdeg.mat';
load 'params/rdeg.mat';
load 'params/qdeg.mat';

IC.X = 50;
IC.Y = 25;
IC.Z = 3;

warning('off');

posNoise = [.15 .15];
mu_wind = normrnd(.5, .8);

batterytwin.R0 = max(abs(normrnd(rdeg(i), r_var)), .0001);
batterytwin.Q = min(abs(normrnd(qdeg(i), q_var)), 15.5);
Motortwin2.Req = abs(normrnd(mdeg(i), m_var));

