function load_workspace(i, r_var, q_var, m_var, s_rate)
    evalin('base', 'seed = randi(9999)');
    evalin('base', 'rng(seed)');
    evalin('base', 'load parallel_workspace.mat');
    evalin('base', sprintf('octomodel.sampletime = %f', s_rate));
    evalin('base', sprintf('batterytwin.R0=max(abs(normrnd(rdeg(%d), %f)), .0001)', i, r_var));
    evalin('base', sprintf('batterytwin.Q=min(abs(normrnd(qdeg(%d), %f)), 15.5)', i, q_var));
    evalin('base', sprintf('Motortwin2.Req=abs(normrnd(mdeg(%d), %f))', i, m_var));
    
end

