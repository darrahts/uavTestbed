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