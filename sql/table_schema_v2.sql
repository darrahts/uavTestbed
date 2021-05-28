-- public.experiment_tb definition

-- Drop table

-- DROP TABLE experiment_tb;

CREATE TABLE experiment_tb (
	id serial NOT NULL,
	mission_ids varchar(256) NULL,
	notes varchar(512) NULL,
	CONSTRAINT experiment_tb_mission_ids_notes_key UNIQUE (mission_ids, notes),
	CONSTRAINT experiment_tb_pkey PRIMARY KEY (id)
);


-- public.flight_sensor_tb definition

-- Drop table

-- DROP TABLE flight_sensor_tb;

CREATE TABLE flight_sensor_tb (
	dt varchar(123) NULL,
	"current" numeric(38,16) NULL,
	x_ctrl_err numeric(38,16) NULL,
	y_ctrl_err numeric(38,16) NULL,
	pos_err numeric(38,16) NULL,
	x_pos numeric(38,16) NULL,
	y_pos numeric(38,16) NULL,
	m2_res numeric(38,16) NULL,
	m4_res numeric(38,16) NULL,
	m5_res numeric(38,16) NULL,
	battery_id numeric(38,16) NULL,
	uav_id numeric(38,16) NULL,
	mission_id numeric(38,16) NULL
);


-- public.model_tb definition

-- Drop table

-- DROP TABLE model_tb;

CREATE TABLE model_tb (
	id serial NOT NULL,
	uav_id int4 NOT NULL,
	active bool NOT NULL DEFAULT true,
	path_header varchar(256) NOT NULL,
	model_path varchar(128) NOT NULL,
	scaler_x_path varchar(128) NOT NULL,
	scaler_y_path varchar(128) NOT NULL,
	test_score float8 NOT NULL,
	validate_score float8 NOT NULL,
	size_mb float8 NOT NULL,
	num_weights int4 NOT NULL,
	train_date date NOT NULL DEFAULT now()::date,
	train_samples int4 NOT NULL,
	test_samples int4 NOT NULL,
	validate_samples int4 NOT NULL,
	batch_size int4 NOT NULL,
	validation_split float8 NOT NULL,
	dropout float8 NOT NULL,
	epochs int4 NOT NULL,
	penalty float8 NULL,
	min_delta float8 NULL,
	patience int4 NULL,
	CONSTRAINT model_tb_uav_id_num_weights_train_samples_test_samples_vali_key UNIQUE (uav_id, num_weights, train_samples, test_samples, validate_samples, batch_size, dropout, epochs)
);


-- public.trajectory_tb definition

-- Drop table

-- DROP TABLE trajectory_tb;

CREATE TABLE trajectory_tb (
	id serial NOT NULL,
	path_distance float8 NOT NULL,
	path_time float8 NOT NULL,
	risk_factor float8 NOT NULL DEFAULT 0.01,
	x_waypoints _float8 NOT NULL,
	y_waypoints _float8 NOT NULL,
	x_ref_points _float8 NOT NULL,
	y_ref_points _float8 NOT NULL,
	sample_time int4 NOT NULL DEFAULT 1,
	reward float8 NOT NULL DEFAULT 1.0,
	CONSTRAINT trajectory_tb_path_distance_path_time_x_waypoints_y_waypoin_key UNIQUE (path_distance, path_time, x_waypoints, y_waypoints, sample_time),
	CONSTRAINT trajectory_tb_pkey PRIMARY KEY (id)
);


-- public.uav_tb definition

-- Drop table

-- DROP TABLE uav_tb;

CREATE TABLE uav_tb (
	id serial NOT NULL,
	"name" varchar(32) NULL,
	serial_number varchar(16) NULL,
	ct float8 NOT NULL DEFAULT 0.0000085486,
	cq float8 NOT NULL DEFAULT 0.00000013678,
	mass float8 NOT NULL DEFAULT 1.8,
	"Jb" _float8 NOT NULL DEFAULT '{0.0429,0,0,0,0.0429,0,0,0,0.0748}'::double precision[],
	"Jbinv" _float8 NOT NULL DEFAULT '{23.31,0,0,0,23.31,0,0,0,13.369}'::double precision[],
	g float8 NOT NULL DEFAULT 9.8,
	sampletime float8 NOT NULL DEFAULT 0.025,
	cd float8 NOT NULL DEFAULT 1.0,
	"Axy" float8 NOT NULL DEFAULT 0.04,
	"Axz" float8 NOT NULL DEFAULT 0.04,
	"Ayz" float8 NOT NULL DEFAULT 0.04,
	rho float8 NOT NULL DEFAULT 1.2,
	lx float8 NOT NULL DEFAULT 0.2,
	ly float8 NOT NULL DEFAULT 0.2,
	lz float8 NOT NULL DEFAULT 0.2,
	l float8 NOT NULL DEFAULT 0.45,
	CONSTRAINT uav_tb_pkey PRIMARY KEY (id),
	CONSTRAINT uav_tb_serial_number_key UNIQUE (serial_number)
);


-- public.eq_motor_tb definition

-- Drop table

-- DROP TABLE eq_motor_tb;

CREATE TABLE eq_motor_tb (
	id serial NOT NULL,
	"name" varchar(32) NULL DEFAULT 'default_motor'::character varying,
	serial_number varchar(16) NOT NULL,
	motor_number int4 NOT NULL,
	age_hours float8 NULL DEFAULT 0.0,
	status varchar(32) NULL DEFAULT 'GREEN'::character varying,
	"Req" float8 NULL DEFAULT 0.2371,
	"Ke_eq" float8 NULL DEFAULT 0.0107,
	"J" float8 NULL DEFAULT 0.00002,
	"Df" float8 NULL DEFAULT 0.0,
	cq float8 NULL DEFAULT 0.00000013678,
	uav_id int4 NULL,
	CONSTRAINT eq_motor_tb_pkey PRIMARY KEY (id),
	CONSTRAINT eq_motor_tb_serial_number_key UNIQUE (serial_number),
	CONSTRAINT eq_motor_tb_serial_number_motor_number_key UNIQUE (serial_number, motor_number),
	CONSTRAINT eq_motor_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);


-- public.eqc_battery_tb definition

-- Drop table

-- DROP TABLE eqc_battery_tb;

CREATE TABLE eqc_battery_tb (
	id serial NOT NULL,
	"name" varchar(32) NULL DEFAULT 'default_battery'::character varying,
	serial_number varchar(16) NULL,
	age_hours float8 NULL DEFAULT 0.0,
	age_cycles int4 NULL DEFAULT 0,
	status varchar(32) NULL DEFAULT 'GREEN'::character varying,
	"Q" float8 NOT NULL DEFAULT 15.0,
	"G" float8 NOT NULL DEFAULT 163.4413,
	"M" float8 NOT NULL DEFAULT 0.0092,
	"M0" float8 NOT NULL DEFAULT 0.0019,
	"RC" float8 NOT NULL DEFAULT 3.6572,
	"R" float8 NOT NULL DEFAULT 0.00028283,
	"R0" float8 NOT NULL DEFAULT '-0.0011'::numeric,
	n float8 NOT NULL DEFAULT 0.9987,
	"EOD" float8 NOT NULL DEFAULT 3.04,
	z float8 NOT NULL DEFAULT 1.0,
	"Ir" float8 NOT NULL DEFAULT 0.0,
	h float8 NOT NULL DEFAULT 0.0,
	v float8 NOT NULL DEFAULT 4.2,
	v0 float8 NOT NULL DEFAULT 4.2,
	dt float8 NOT NULL DEFAULT 1.0,
	in_use bool NULL DEFAULT false,
	uav_id int4 NULL,
	CONSTRAINT eqc_battery_tb_pkey PRIMARY KEY (id),
	CONSTRAINT eqc_battery_tb_serial_number_key UNIQUE (serial_number),
	CONSTRAINT eqc_battery_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);


-- public.mission_tb definition

-- Drop table

-- DROP TABLE mission_tb;

CREATE TABLE mission_tb (
	id serial NOT NULL,
	dt_start timestamptz NOT NULL,
	dt_stop timestamptz NOT NULL,
	trajectory_id int4 NULL,
	stop_code int4 NOT NULL,
	prior_rul float8 NOT NULL,
	flight_time float8 NOT NULL,
	distance float8 NOT NULL,
	z_end float8 NOT NULL,
	v_end float8 NOT NULL,
	avg_pos_err float8 NOT NULL,
	max_pos_err float8 NOT NULL,
	std_pos_err float8 NOT NULL,
	avg_ctrl_err float8 NOT NULL,
	max_ctrl_err float8 NOT NULL,
	std_ctrl_err float8 NOT NULL,
	battery_id int4 NULL,
	uav_id int4 NULL,
	idx int4 NULL,
	CONSTRAINT mission_tb_dt_start_dt_stop_key UNIQUE (dt_start, dt_stop),
	CONSTRAINT mission_tb_pkey PRIMARY KEY (id),
	CONSTRAINT mission_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT mission_tb_trajectory_id_fkey FOREIGN KEY (trajectory_id) REFERENCES trajectory_tb(id),
	CONSTRAINT mission_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);


-- public.system_parameter_tb definition

-- Drop table

-- DROP TABLE system_parameter_tb;

CREATE TABLE system_parameter_tb (
	id serial NOT NULL,
	mission_idx int4 NULL,
	pos_err_mu float8 NOT NULL,
	pos_err_std float8 NOT NULL,
	pos_std_mu float8 NOT NULL,
	pos_std_std float8 NOT NULL,
	ctrl_err_mu float8 NOT NULL,
	ctrl_err_std float8 NOT NULL,
	ctrl_std_mu float8 NOT NULL,
	ctrl_std_std float8 NOT NULL,
	z_end_mu float8 NOT NULL,
	z_end_std float8 NOT NULL,
	v_end_mu float8 NOT NULL,
	v_end_std float8 NOT NULL,
	flight_time_mu float8 NOT NULL,
	flight_time_std float8 NOT NULL,
	stop_codes1 float8 NOT NULL,
	stop_codes2 float8 NOT NULL,
	stop_codes3 float8 NOT NULL,
	r_deg_mu float8 NOT NULL,
	r_deg_std float8 NOT NULL,
	q_deg_mu float8 NOT NULL,
	q_deg_std float8 NOT NULL,
	m_deg_mu float8 NOT NULL,
	m_deg_std float8 NOT NULL,
	r_poly_delta_mu float8 NOT NULL,
	r_poly_delta_std float8 NOT NULL,
	r_poly_bias_mu float8 NOT NULL,
	r_poly_bias_std float8 NOT NULL,
	q_poly_delta_mu float8 NOT NULL,
	q_poly_delta_std float8 NOT NULL,
	q_poly_bias_mu float8 NOT NULL,
	q_poly_bias_std float8 NOT NULL,
	m_poly_delta_mu float8 NOT NULL,
	m_poly_delta_std float8 NOT NULL,
	m_poly_bias_mu float8 NOT NULL,
	m_poly_bias_std float8 NOT NULL,
	dt timestamptz NULL DEFAULT now(),
	CONSTRAINT system_parameter_tb_pkey PRIMARY KEY (id),
	CONSTRAINT system_parameter_tb_mission_id_fkey FOREIGN KEY (mission_idx) REFERENCES mission_tb(id)
);


-- public.twin_params_tb definition

-- Drop table

-- DROP TABLE twin_params_tb;

CREATE TABLE twin_params_tb (
	id serial NOT NULL,
	mission_id int4 NULL,
	trajectory_id int4 NULL,
	rul_hat float8 NOT NULL,
	flight_time float8 NOT NULL,
	distance float8 NOT NULL,
	v_end float8 NOT NULL,
	z_end float8 NOT NULL,
	avg_err float8 NOT NULL,
	q_deg float8 NOT NULL,
	r_deg float8 NOT NULL,
	m_deg float8 NOT NULL,
	stop1 int4 NOT NULL,
	stop2 int4 NOT NULL,
	stop3 int4 NOT NULL,
	uav_id int4 NULL,
	CONSTRAINT twin_params_tb_pkey PRIMARY KEY (id),
	CONSTRAINT twin_params_tb_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES mission_tb(id),
	CONSTRAINT twin_params_tb_trajectory_id_fkey FOREIGN KEY (trajectory_id) REFERENCES trajectory_tb(id),
	CONSTRAINT twin_params_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);


-- public.battery_sensor_tb definition

-- Drop table

-- DROP TABLE battery_sensor_tb;

CREATE TABLE battery_sensor_tb (
	dt timestamptz NOT NULL,
	v float8 NOT NULL,
	z float8 NOT NULL,
	r0 float8 NOT NULL,
	q float8 NOT NULL,
	v_prime float8 NOT NULL,
	v_hat float8 NOT NULL,
	z_hat float8 NOT NULL,
	z_bound float8 NOT NULL,
	r0_hat float8 NOT NULL,
	r0_bound float8 NOT NULL,
	battery_id int4 NULL,
	uav_id int4 NULL,
	mission_id int4 NULL,
	CONSTRAINT battery_sensor_tb_dt_v_z_r0_q_v_prime_v_hat_z_hat_z_bound_r_key UNIQUE (dt, v, z, r0, q, v_prime, v_hat, z_hat, z_bound, r0_hat, r0_bound, battery_id, uav_id, mission_id),
	CONSTRAINT battery_sensor_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT battery_sensor_tb_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES mission_tb(id),
	CONSTRAINT battery_sensor_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);
CREATE INDEX battery_sensor_tb_dt_idx ON public.battery_sensor_tb USING btree (dt DESC);


-- public.degradation_parameter_tb definition

-- Drop table

-- DROP TABLE degradation_parameter_tb;

CREATE TABLE degradation_parameter_tb (
	id serial NOT NULL,
	mission_id int4 NULL,
	q_deg float8 NOT NULL,
	q_var float8 NOT NULL,
	q_slope float8 NULL,
	q_intercept float8 NULL,
	r_deg float8 NOT NULL,
	r_var float8 NOT NULL,
	r_slope float8 NULL,
	r_intercept float8 NULL,
	m_deg float8 NOT NULL,
	m_var float8 NOT NULL,
	m_slope float8 NULL,
	m_intercept float8 NULL,
	battery_id int4 NULL,
	motor2_id int4 NULL,
	uav_id int4 NULL,
	CONSTRAINT degradation_parameter_tb_mission_id_q_deg_q_var_r_deg_r_var_key UNIQUE (mission_id, q_deg, q_var, r_deg, r_var, m_deg, m_var, battery_id, motor2_id),
	CONSTRAINT degradation_parameter_tb_pkey PRIMARY KEY (id),
	CONSTRAINT degradation_parameter_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT degradation_parameter_tb_motor2_id_fkey FOREIGN KEY (motor2_id) REFERENCES eq_motor_tb(id),
	CONSTRAINT degradation_parameter_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id),
	CONSTRAINT fk_mission FOREIGN KEY (mission_id) REFERENCES mission_tb(id)
);