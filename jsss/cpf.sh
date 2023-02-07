#!/bin/bash

# for n in {1..24} ; do cp "../simulink/uav_simulation_tarot.slx" "../simulink/uav_simulation_tarot$n.slx"; done

#for n in {2..24} ; do cp "sim_par1.m" "sim_par$n.m"; done

#for n in {3..24} ; do cp "sim_true2.m" "sim_true$n.m"; done

for n in {3..24} ; do cp "sim_true_rtf2.m" "sim_true_rtf$n.m"; done

# for n in {1..100} ; do psql -d uav2_db -f ../sql/create_tarot_uav.sql -U $USER; done