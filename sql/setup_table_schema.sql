
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
	This is the table schema for the data management system. It includes the following tables 
		- asset_type_tb
		- asset_tb
		- process_type_tb
		- process_tb   
		- stop_code_tb
		- trajectory_tb     
		- default_airframe_tb
		- dc_motor_tb
		- eqc_battery_tb
		- uav_tb
		- flight_summary_tb
		- flight_degradation_tb
		- flight_telemetry_tb
		- environment_data_tb (todo) 


	Contributing and extending this is not difficult and needed!

	Tim Darrah
	NASA Fellow
	PhD Student
	Vanderbilt University
	timothy.s.darrah@vanderbilt.edu
*/
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

/*
	fields:
		type: refers to the process such as degradation, environment, etc
		subtype:1: refers to the component such as battery, motor, wind, etc
		subtype2: refers to what within the component such as capacitance, resistance, gust, etc
*/
create table process_type_tb(
	"id" serial primary key not null,
	"type" varchar(32) not null,
	"subtype" varchar(64) not null,
	"subtype2" varchar(64),
	unique("type", "subtype", "subtype2")
);


/*
	fields:
		description: details about how the process evolves such as continuous or discrete, etc
*/
create table process_tb(
	"id" serial primary key not null,
	"type_id" int not null references process_type_tb,
	"description" varchar(256) not null,
    "source" varchar(256) not null,
	"parameters" json not null,
	unique("type_id", "description", "source")
);




/*
        description here
*/
create table asset_type_tb(
    "id" serial primary key not null,
    "type" varchar(32) not null,
    "subtype" varchar(32) not null,
    "subtype2" varchar(32) unique,
    "description" varchar(256),
    unique ("type", "subtype", "subtype2", "description")
);


/*
    Table to hold asset data

	There is not a table-wide unique constraint on this table because we can have more than one component of the same type,
	only the serial number has to be unique.
*/
create table asset_tb(
    "id" serial not null,
    "version" int not null default 1,
    "owner" varchar(32) not null default(current_user),
    "type_id" int not null references asset_type_tb(id),
	"process_id" int array,
    "serial_number" varchar(32) not null,
	"common_name" varchar(32),
    "age" float(16) default 0,
	"age2" float(16) default 0,
    "eol" float(16) default 0,
    "units" varchar(32), 
	"units2" varchar(32),
	unique("serial_number", "version"),
	unique("id", "version"),
	primary key ("id", "version")
);


/*
    Table to hold stop code information used during simulations

	example:
		low soc is the stop code when the flight is terminated due to violating a minimum soc threshold.
		the id can then used for further analysis
*/
create table stop_code_tb(
	"id" serial primary key not null,
	"description" varchar(256) unique not null
);



/*
	This is a helper table that is used in conjunction with flight_summary_tb to help organize multiple flights.
	The first group has an id of 1 with info of "example".
*/
create table group_tb(
	id serial primary key not null,
	info varchar(256) unique not null
);




/*
    Table to hold trajectory information
	
	fields:
		path_distance: distance of flight in meters
		risk_factor: risk of collision 
		<x/y>_waypoints: the main waypoints of the trajectory
		<x/y>_ref_points: reference points along the trajectory at "sample_time" intervals,
			can be left null and generated at run time
		sample_time: sample time of the <x/y>_ref_points
		reward: reward for this trajectory

	constraints:
		duplicate entries not allowed
*/
create table trajectory_tb(
	"id" serial primary key,
	"path_distance" float not null,
	"path_time" float not null,
	"risk_factor" float default .01,
	"start" float[2] not null,
	"destination" float[2] not null,
	"x_waypoints" float[16] not null,
	"y_waypoints" float[16] not null,
	"x_ref_points" float[1280],
	"y_ref_points" float[1280],
	"sample_time" int not null default 1,
	"reward" float default 1.0,
	"map" varchar(32) not null default 'map',
	unique(path_distance, path_time, "start", destination, x_waypoints, y_waypoints, sample_time, reward)
 );


/*
       Creates an airframe with default parameters, other parameter values can be supplied to model different UAVs that use the same dynamics
	   To create an airframe that uses "different" parameters, create a different asset and subsequent airframe table for that specific model.

	   num_motors: 3, 4, 6, or 8

	   NOTE: "ct" and "cq" are thrust and torque constants of the MOTOR, not airframe. these parameters will stay here to remain 
	   backwards compatable with previous simulations but will be removed in the future. 
*/
create table airframe_tb(
	"id" serial not null,
	"version" int not null default 1,
	"num_motors" int not null default 8,
	"mass" float not null default 1.8,
	"Jb" float[9] not null default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"cd" float not null default 1.0,
	"Axy" float not null default 0.9,
	"Axz" float not null default 0.5,
	"Ayz" float not null default 0.5,
	"l" float not null default 0.45,
	constraint check_num_motors check (num_motors in (3, 4, 6, 8)),
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key ("id", "version") references asset_tb("id", "version")
);



/*
        description here
*/
create table dc_motor_tb(
    "id" serial not null,
    "version" int not null default 1,
    "motor_number" int,
    "Req" float not null default 0.2371,
    "Ke_eq" float not null default 0.0107,
    "J" float not null default 0.00002,
    "Df" float default 0.0,
	"cd" float default 0.0,
	"ct" float not null default 0.0000085486,
	"cq" float not null default 0.00000013678,
	"cq2" float default 0.0,
	"current_limit" float default 11.0,
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key ("id", "version") references asset_tb("id", "version")
);


/*
		description here
*/
create table esc_tb(
	"id" serial not null,
	"version" int not null default 1,
	"esc_number" int,
	"params" json default '{}',
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key ("id", "version") references asset_tb("id", "version")
);


/*
        description here
*/
create table eqc_battery_tb (
    "id" serial not null,
    "version" int not null default 1,
	"cycles" int  default 0,
	"Q" float not null default 15.0,
	"G" float not null default 163.4413,
	"M" float not null default 0.0092,
	"M0" float not null default 0.0019,
	"RC" float not null default 3.6572,
	"R" float not null default 0.00028283,
	"R0" float not null default 0.0011,
	"n" float not null default 0.9987,
	"EOD" float not null default 3.04,
	"z" float not null default 1.0,
	"Ir" float not null default 0.0,
	"h" float not null default 0.0,
	"v" float not null default 4.2,
	"v0" float not null default 4.2,
	"dt" float not null default 1.0,
	"soc_ocv" json default '{}',
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key ("id", "version") references asset_tb("id", "version")
);


/*
        The uav_tb is basically a container and can easily be extended with other parameters. Some parameters are added in
		the simulation that could be moved here for example.
*/
create table uav_tb(
	"id" serial not null,
	"version" int not null default 1,
	"airframe_id" int not null,
	"battery_id" int not null,
	"motors_id" int array,
	"escs_id" int array,
	"m1_id" int,
	"m2_id" int,
	"m3_id" int,
	"m4_id" int,
	"m5_id" int,
	"m6_id" int,
	"m7_id" int,
	"m8_id" int,
	"gps_id" int,
	"max_flight_time" float not null default 18.0,
	"dynamics_srate" float not null default .025,
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key ("id", "version") references asset_tb("id", "version")
);

/*
        This table is for end-of-flight metrics
		- flight_time is in minutes
*/
create table session_tb(
	"id" serial primary key not null,
	"stop_code" int not null references stop_code_tb(id),
	"z_start" float not null,
	"z_end" float not null,
	"v_start" float not null,
	"v_end" float not null,
	"m1_avg_current" float,
	"m2_avg_current" float,
	"m3_avg_current" float,
	"m4_avg_current" float,
	"m5_avg_current" float,
	"m6_avg_current" float,
	"m7_avg_current" float,
	"m8_avg_current" float,
	"avg_vel" float,
	"std_vel" float,
	"avg_acc" float,
	"std_acc" float,
	"avg_pos_err" float not null,
	"max_pos_err" float not null,
	"std_pos_err" float not null,
	"avg_ctrl_err" float not null,
	"max_ctrl_err" float not null,
	"std_ctrl_err" float not null,
	"distance" float not null,
	"flight_time" float not null,
	"avg_current" float not null,
	"amp_hours" float not null,
	"dt_start" timestamptz not null,
	"dt_stop" timestamptz not null,
	"trajectory_id" int not null references trajectory_tb(id),
	"uav_id" int not null,
	"uav_version" int not null,
	"flight_num" int not null,
	"group_id" int references group_tb(id),
	unique (dt_start, dt_stop, uav_id, uav_version, flight_num, group_id),
	foreign key (uav_id, uav_version) references uav_tb("id", "version")
);


create table sensor_tb(
    "id" serial not null,
    "version" int not null default 1,
	"voltage_supply" float not null default 12.0,
	"avg_watts" float not null default 8.26,
	"std_watts" float not null default .02,
	"params" json default '{}',
	unique("id", "version"),
	primary key ("id", "version"),
	foreign key (id, "version") references asset_tb("id", "version")
);


/*
        This holds degradation data for
		- battery charge capacitance (q_deg)
			where q_deg = battery.Q 
		- variance in the charge capacitance degradation
			this comes from the degradation model being supplied
			other factors can possibly influence this parameter 
		- rate of change (q_slope) in the battery capacitance degradation
		- bias (q_intercept) of the rate of change approximation
		- battery internal resistance (r_deg)
		- same with variance, rate of change, and bias
		- the same 4 parameters as above for one motor of choice

		more could be added and this isn't the only way to handle the data
*/
create table degradation_tb (
	"id" serial primary key,
	"flight_id" int not null references session_tb(id),
	"q_deg" float not null,
	"q_var" float,
	"r_deg" float not null,
	"r_var" float,
	"m1_deg" float not null,
	"m1_var" float,
	"m2_deg" float,
	"m2_var" float,
	"m3_deg" float,
	"m3_var" float,
	"m4_deg" float,
	"m4_var" float,
	"m5_deg" float,
	"m5_var" float,
	"m6_deg" float,
	"m6_var" float,
	"m7_deg" float,
	"m7_var" float,
	"m8_deg" float,
	"m8_var" float,

	unique(flight_id, q_deg, q_var, r_deg, r_var, m1_deg, m1_var)
);


/*
        this table holds in-flight telemetry data and at a minimum if used must record 
		- battery_true_v
		- battery_true_z
		- battery_true_i
		- x_pos_true
		- y_pos_true
		- z_pos_true

		new fields are easily added. 
*/
create table telemetry_tb (
	"dt" timestamp(6) unique not null,
    "battery_true_v" float not null,
    "battery_true_z" float not null,
    "battery_true_r" float,
    "battery_true_i" float not null,
    "battery_hat_v" float,
    "battery_hat_z" float, 
    "battery_hat_r" float,
    "battery_hat_z_var" float,
    "battery_hat_r_var" float,
    "wind_gust_x" float,
    "wind_gust_y" float,
    "wind_gust_z" float,
	"wind_const_x" float,
    "wind_const_y" float,
    "wind_const_z" float,
	"wind_direction" float,
	"wind_magnitude" float,
	"m1_vref" float,
    "m1_rpm" float,
    "m1_torque" float,
    "m1_current" float,
	"m2_vref" float,
    "m2_rpm" float,
    "m2_torque" float,
    "m2_current" float,
	"m3_vref" float,
    "m3_rpm" float,
    "m3_torque" float,
    "m3_current" float,
	"m4_vref" float,
    "m4_rpm" float,
    "m4_torque" float,
    "m4_current" float,
	"m5_vref" float,
    "m5_rpm" float,
    "m5_torque" float,
    "m5_current" float,
	"m6_vref" float,
    "m6_rpm" float,
    "m6_torque" float,
    "m6_current" float,
	"m7_vref" float,
    "m7_rpm" float,
    "m7_torque" float,
    "m7_current" float,
	"m8_vref" float,
    "m8_rpm" float,
    "m8_torque" float,
    "m8_current" float,
    "euclidean_pos_err" float,
    "x_pos_err" float,
    "y_pos_err" float,
    "x_ctrl_err" float,
    "y_ctrl_err" float,
	"x_pos_gps" float,
    "y_pos_gps" float,
    "z_pos_gps" float,
    "x_pos_true" float not null,
    "y_pos_true" float not null,
    "z_pos_true" float not null,
	"x_vel_gps" float,
    "y_vel_gps" float,
    "z_vel_gps" float,
    "x_vel_true" float not null,
    "y_vel_true" float not null,
    "z_vel_true" float not null,
	"velocity" float,
	"acceleration" float,
	"flight_id" int references session_tb(id)
);

/*
	helper table used by the monte carlo experiment, component ages of the true system

*/
create table true_age_tb(
	"id" serial primary key not null,
	"flight_id" int references session_tb(id),
	"stop_code" int references stop_code_tb(id),
	"trajectory_id" int references trajectory_tb(id),
	"uav_age" float not null,
	"battery_age" float not null,
	"m1_age" float not null,
	"m2_age" float not null,
	"m3_age" float not null,
	"m4_age" float not null,
	"m5_age" float not null,
	"m6_age" float not null,
	"m7_age" float not null,
	"m8_age" float not null
);

/*
	helper table used by the monte carlo experiment, component ages of the particles

*/
create table stochastic_tb(
	"id" serial primary key not null,
	"flight_id" int references session_tb(id),
	"stop_code" int references stop_code_tb(id),
	"trajectory_id" int references trajectory_tb(id),
	"uav_age" float not null,
	"battery_age" float not null,
	"m1_age" float not null,
	"m2_age" float not null,
	"m3_age" float not null,
	"m4_age" float not null,
	"m5_age" float not null,
	"m6_age" float not null,
	"m7_age" float not null,
	"m8_age" float not null,
	"session_num" int not null
);



create table stochastic_summary_tb(
	"id" serial primary key not null,
	"stop_code" int not null references stop_code_tb(id),
	"z_start" float not null,
	"z_end" float not null,
	"v_start" float not null,
	"v_end" float not null,
	"m1_avg_current" float,
	"m2_avg_current" float,
	"m3_avg_current" float,
	"m4_avg_current" float,
	"m5_avg_current" float,
	"m6_avg_current" float,
	"m7_avg_current" float,
	"m8_avg_current" float,
	"avg_pos_err" float not null,
	"max_pos_err" float not null,
	"std_pos_err" float not null,
	"avg_ctrl_err" float not null,
	"max_ctrl_err" float not null,
	"std_ctrl_err" float not null,
	"distance" float not null,
	"flight_time" float not null,
	"avg_current" float not null,
	"amp_hours" float not null,
	"trajectory_id" int not null references trajectory_tb(id),
	"uav_id" int not null,
	"uav_version" int not null,
	"flight_id" int not null,
	"flight_num" int not null,
	"session_num" int not null,
	unique (uav_id, flight_id, flight_num, session_num),
	foreign key (uav_id, uav_version) references uav_tb("id", "version")
);


create table stochastic_degradation_tb (
	"id" serial primary key,
	"q_deg" float not null,
	"r_deg" float not null,
	"m1_deg" float not null,
	"m2_deg" float,
	"m3_deg" float,
	"m4_deg" float,
	"m5_deg" float,
	"m6_deg" float,
	"m7_deg" float,
	"m8_deg" float,
	"uav_id" int not null,
	"uav_version" int not null,
	"flight_id" int not null,
	"flight_num" int not null,
	"session_num" int not null,
	unique(flight_id, uav_id, flight_num, q_deg, r_deg, m1_deg, session_num),
	foreign key (uav_id, uav_version) references uav_tb("id", "version")
);
