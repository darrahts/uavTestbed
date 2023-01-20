try 
  id  = feature('getpid');
  if ispc
    cmd = sprintf('Taskkill /PID %d /F > /dev/null 2>&1',id);
  elseif (ismac || isunix)
    cmd = sprintf('kill -9 %d > /dev/null 2>&1',id);
  else
    disp('unknown operating system');
  end
  system(cmd);
catch e
  fprintf('%s', string(e.message));
end