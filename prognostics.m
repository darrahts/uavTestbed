%% load parameters
% model parameters
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

%% define set of trajectory scenarios
load trajectories/path1.mat
load trajectories/path1stamped.mat
sampletimetraj=1; % seconds by default
desiredvelocity=1; % 1 m/s
IC.X=path(1,1);
IC.Y=path(1,2);
IC.state(1)=path(1,1);
IC.state(2)=path(1,2);
destination=path(end,:);
stoptimetotal=1.0047e3;

%% run battery degradation experiment
load_system('truesystem');
load_system('digitaltwin');
set_param('truesystem','FastRestart','on');
set_param('digitaltwin','FastRestart','on');
R0degradation=[0.0011 0.03]; % min and max, increases with degradation
Qdegradation=[15 10]; % max and min, decreases with degradation
RMotordegradation=[0.2371 1.2]; % min and max, increases with degradation
for i=1:length(R0degradation)
    R0i=R0degradation(i);
    Qi=Qdegradation(i);
    RMotori=RMotordegradation(i);
    battery.R0=R0i;
    battery.Q=Qi;
    Motor2.Req=RMotori;
    sim('truesystem');
    
    % assess success
    if (arrived.Data(end,1)==0 || trackingerror.Data(end,1)==1 || lowsoc.Data(end,1)==1)
        % unsuccessful mission
        missionfailure=true;
        break;
    else
        missionfailure=false;
    end
    
    % track parameters, R0, re-initialize UKF
    ukfBatteryParams.R0init=R0param.Data(end,1);
    ukfBatteryParams.Qinit=Qparam.Data(end,1);
    resmot2=resistancemotor2.Data;
    MotorEstimator.Rinit=mean(resmot2);
    
    %%  predict next mission
    batterytwin.R0=R0param.Data(end,1);
    batterytwin.Q=Qparam.Data(end,1);
    Motortwin2.Req=mean(resmot2);
    sim('digitaltwin');
    
    % check complete mission in time
    if arrivedprediction.Data(end,1)==0
        predictiontimetocomplete=true;
        break;
    else
        predictiontimetocomplete=false;
    end
    
    % check tracking accuracy
    if trackingerror.Data(end,1)==1
        predictioncrash=true;
        break;
    else
        predictioncrash=false;
    end
    
    % check battery performance
     if lowsoc.Data(end,1)==1
        predictionlowsoc=true;
        break;
     else
         predictionlowsoc=false;
    end
end

set_param('truesystem','FastRestart','off');
set_param('digitaltwin','FastRestart','off');
%% show map with reference and resulting trajectory
% 2 D comparison
timeest=estimations.Time;
estimatedpos=estimations.Data;
figure1 = figure;
hold on;
scatter(XrefTot(:,2),YrefTot(:,2));
scatter(estimatedpos(:,1),estimatedpos(:,2));

% trajectory error
figure12 = figure;
hold on;
xerror=XrefTot(:,2)-estimatedpos(1:end-(length(estimatedpos(:,1))-length(XrefTot(:,2))),1);
yerror=YrefTot(:,2)-estimatedpos(1:end-(length(estimatedpos(:,1))-length(XrefTot(:,2))),2);
plot(xerror);
plot(yerror);

% single variable comparison
figure13 = figure;
timev=reals.Time;
variables=reals.Data;
timeest=estimations.Time;
estimated=estimations.Data;
matrices=bounds.Data(:,:,:);
limits=[];
for i=1:length(matrices)
    limits(:,i)=3*sqrt(diag(matrices(:,:,i)));
end
subplot(2,1,1);
plot(timev,variables(:,1),'k');
hold on;
plot(timev,estimated(:,1),'r');
plot(timev,estimated(:,1)+limits(1,:)','b-');
plot(timev,estimated(:,1)-limits(1,:)','b-');

%% show soc and voltage across the trajectory
timevol=voltage.Time;
estimatedvol=voltage.Data;
timesoc=soc.Time;
estimatedsoc=soc.Data;
figure2 = figure;
plot(timevol,estimatedvol(:,3));
figure3 = figure;
plot(timesoc,estimatedsoc(:,2));

