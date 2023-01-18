try 
  id  = feature('getpid');
  if ispc
    cmd = sprintf('Taskkill /PID %d /F',id);
  elseif (ismac || isunix)
    cmd = sprintf('kill -9 %d',id);
  else
    disp('unknown operating system');
  end
  system(cmd);

catch e

  fprintf('%s', string(e.message));

end
  
system('killall MATLAB');