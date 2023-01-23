#!/bin/bash

num_parallel_units=$(($(nproc --all) / 2))

fail=0

t=1

DATE=$(date +'%Y-%m-%d')

echo "fail value: $fail"
while true
do 
    echo 'true run < >'

    matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_true\_$t.log -batch "try, run('jsss/sim_true.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
    
    _pid=$!

    echo "pid: $_pid"

    ps -p $_pid

    echo 'waiting for simtrue'
    wait $_pid > /dev/null 2>&1

    t=t+1


    echo 'par run < >'

    # matlab -nodesktop -nodisplay -nosplash -logfile $DATE\_run\_$i.log -batch "try, run('jsss/sim_par1.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
    
    # _pid=$!

    # echo "pid: $_pid"

    # ps -p $_pid

    # echo 'waiting for simpar'
    # wait $_pid > /dev/null 2>&1



    echo 'starting sim par'

    for (( i=1; i <=$num_parallel_units; i++ ))
    do
        echo "$i"
        matlab -nodesktop -nodisplay -nosplash -logfile logs/$DATE\_par\_$t_$i.log -batch "try, run('jsss/sim_par$i.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
        sleep 20
    done


    echo "waiting"


    wait < <(jobs -p) > /dev/null 2>&1


    fail=`cat fail.txt`
    echo "fail value: $fail"
    if [[ $fail == "11111" ]]; then
        echo "failed!"
        break
    fi


done



echo 'simulation done'