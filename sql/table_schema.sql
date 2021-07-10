
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

	There is not a table-wide unique constraint on this table because we can have more than one battery of the same type,
	only the serial number has to be unique.
*/
create table asset_tb(
    "id" serial primary key not null,
    "owner" varchar(32) not null default(current_user),
    "type_id" int references asset_type_tb(id),
    "serial_number" varchar(32) unique not null,
    "age" float(16),
    "eol" float(16),
    "units" varchar(32),
);

/*

*/
create table process_type_tb(
	"id" serial primary key not null,
	"type" varchar(32) not null,
	"subtype1" varchar(64) not null,
	"subtype2" varchar(64),
	unique("type", "subtype1", "subtype2")
);

/*

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
	"x_waypoints" float[16] not null,
	"y_waypoints" float[16] not null,
	"x_ref_points" float[1280],
	"y_ref_points" float[1280],
	"sample_time" int not null default 1,
	"reward" float default 1.0,
	unique(path_distance, path_time, x_waypoints, y_waypoints, sample_time, reward)
 );


/*
        description here
*/
create table default_airframe_tb(
	"id" int primary key references asset_tb(id),
	"num_motors" int not null default 8,
	"ct" float not null default 0.0000085486,
	"cq" float not null default 0.00000013678,
	"mass" float not null default 1.8,
	"Jb" float[9] not null default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"cd" float not null default 1.0,
	"Axy" float not null default 0.9,
	"Axz" float not null default 0.5,
	"Ayz" float not null default 0.5,
	"rho" float not null default 1.2,
	"lx" float not null default 0.2,
	"ly" float not null default 0.2,
	"lz" float not null default 0.2,
	"l" float not null default 0.45
);


/*
        description here
*/
create table dc_motor_tb(
    "id" int primary key references asset_tb(id),
    "motor_number" int,
    "Req" float default 0.2371,
    "Ke_eq" float default 0.0107,
    "J" float default 0.00002,
    "Df" float default 0.0,
    "cq" float default 0.00000013678
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
	"dt" float not null default 1.0
);


/*
        description here
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
	"max_flight_time" float not null default 18.0
);



/*
        description here
*/
create table flight_summary_tb(
	"id" serial primary key not null,
	"stop_code" int not null references stop_code_tb(id),
	"z_end" float not null,
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
	"group_num" int,
	unique (dt_start, dt_stop, uav_id, flight_num)
);



/*
        description here
*/
create table flight_degradation_tb (
	"id" serial not null primary key,
	"flight_id" int not null references flight_summary_tb(id),
	"q_deg" float not null,
	"q_var" float not null,
	"q_slope" float,
	"q_intercept" float,
	"r_deg" float not null,
	"r_var" float not null,
	"r_slope" float,
	"r_intercept" float,
	"m_deg" float not null,
	"m_var" float not null,
	"m_slope" float,
	"m_intercept" float,
	"uav_id" int not null references uav_tb(id),
	unique(flight_id, q_deg, q_var, r_deg, r_var, m_deg, m_var, uav_id)
);


/*
        description here
*/
create table flight_telemetry_tb (
	"dt" timestamptz not null,
	"v_batt" float not null,
	"z_batt" float not null,
	"r_batt" float not null,
	"i_batt" float8 not null,
	"ctrl_err" float8 not null,
	"pos_err" float8 not null,
	"x_pos" float8 not null,
	"y_pos" float8 not null,
	"z_pos" float8 not null default 10.0,
	"m1_r" float,
	"m2_r" float,
	"m3_r" float,
	"m4_r" float,
	"m5_r" float,
	"m6_r" float,
	"m7_r" float,
	"m8_r" float,
	"uav_id" int not null references uav_tb(id),
	"flight_id" int not null references flight_summary_tb(id),
	unique(dt, v_batt, z_batt, pos_err, x_pos, y_pos, uav_id, flight_id)
);





