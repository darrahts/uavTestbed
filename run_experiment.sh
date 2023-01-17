#!/bin/bash

num_parallel_units=$(($(nproc --all) / 2))

fail=0

echo "fail value: $fail"
while true
do 
    matlab -nosplash -nodesktop -nodisplay -r "try, run('jsss/sim_true.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &
    _pid=$!

    ps -p $_pid

    echo 'waiting for simtrue'
    wait $_pid 


    echo 'starting sim par'

    for (( i=1; i <=$num_parallel_units; i++ ))
    do
        echo "$i"
        matlab -nosplash -nodesktop -nodisplay -r "try, run('jsss/sim_par$i.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &

        sleep 20

    done

    echo "waiting"
    wait < <(jobs -p)


    fail=`cat fail.txt`
    echo "fail value: $fail"
    if (( "$fail" == "11111" ))
    then 
        echo "failed!"
       break
    fi


done



echo 'simulation done'