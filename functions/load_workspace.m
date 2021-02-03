function load_workspace(i, r_var, q_var, m_var)
    %load 'WorkSpace_base.mat';
    evalin('base', 'rng("shuffle")');
    evalin('base', 'seed = randi(9999)');
    evalin('base', 'load parallel_workspace.mat');
    evalin('base', sprintf('batterytwin.R0=normrnd(rdeg(i), %f)', r_var));
    evalin('base', sprintf('batterytwin.Q=normrnd(qdeg(i), %f)', q_var));
    evalin('base', sprintf('Motortwin2.Req=normrnd(mdeg(i), %f)', m_var));
%     evalin('base', sprintf('Motortwin4.Req=normrnd(mdeg(1), %f)', m_var));
%     evalin('base', sprintf('Motortwin5.Req=normrnd(mdeg(1), %f)', m_var));
    
end

