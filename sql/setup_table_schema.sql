
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
	"subtype1" varchar(64) not null,
	"subtype2" varchar(64),
	unique("type", "subtype1", "subtype2")
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
    "type" varchar(32) unique not null,
    "subtype" varchar(32) unique not null,
    "description" varchar(256),
    unique ("type", "subtype", "description")
);


/*
    Table to hold asset data

	There is not a table-wide unique constraint on this table because we can have more than one component of the same type,
	only the serial number has to be unique.
*/
create table asset_tb(
    "id" serial primary key not null,
    "owner" varchar(32) not null default(current_user),
    "type_id" int not null references asset_type_tb(id),
	"process_id" int references process_tb(id),
    "serial_number" varchar(32) unique not null,
	"common_name" varchar(32),
    "age" float(16) default 0,
    "eol" float(16) default 0,
    "units" varchar(32)
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
create table default_airframe_tb(
	"id" int primary key references asset_tb(id),
	"num_motors" int not null default 8,
	"mass" float not null default 1.8,
	"Jb" float[9] not null default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"cd" float not null default 1.0,
	"Axy" float not null default 0.9,
	"Axz" float not null default 0.5,
	"Ayz" float not null default 0.5,
	"l" float not null default 0.45,
	constraint check_num_motors check (num_motors in (3, 4, 6, 8))
);



/*
        description here
*/
create table dc_motor_tb(
    "id" int primary key references asset_tb(id),
    "motor_number" int,
    "Req" float not null default 0.2371,
    "Ke_eq" float not null default 0.0107,
    "J" float not null default 0.00002,
    "Df" float default 0.0,
	"cd" float default 0.0,
	"ct" float not null default 0.0000085486,
	"cq" float not null default 0.00000013678,
	"cq2" float default 0.0,
	"current_limit" float default 11.0
);


/*
        description here
*/
create table eqc_battery_tb (
	"id" int primary key references asset_tb(id),
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
	"soc_ocv" json default '{}'
);


/*
        The uav_tb is basically a container and can easily be extended with other parameters. Some parameters are added in
		the simulation that could be moved here for example.
*/
create table uav_tb(
	"id" int primary key references asset_tb(id),
	"airframe_id" int not null references asset_tb(id),
	"battery_id" int not null references asset_tb(id),
	"m1_id" int not null references asset_tb(id),
	"m2_id" int not null references asset_tb(id),
	"m3_id" int not null references asset_tb(id),
	"m4_id" int references asset_tb(id),
	"m5_id" int references asset_tb(id),
	"m6_id" int references asset_tb(id),
	"m7_id" int references asset_tb(id),
	"m8_id" int references asset_tb(id),
	"gps_id" int references asset_tb(id),
	"max_flight_time" float not null default 18.0,
	"dynamics_srate" float not null default .025
);



/*
        This table is for end-of-flight metrics
		- flight_time is in minutes
*/
create table flight_summary_tb(
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
	"dt_start" timestamptz not null,
	"dt_stop" timestamptz not null,
	"trajectory_id" int not null references trajectory_tb(id),
	"uav_id" int not null references uav_tb(id),
	"flight_num" int not null,
	"group_id" int references group_tb(id),
	unique (dt_start, dt_stop, uav_id, flight_num, group_id)
);

create table sensor_tb(
	"id" int primary key references asset_tb(id),
	"voltage_supply" float not null default 12.0,
	"avg_watts" float not null default 8.26,
	"std_watts" float not null default .02,
	"params" json default '{}'
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
create table flight_degradation_tb (
	"id" serial primary key,
	"flight_id" int not null references flight_summary_tb(id),
	"q_deg" float not null,
	"q_var" float,
	"q_slope" float,
	"q_intercept" float,
	"r_deg" float not null,
	"r_var" float,
	"r_slope" float,
	"r_intercept" float,
	"m_deg" float not null,
	"m_var" float,
	"m_slope" float,
	"m_intercept" float,
	unique(flight_id, q_deg, q_var, r_deg, r_var, m_deg, m_var)
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
create table flight_telemetry_tb (
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
	"flight_id" int references flight_summary_tb(id)
);


