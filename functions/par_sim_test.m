function par_sim_test()
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics\functions';
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics\estimation';
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics\maps';
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics\params';
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics\trajectories';
    addpath 'C:\Users\darrahts\Dropbox\NASA\nextPaper\Prognostics';
    rng("shuffle");
    load 'WorkSpace.mat';
    batterytwin.R0=normrnd(rdown(1), .00025);
    batterytwin.Q=normrnd(qdown(1), .075);
    Motortwin2.Req=normrnd(mdown(1), .03);
    Motortwin4.Req=normrnd(mdown(1), .03);
    mu1 = normrnd(.5, .8);
    mu2 = normrnd(.5, .8);
    mu3 = normrnd(.5, .8);
    seed = randi(6999);
    open_system("digitaltwin1c.slx")
    sim("digitaltwin1c.slx")
    t1 = flight_time.Data(end);
%     batterytwin.v = battery_actual.Data(end, 1);
%     batterytwin.z = battery_actual.Data(end, 2);
%     batterytwin.R0 = battery_actual.Data(end, 3);
%     batterytwin.Ir = battery_actual.Data(end, 4);
%     batterytwin.h = battery_actual.Data(end, 5);
%     batterytwin.Q = battery_actual.Data(end, 6);
%     sim("digitaltwin1c.slx");
%     t2 = flight_time.Data(end);
%     total_flight_time = t2 + t1;
%     f = fopen('res.txt', 'w');
%     fprintf(f, sprintf('t1: %f\n', t1));
%     fprintf(f, sprintf('t2: %f\n', t2));
%     fprintf(f, sprintf('tot: %f\n', total_flight_time));
end

