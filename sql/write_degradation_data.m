




if i > lookback
    degradation_tb_cols = {'mission_id', 'q_deg', 'q_var', 'q_slope', 'q_intercept', ...
        'r_deg', 'r_var', 'r_slope', 'r_intercept', 'm_deg', 'm_var', 'm_slope', 'm_intercept', ...
        'battery_id', 'motor2_id', 'uav_id'};
    degradation_tb = table(mission_id, q_deg(i), q_var, q_poly(1), q_poly(2), ...
        r_deg(i), r_var, r_poly(1), r_poly(2), m_deg(i), m_var, ...
        m_poly(1), m_poly(2), battery.id, Motor2.id, octomodel.id, ...
        'VariableNames', degradation_tb_cols);
else
    degradation_tb_cols = {'mission_id', 'q_deg', 'q_var', 'r_deg', 'r_var', ...
        'm_deg', 'm_var','battery_id', 'motor2_id', 'uav_id'};
    degradation_tb = table(mission_id, q_deg(i), q_var, r_deg(i), ...
        r_var, m_deg(i), m_var, battery.id, Motor2.id, octomodel.id, ...
        'VariableNames', degradation_tb_cols);
end
%disp(degradation_tb)
    
sqlwrite(conn, 'degradation_parameter_tb', degradation_tb);
conn.commit();