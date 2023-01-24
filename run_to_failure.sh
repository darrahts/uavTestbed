#!/bin/bash

num_parallel_units=$(($(nproc --all) / 2))

t=2

DATE=$(date +'%Y-%m-%d')

echo $t

matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true\_$t.log -batch "try, run('jsss/sim_true$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &


# for (( i=1; i <=$num_parallel_units; i++ ))
# do 
#     echo "true run < $t>"

#     matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true\_$t.log -batch "try, run('jsss/sim_true$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
    
#     t=t+1

#     sleep 20
# done

echo "waiting"


wait < <(jobs -p) > /dev/null 2>&1


echo 'simulation done'