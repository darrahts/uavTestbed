function parallel_initializer_handler(i, lookback, horizon, r_var, q_var, m_var, s_rate)
    evalin('base', sprintf('i=%d;', i));
    evalin('base', sprintf('lookback=%d;', lookback));
    evalin('base', sprintf('horizon=%d;', horizon));
    evalin('base', sprintf('r_var=%f;', r_var));
    evalin('base', sprintf('q_var=%f;', q_var));
    evalin('base', sprintf('m_var=%f;', m_var));
    evalin('base', sprintf('s_rate=%f;', s_rate));
    evalin('base', 'load_parallel_workspace');
%    end
end


