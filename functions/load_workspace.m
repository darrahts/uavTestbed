function load_workspace()
    %load 'WorkSpace_base.mat';
    evalin('base', 'rng("shuffle")');
    evalin('base', 'load WorkSpace.mat');
    evalin('base', 'batterytwin.R0=normrnd(rdown(1), .00025)');
    evalin('base', 'batterytwin.Q=normrnd(qdown(1), .075)');
    evalin('base', 'Motortwin2.Req=normrnd(mdown(1), .03)');
    evalin('base', 'Motortwin4.Req=normrnd(mdown(1), .03)');
    evalin('base', 'mu1 = normrnd(.5, .8)');
    evalin('base', 'mu2 = normrnd(.5, .8)');
    evalin('base', 'mu3 = normrnd(.5, .8)');
    evalin('base', 'seed = randi(6999)');
end

