function load_parallel_workspace(i, lookback, horizon, r_var, q_var, m_var, s_rate)
    evalin('base', 'seed = randi(9999)');
    evalin('base', 'rng(seed)');
    evalin('base', 'addpath(genpath(pwd))');
    evalin('base', 'load_fresh_workspace');
    evalin('base', 'load_trajectory');
    evalin('base', sprintf('octomodel.sampletime = %f', s_rate));
        
    if i > lookback
        % fit a polonomial to determine the rate of change of the degradation parameters 
        evalin('base', sprintf('x = ((%d-(%d-1)):1:%d)', i, lookback, i));
        evalin('base', sprintf("r_poly = polyfit(x, smoothdata(r_deg((%d-(%d-1)):%d)', 'rlowess', 5), 1)", i, lookback, i));
        evalin('base', sprintf("q_poly = polyfit(x, smoothdata(q_deg((%d-(%d-1)):%d)', 'rlowess', 5), 1)", i, lookback, i));
        evalin('base', sprintf("m_poly = polyfit(x, smoothdata(m_deg((%d-(%d-1)):%d)', 'rlowess', 5), 1)", i, lookback, i));
        % keep track of deltas 
        evalin('base', "polys(1,:) = r_poly");
        evalin('base', "polys(2,:) = q_poly");
        evalin('base', "polys(3,:) = m_poly");
        
        % predict degradation value at the horizon
        evalin('base', sprintf("ROi = polyval(r_poly, %d+%d)", i, horizon));
        evalin('base', sprintf("Qi = polyval(q_poly, %d+%d)", i, horizon));
        evalin('base', sprintf("RMi = polyval(m_poly, %d+%d)", i, horizon));
        
        evalin('base', "batterytwin.R0 = R0i");
        evalin('base', "batterytwin.Q = Qi");
        evalin('base', "Motortwin2.Req = RMi");
        
        evalin('base', sprintf('save_deg_info(%d, polys, R0i, Qi, RMi)', i));
        
    else
        evalin('base', sprintf('batterytwin.R0=max(abs(normrnd(rdeg(%d), %f)), .0001)', i, r_var));
        evalin('base', sprintf('batterytwin.Q=min(abs(normrnd(qdeg(%d), %f)), 15.5)', i, q_var));
        evalin('base', sprintf('Motortwin2.Req=abs(normrnd(mdeg(%d), %f))', i, m_var));
    end
end

