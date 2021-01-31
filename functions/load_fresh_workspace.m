battery=load('params/battery.mat').battery;
batterytwin=load('params/batterytwin.mat').batterytwin;
controllers=load('params/controllers.mat').controllers;
Motor1=load('params/Motors/Motor1.mat').Motor;
Motor2=load('params/Motors/Motor2.mat').Motor;
Motor3=load('params/Motors/Motor3.mat').Motor;
Motor4=load('params/Motors/Motor4.mat').Motor;
Motor5=load('params/Motors/Motor5.mat').Motor;
Motor6=load('params/Motors/Motor6.mat').Motor;
Motor7=load('params/Motors/Motor7.mat').Motor;
Motor8=load('params/Motors/Motor8.mat').Motor;
Motortwin1=load('params/Motors/Motor1.mat').Motor;
Motortwin2=load('params/Motors/Motor2.mat').Motor;
Motortwin3=load('params/Motors/Motor3.mat').Motor;
Motortwin4=load('params/Motors/Motor4.mat').Motor;
Motortwin5=load('params/Motors/Motor5.mat').Motor;
Motortwin6=load('params/Motors/Motor6.mat').Motor;
Motortwin7=load('params/Motors/Motor7.mat').Motor;
Motortwin8=load('params/Motors/Motor8.mat').Motor;
IC= load('params/IC_HoverAt10ftOcto.mat').IC;
octomodel=load('params/octoModel.mat').octomodel;

% state estimators
load('positionestimator');
load('ukfBatteryParams');
load('MotorEstimator');

% accelerated degradation
% load 'params/mdown.mat';
% load 'params/rdown.mat';
% load 'params/qdown.mat';

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
