% map processing
load maps/complexmap.mat ;
Resolution=0.1; % meters
map = binaryOccupancyMap(complexMap,Resolution);
% show(map);

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
prm.NumNodes = 5000;
prm.ConnectionDistance = 20;

% path parameters
startLocation = [50 25];
endLocation = [450 50];

path = findpath(prm, startLocation, endLocation);
figure;
% show(prm);

% flight parameters
desiredvelocity=1; % m/s
totaldistancei = calculatedistance(path); % total distance to be covered
timeinterval = calculatetime(totaldistancei,desiredvelocity); 
stoptimetotal=timeinterval(2)+0.25*timeinterval(2); % time to complete the mission

% generate smooth time stamped trajectory
sampletimetraj=1; % 0.5 seconds by default
tSamples = sampletimetraj:sampletimetraj:timeinterval(2);
[q,qd,qdd,pp] = bsplinepolytraj(path',timeinterval,tSamples);
XrefTot=[tSamples',q(1,:)'];
YrefTot=[tSamples',q(2,:)'];
