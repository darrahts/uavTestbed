

controllers=load('params/controllers.mat').controllers;

% load rest of simulation parameters
IC= load('params/IC_HoverAt10ftOcto.mat').IC;

% state estimators
load('positionestimator');
load('ukfBatteryParams');
load('MotorEstimator');

% normal degradation
load 'params/mdeg.mat';
load 'params/rdeg.mat';
load 'params/qdeg.mat';

warning('off');

octomodel.sampletime = .01;
twin_sample_rate = .05;
true_sample_rate = .025;

pos_err_threshold = 5.5;
min_soc = .3;

stoptimetotal = 2200;

posNoise = [.0125 .0125];
mu_wind = normrnd(.125, .125);
