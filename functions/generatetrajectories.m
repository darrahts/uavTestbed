
% map processing
load maps/complexmap.mat ;
Resolution=0.1; % meters
map = binaryOccupancyMap(complexMap,Resolution);
show(map);


% robot parameters
robotRadius = 0.5;

% inflate map
mapInflated = copy(map);
inflate(mapInflated,robotRadius);
show(mapInflated);



% construct PRM
prm = mobileRobotPRM;
prm.Map = mapInflated;

% prm parameters
prm.NumNodes = 1000;
prm.ConnectionDistance = 50;

% path parameters
startLocation = [50 25];
endLocation = [450 200];
endendloc = [40 10];
p1
p2
p3

path1 = findpath(prm, startLocation, endLocation);
path2 = findpath(prm, endLocation, endendloc);
path = [path1; path2];
figure;
show(prm);



% flight parameters
desiredvelocity=1.3; % m/s
totaldistancei = calculatedistance(path); % total distance to be covered
timeinterval = calculatetime(totaldistancei,desiredvelocity); 
stoptimetotal=timeinterval(2)+0.25*timeinterval(2); % time to complete the mission

% generate smooth time stamped trajectory
sampletimetraj=1; % 0.5 seconds by default
tSamples = sampletimetraj:sampletimetraj:timeinterval(2);
[q,qd,qdd,pp] = bsplinepolytraj(path',timeinterval,tSamples);
XrefTot=[tSamples',q(1,:)'];
YrefTot=[tSamples',q(2,:)'];

path2stamped.XrefTot = XrefTot;
path2stamped.YrefTot = YrefTot;
save('path2stamped.mat', 'XrefTot', "YrefTot");
path2 = [q(1,:) ;q(2,:)]';
save('path2.mat', 'path');