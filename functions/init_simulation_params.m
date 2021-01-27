twin_sample_rate = .05;
true_sample_rate = .025;
load 'params/mdown.mat';
load 'params/rdown.mat';
load 'params/qdown.mat';

load_system('truesystem');
load_system('digitaltwin1c');

n_missions = min([length(qdown), length(rdown), length(mdown)]);

ending_soc_true = zeros(n_missions,1);
ending_soc_twin = ending_soc_true;
currents_twin = ending_soc_twin;
currents_true = ending_soc_true;

% for wind
mu1 = normrnd(.5, .8);

pos_errs_true = zeros(n_missions, 3);
pos_errs_twin = pos_errs_true;

track_err_true = zeros(n_missions,2);
track_err_twin = track_err_true;

true_res = zeros(n_missions, 4);
twin_res = zeros(n_missions, 4);

stop_flag = false;
maint_flag = false;

polys = zeros(n_missions,3,2);
lookback = 5;

q_deg = zeros(n_missions, 1);
r_deg = zeros(n_missions, 1);
m_deg = zeros(n_missions, 1);

twin_params = zeros(n_missions, 3);
true_params = zeros(n_missions, 3);

twin_traj = struct;
true_traj = struct;

twin_batt_params = struct;
true_batt_params = struct;

use_twin = true;
use_true = true;

i = 1;

total_missions = 0;