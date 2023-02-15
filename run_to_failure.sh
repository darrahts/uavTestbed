#!/bin/bash

NUM_PARALLEL_UNITS=$(($(nproc --all) / 2))

# start with file2, file1 and file are reserved.
FILE_ID=2

DATE=$(date +'%Y-%m-%d')

echo "number of parallel units: $NUM_PARALLEL_UNITS"

# starting ID of the tarot uav models.
UAV_ID=1412 #952 #492 #32

# used for grouping
GROUP_INFO="'run 2'"

# check if stop count has been reached before executing the file
CHECK_STOPS=1

for (( i=2; i <=$NUM_PARALLEL_UNITS; i++ ))
do 
    echo "simulating uav (id = $UAV_ID, file_id = $FILE_ID)"

    matlab -nodesktop -nodisplay -nosplash -logfile logs/true_rtf\_$UAV_ID.log -batch "uav_id=$UAV_ID; check_stops=$CHECK_STOPS; experiment_info=$GROUP_INFO; try, run('jsss/sim_true_rtf$FILE_ID.m'), catch me, fprintf('%s', string(me.message)), end; exit;" &

    # the same simulink file cannot be executed by multiple processes, so it has been copied 
    let FILE_ID++

    # the UAV IDs increment by 20.
    let UAV_ID+=20

    sleep 20
done

echo "waiting"


wait < <(jobs -p) > /dev/null 2>&1


echo 'simulation done'