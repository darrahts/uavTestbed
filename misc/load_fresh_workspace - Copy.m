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

load 'params/mdown.mat';
load 'params/rdown.mat';
load 'params/qdown.mat';

IC.X = 50;
IC.Y = 25;
IC.Z = 3;

warning('off');
load trajectories/path2.mat
load trajectories/path2stamped.mat
sampletimetraj=1; % seconds by default
desiredvelocity=1.3; % 1 m/s

IC.X=path(1,1);
IC.Y=path(1,2);
IC.state(1)=path(1,1);
IC.state(2)=path(1,2);
destination=path(end,:);
%stoptimetotal=1.0047e3;
stoptimetotal= 1900;

octomodel.sampletime = .01;