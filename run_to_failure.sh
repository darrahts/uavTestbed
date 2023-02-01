#!/bin/bash

num_parallel_units=$(($(nproc --all) / 2))

t=2  

DATE=$(date +'%Y-%m-%d')

echo $t
echo $num_parallel_units

# matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true\_$t.log -batch "try, run('jsss/sim_true$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &

# matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true_rtf\_$t.log -batch "try, run('jsss/sim_true_rtf$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &

for (( i=2; i <=$num_parallel_units; i++ ))
do 
    echo "true run < $t>"

    # matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true\_$t.log -batch "try, run('jsss/sim_true$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
    matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true_rtf\_$t.log -batch "try, run('jsss/sim_true_rtf$t.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &

    let t++

    sleep 20
done

echo "waiting"


wait < <(jobs -p) > /dev/null 2>&1


echo 'simulation done'