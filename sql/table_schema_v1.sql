-- public.eq_motor_tb definition

-- Drop table

-- DROP TABLE public.eq_motor_tb;

CREATE TABLE public.eq_motor_tb (
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
	CONSTRAINT eq_motor_tb_serial_number_motor_number_key UNIQUE (serial_number, motor_number)
);


-- public.uav_tb definition

-- Drop table

-- DROP TABLE public.uav_tb;

CREATE TABLE public.uav_tb (
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


-- public.eqc_battery_tb definition

-- Drop table

-- DROP TABLE public.eqc_battery_tb;

CREATE TABLE public.eqc_battery_tb (
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

-- DROP TABLE public.mission_tb;

CREATE TABLE public.mission_tb (
	id serial NOT NULL,
	dt_start timestamptz NOT NULL,
	dt_stop timestamptz NOT NULL,
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
	CONSTRAINT mission_tb_dt_start_dt_stop_key UNIQUE (dt_start, dt_stop),
	CONSTRAINT mission_tb_pkey PRIMARY KEY (id),
	CONSTRAINT mission_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT mission_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);


-- public.battery_sensor_tb definition

-- Drop table

-- DROP TABLE public.battery_sensor_tb;

CREATE TABLE public.battery_sensor_tb (
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
SELECT create_hypertable('battery_sensor_tb', 'dt');

-- public.degradation_parameter_tb definition

-- Drop table

-- DROP TABLE public.degradation_parameter_tb;

CREATE TABLE public.degradation_parameter_tb (
	id serial NOT NULL,
	mission_id int4 NULL,
	q_deg float8 NOT NULL,
	q_var float8 NOT NULL,
	r0_deg float8 NOT NULL,
	r0_var float8 NOT NULL,
	req_deg float8 NOT NULL,
	req_var float8 NOT NULL,
	battery_id int4 NULL,
	motor2_id int4 NULL,
	CONSTRAINT degradation_parameter_tb_mission_id_q_deg_q_var_r0_deg_r0_v_key UNIQUE (mission_id, q_deg, q_var, r0_deg, r0_var, req_deg, req_var, battery_id, motor2_id),
	CONSTRAINT degradation_parameter_tb_pkey PRIMARY KEY (id),
	CONSTRAINT degradation_parameter_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT degradation_parameter_tb_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES mission_tb(id),
	CONSTRAINT degradation_parameter_tb_motor2_id_fkey FOREIGN KEY (motor2_id) REFERENCES eq_motor_tb(id)
);


-- public.flight_sensor_tb definition

-- Drop table

-- DROP TABLE public.flight_sensor_tb;

CREATE TABLE public.flight_sensor_tb (
	dt timestamptz NOT NULL,
	"current" float8 NOT NULL,
	x_ctrl_err float8 NOT NULL,
	y_ctrl_err float8 NOT NULL,
	pos_err float8 NOT NULL,
	x_pos float8 NOT NULL,
	y_pos float8 NOT NULL,
	z_pos float8 NOT NULL DEFAULT 10.0,
	m2_res float8 NULL,
	m4_res float8 NULL,
	m5_res float8 NULL,
	battery_id int4 NULL,
	uav_id int4 NULL,
	mission_id int4 NULL,
	CONSTRAINT flight_sensor_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT flight_sensor_tb_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES mission_tb(id),
	CONSTRAINT flight_sensor_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);
CREATE INDEX flight_sensor_tb_dt_idx ON public.flight_sensor_tb USING btree (dt DESC);
SELECT create_hypertable('flight_sensor_tb', 'dt');




-- public.model_tb definition

-- Drop table

-- DROP TABLE public.model_tb;

CREATE TABLE public.model_tb (
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
