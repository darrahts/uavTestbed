load trajectories/longPath.mat
load trajectories/longPathPoints.mat
load trajectories/waypoints.mat
load map.mat
sampletimetraj=1; % seconds by default
desiredvelocity=1.3; % 1 m/s

IC.X=longPath(1,1);
IC.Y=longPath(1,2);
IC.state(1)=longPath(1,1);
IC.state(2)=longPath(1,2);
%stoptimetotal=1.0047e3;
stoptimetotal= 1900;