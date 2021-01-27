function [totaldistance] = calculatedistance(waypoints)

totaldistance=0;
for i=1:length(waypoints)-1
    totaldistance=totaldistance+norm(waypoints(i+1,:)-waypoints(i,:));
end
end

