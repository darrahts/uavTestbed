function parallel_initializer_handler(i, lookback, horizon, r_var, q_var, m_var, s_rate)
    % load the simulation parameters to the parallel workspaces
    evalin('base', sprintf('i=%d;', i));
    evalin('base', sprintf('lookback=%d;', lookback));
    evalin('base', sprintf('horizon=%d;', horizon));
    evalin('base', sprintf('r_var=%f;', r_var));
    evalin('base', sprintf('q_var=%f;', q_var));
    evalin('base', sprintf('m_var=%f;', m_var));
    evalin('base', sprintf('s_rate=%f;', s_rate));
 
    evalin('base', "conn = database('uavtestbed2', 'postgres', get_password('#4KRx39Dn@09'));");

    evalin('base', "load 'params/mdeg.mat';");
    evalin('base', "load 'params/rdeg.mat';");
    evalin('base', "load 'params/qdeg.mat';");
    
    evalin('base', "uav_sern='X001';");
    evalin('base', "octomodel = get_airframe(conn, uav_sern);");
    evalin('base', "battery_sern='B001';");
    
    
    evalin('base', "batterytwin = get_battery(conn, battery_sern);");
    
    %  this way gives the error: dot indexing is not supported for variables
    %  of this type
    %evalin('base', sprintf("batterytwin.R0 = max(abs(normrnd(rdeg(%d), %f)), .0001);", i, r_var));
    
    %  this way gives the error: array indices must be positive integers or
    %  logical values
    %evalin('base', "batterytwin.R0 = max(abs(normrnd(rdeg(i), r_var)), .0001);");
    
    evalin('base', "batterytwin.Q = min(abs(normrnd(qdeg(i), q_var)), 15.5);");
    evalin('base', "Motortwin2.Req = abs(normrnd(mdeg(i), m_var));");
    
    
    % load the parallel workspace script
%    evalin('base', 'load_parallel_workspace');
%    end
end


