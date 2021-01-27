function [y] = positionMeasTransitionFunction(x)

V=[1,1,1,1,1,1];
H=[diag(V),zeros(6,3)];
y = H*x;
end

