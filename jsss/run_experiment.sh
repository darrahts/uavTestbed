#!/bin/bash
# export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/dri/

# matlab -nodesktop -nodisplay -nosplash -logfile test.log -batch "try, run('jsss/sim_true.m'), catch me, fprintf('%s', string(me.message)), end; exit;"

echo 'hello'

matlab -nodesktop -nodisplay -nosplash -logfile test.log -batch "try, run('jsss/sim_par1.m'), catch me, fprintf('%s', string(me.message)), end; exit;"

echo 'goodbye'
