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
	uav_id int4 references uav_tb(id),
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
	motor2_id int references eq_motor_tb(id),
	uav_id int4 NULL,
	CONSTRAINT mission_tb_dt_start_dt_stop_key UNIQUE (dt_start, dt_stop),
	CONSTRAINT mission_tb_pkey PRIMARY KEY (id),
	CONSTRAINT mission_tb_battery_id_fkey FOREIGN KEY (battery_id) REFERENCES eqc_battery_tb(id),
	CONSTRAINT mission_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);

alter table mission_tb add column motor2_id int references eq_motor_tb(id);


-- public.battery_sensor_tb definition

-- Drop table

 DROP TABLE public.battery_sensor_tb;

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
	--CONSTRAINT battery_sensor_tb_dt_v_z_r0_q_v_prime_v_hat_z_hat_z_bound_r_key UNIQUE (dt, v, z, r0, q, v_prime, v_hat, z_hat, z_bound, r0_hat, r0_bound, battery_id, uav_id, mission_id),
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

drop table battery_sensor_tb;


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


insert into eq_motor_tb(name, serial_number, motor_number, uav_id) 
	values
		('rc_standard', 'M001', 1, 1),
		('rc_standard', 'M002', 2, 1),
		('rc_standard', 'M003', 3, 1),
		('rc_standard', 'M004', 4, 1),
		('rc_standard', 'M005', 5, 1),
		('rc_standard', 'M006', 6, 1),
		('rc_standard', 'M007', 7, 1),
		('rc_standard', 'M008', 8, 1);
	
	drop table eq_motor_tb;
	
insert into uav_tb(name, serial_number) values('simulink_octocopter', 'X001');
	
	insert into eqc_battery_tb(name, serial_number, uav_id) values ('plett_discrete', 'B001', 1);



drop table degradation_parameter_tb ;

select * from degradation_parameter_tb dpt;



select * from uav_tb;
select * from eqc_battery_tb ebt ;
select * from eq_motor_tb emt ;

select * from battery_sensor_tb order by dt desc;
select * from mission_tb;
select * from flight_sensor_tb order by dt desc;









create extension if not exists timescaledb;


create table uav_tb(
	id serial primary key,
	name varchar(32),
	serial_number varchar(16) unique,
	ct float not null default .0000085486,
	cq float not null default .00000013678,
	mass float not null default 1.8,
	"Jb" float[9] not null default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"Jbinv" float[9] not null default '{23.31, 0.0, 0.0,  0.0, 23.31, 0.0,    0.0, 0.0, 13.369}',
	g float not null default 9.8,
	sampletime float not null default 0.025,
	cd float not null default 1.0, 
	"Axy" float not null default 0.04,
	"Axz" float not null default 0.04,
	"Ayz" float not null default 0.04,
	rho float not null default 1.2,
	lx float not null default 0.2,
	ly float not null default 0.2,
	lz float not null default 0.2,
	l float not null default .45
);

-- drop table uav_tb cascade;

insert into uav_tb(name, serial_number) values('simulink_octocopter', 'X001');




create table eqc_battery_tb(
	id serial primary key,
	name varchar(32) default 'default_battery',
	serial_number varchar(16) unique,
	age_hours float default 0.0,
	age_cycles integer default 0,
	status varchar(32) default 'GREEN',
	"Q" float not null default 15.0,
	"G" float not null default 163.4413,
	"M" float not null default 0.0092,
	"M0" float not null default 0.0019,
	"RC" float not null default 3.6572,
	"R" float not null default .00028283,
	"R0" float not null default -.0011,
	n float not null default 0.9987,
	"EOD" float not null default 3.04,
	z float not null default 1.0,
	"Ir" float not null default 0.0,
	h float not null default 0.0,
	v float not null default 4.2,
	v0 float not null default 4.2,
	dt float not null default 1.0,
	in_use boolean default '0',
	uav_id integer references uav_tb(id)
);

-- drop table eqc_battery_tb ;

insert into eqc_battery_tb(name, serial_number, uav_id) values ('plett_discrete', 'B001', 1);

-- select * from eqc_battery_tb where name ilike 'plett_discrete' and serial_number ilike 'B001' limit 1;


create table eq_motor_tb(
	id serial primary key,
	name varchar(32) default 'default_motor',
	serial_number varchar(16) unique not null,
	motor_number int not null,
	age_hours float default 0.0,
	status varchar(32) default 'GREEN',
	"Req" float default 0.2371,
	"Ke_eq" float default 0.0107,
	"J" float default 0.00002,
	"Df" float default 0.0,
	"cq" float default 0.00000013678,
	unique (serial_number, motor_number),
	uav_id integer references uav_tb(id)
);

drop table eq_motor_tb;

insert into eq_motor_tb(name, serial_number, motor_number, uav_id) 
	values
		('rc_standard', 'M001', 1, 1),
		('rc_standard', 'M002', 2, 1),
		('rc_standard', 'M003', 3, 1),
		('rc_standard', 'M004', 4, 1),
		('rc_standard', 'M005', 5, 1),
		('rc_standard', 'M006', 6, 1),
		('rc_standard', 'M007', 7, 1),
		('rc_standard', 'M008', 8, 1);
	
	
	select * from uav_tb ut where name ilike 'simulink_octocopter' and serial_number ilike 'x001' limit 1;
	

	select ebt.* from eqc_battery_tb ebt join uav_tb ut on ebt.uav_id = ut.id where ut."name" ilike 'simulink_octocopter';

	select emt.* from eq_motor_tb emt join uav_tb ut on emt.uav_id = ut.id where ut.serial_number ilike 'X001';

	select ebt.* from eqc_battery_tb ebt join uav_tb ut on ebt.uav_id = ut.id where ut.serial_number ilike 'X001' and ebt.serial_number ilike 'B001';

	select ut.* from uav_tb ut where serial_number ilike 'X001' limit 1;

select count(pd.*) from pg_catalog.pg_database pd where pd.datname ilike 'uavtestbed2' 

drop table model_tb;

create table model_tb(
	id serial not null,
	uav_id int references uav_tb(id) not null,
	active bool not null default true,
	path_header varchar(256) not null,
	model_path varchar(128) not null,
	scaler_x_path varchar(128) not null,
	scaler_y_path varchar(128) not null,
	test_score float not null,
	validate_score float not null,
	size_mb float not null,
	num_weights int not null,
	train_date date not null default now()::date,
	train_samples int not null,
	test_samples int not null,
	validate_samples int not null,
	batch_size int not null,
	validation_split float not null,
	dropout float not null,
	epochs int not null,
	penalty float,
	min_delta float,
	patience int,
	unique(uav_id, num_weights, train_samples, test_samples, validate_samples, batch_size, dropout, epochs)
);



update eqc_battery_tb set "R0" = .0011 where id = 2;




create extension if not exists timescaledb;


create table uav_tb(
	id serial primary key,
	name varchar(32),
	serial_number varchar(16) unique,
	ct double precision not null default .0000085486,
	cq double precision not null default .00000013678,
	mass double precision not null default 1.8,
	"Jb" float[9] not null default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"Jbinv" float[9] not null default '{23.31, 0.0, 0.0,  0.0, 23.31, 0.0,    0.0, 0.0, 13.369}',
	g double precision not null default 9.8,
	sampletime double precision not null default 0.025,
	cd double precision not null default 1.0, 
	"Axy" double precision not null default 0.04,
	"Axz" double precision not null default 0.04,
	"Ayz" double precision not null default 0.04,
	rho double precision not null default 1.2,
	lx double precision not null default 0.2,
	ly double precision not null default 0.2,
	lz double precision not null default 0.2,
	l double precision not null default .45
);

drop table uav_tb cascade;

insert into uav_tb(name, serial_number) values('simulink_octocopter', 'X001');




create table eqc_battery_tb(
	id serial primary key,
	name varchar(32) default 'default_battery',
	serial_number varchar(16) unique,
	age_hours double precision default 0.0,
	age_cycles integer default 0,
	status varchar(32) default 'GREEN',
	"Q" double precision not null default 15.0,
	"G" double precision not null default 163.4413,
	"M" double precision not null default 0.0092,
	"M0" double precision not null default 0.0019,
	"RC" double precision not null default 3.6572,
	"R" double precision not null default .00028283,
	"R0" double precision not null default -.0011,
	n double precision not null default 0.9987,
	"EOD" double precision not null default 3.04,
	z double precision not null default 1.0,
	"Ir" double precision not null default 0.0,
	h double precision not null default 0.0,
	v double precision not null default 4.2,
	v0 double precision not null default 4.2,
	dt double precision not null default 1.0,
	in_use boolean default '0',
	uav_id integer references uav_tb(id)
);

drop table eqc_battery_tb ;

insert into eqc_battery_tb(name, serial_number, uav_id) values ('plett_discrete', 'B001', 1);

-- select * from eqc_battery_tb where name ilike 'plett_discrete' and serial_number ilike 'B001' limit 1;


create table eq_motor_tb(
	id serial primary key,
	name varchar(32) default 'default_motor',
	serial_number varchar(16) unique not null,
	motor_number int not null,
	age_hours double precision default 0.0,
	status varchar(32) default 'GREEN',
	"Req" double precision default 0.2371,
	"Ke_eq" double precision default 0.0107,
	"J" double precision default 0.00002,
	"Df" double precision default 0.0,
	"cq" double precision default 0.00000013678,
	unique (serial_number, motor_number),
	uav_id integer references uav_tb(id)
);

drop table eq_motor_tb;

insert into eq_motor_tb(name, serial_number, motor_number, uav_id) 
	values
		('rc_standard', 'M001', 1, 1),
		('rc_standard', 'M002', 2, 1),
		('rc_standard', 'M003', 3, 1),
		('rc_standard', 'M004', 4, 1),
		('rc_standard', 'M005', 5, 1),
		('rc_standard', 'M006', 6, 1),
		('rc_standard', 'M007', 7, 1),
		('rc_standard', 'M008', 8, 1);
	
	
	select * from uav_tb ut where name ilike 'simulink_octocopter' and serial_number ilike 'x001' limit 1;
	

	select ebt.* from eqc_battery_tb ebt join uav_tb ut on ebt.uav_id = ut.id where ut."name" ilike 'simulink_octocopter';

	select emt.* from eq_motor_tb emt join uav_tb ut on emt.uav_id = ut.id where ut.serial_number ilike 'X001';

	select ebt.* from eqc_battery_tb ebt join uav_tb ut on ebt.uav_id = ut.id where ut.serial_number ilike 'X001' and ebt.serial_number ilike 'B001';

	select ut.* from uav_tb ut where serial_number ilike 'X001' limit 1;

select count(pd.*) from pg_catalog.pg_database pd where pd.datname ilike 'uavtestbed2' 

drop table model_tb;

create table model_tb(
	id serial not null,
	uav_id int references uav_tb(id) not null,
	active bool not null default true,
	path_header varchar(256) not null,
	model_path varchar(128) not null,
	scaler_x_path varchar(128) not null,
	scaler_y_path varchar(128) not null,
	test_score float not null,
	validate_score float not null,
	size_mb float not null,
	num_weights int not null,
	train_date date not null default now()::date,
	train_samples int not null,
	test_samples int not null,
	validate_samples int not null,
	batch_size int not null,
	validation_split float not null,
	dropout float not null,
	epochs int not null,
	penalty float,
	min_delta float,
	patience int,
	unique(uav_id, num_weights, train_samples, test_samples, validate_samples, batch_size, dropout, epochs)
);

drop table battery_sensor_tb ;
create table battery_sensor_tb(
	dt timestamptz(9) not null,
	v float not null,
	z float not null,
	r0 float not null,
	q float not null,
	v_prime float not null,
	v_hat float not null,
	z_hat float not null,
	z_bound float not null,
	r0_hat float not null,
	r0_bound float not null,
	battery_id int references eqc_battery_tb(id),
	uav_id int references uav_tb(id),
	mission_id int references mission_tb(id),
	unique(dt, v, z, r0, q, v_prime, v_hat, z_hat, z_bound, r0_hat, r0_bound, battery_id, uav_id, mission_id)
);

select create_hypertable('battery_sensor_tb', 'dt');

drop table battery_sensor_tb;

select id from mission_tb mt order by id desc limit 1;

select * from uav_tb;
select * from eqc_battery_tb ebt ;
select * from eq_motor_tb emt ;

select * from battery_sensor_tb order by dt desc;
select * from mission_tb;
select * from flight_sensor_tb order by dt desc;

delete from battery_sensor_tb bst where mission_id = 3;
delete from mission_tb mt where id = 3;

drop table mission_tb cascade;

create table mission_tb(
	id serial primary key,
	dt_start timestamptz not null,
	dt_stop timestamptz not null,
	trajectory_id int references trajectory_tb(id),
	stop_code int not null,
	prior_rul float not null,
	flight_time float not null,
	distance float not null,
	z_end float not null,
	v_end float not null,
	avg_pos_err float not null,
	max_pos_err float not null,
	std_pos_err float not null,
	avg_ctrl_err float not null,
	max_ctrl_err float not null,
	std_ctrl_err float not null,
	battery_id int references eqc_battery_tb(id),
	uav_id int references uav_tb(id),
	unique(dt_start, dt_stop)
);

drop table flight_sensor_tb ;
create table flight_sensor_tb(
	dt timestamptz not null,
	"current" float not null,
	x_ctrl_err float not null,
	y_ctrl_err float not null,
	pos_err float not null,
	x_pos float not null,
	y_pos float not null,
	z_pos float not null default 10.0,
	m2_res float,
	m4_res float,
	m5_res float,
	battery_id int references eqc_battery_tb(id),
	uav_id int references uav_tb(id),
	mission_id int references mission_tb(id)
);
select create_hypertable('flight_sensor_tb', 'dt');

select * from flight_sensor_tb;


SELECT EXTRACT(EPOCH FROM dt::timestamptz) from flight_sensor_tb;

--drop table flight_sensor_tb cascade;
--drop table battery_sensor_tb cascade;
--drop table mission_tb cascade;
--drop table degradation_parameter_tb;
create table degradation_parameter_tb(
	id serial primary key,
	mission_id int references mission_tb(id),
	q_deg float not null,
	q_var float not null,
	q_slope float,
	q_intercept float,
	r_deg float not null,
	r_var float not null,
	r_slope float,
	r_intercept float,
	m_deg float not null,
	m_var float not null,
	m_slope float,
	m_intercept float,
	battery_id int references eqc_battery_tb(id),
	motor2_id int references eq_motor_tb(id),
	uav_id int references uav_tb(id),
	unique(mission_id, q_deg, q_var, r_deg, r_var, m_deg, m_var, battery_id, motor2_id)
);


alter table degradation_parameter_tb add constraint fk_mission foreign key(mission_id) references mission_tb(id);

create table trajectory_tb(
	id serial primary key,
	path_distance float not null,
	path_time float not null,
	risk_factor float not null default .01,
	x_waypoints float[16] not null,
	y_waypoints float[16] not null,
	x_ref_points float[1280] not null,
	y_ref_points float[1280] not null,
	sample_time int not null default 1,
	reward float not null default 1.0,
	unique(path_distance, path_time, x_waypoints, y_waypoints, sample_time, reward)
 );

--drop table trajectory_tb ;

alter table trajectory_tb add column reward float default 1.0 not null;

select table_name from information_schema.tables where table_schema = 'public';


create user read_only with encrypted password 'Test1234!';

drop role readonly;


CREATE ROLE readonly WITH LOGIN PASSWORD 'Test1234!' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';

GRANT CONNECT ON DATABASE tsdb TO read_only;
GRANT USAGE ON SCHEMA public TO read_only;
GRANT SELECT ON table battery_sensor_tb to read_only;
GRANT SELECT ON table degradation_parameter_tb to read_only;
grant select on table eq_motor_tb to read_only;
grant select on table eqc_battery_tb to read_only;
grant select on table experiment_tb to read_only;
grant select on table flight_sensor_tb to read_only;
grant select on table mission_tb to read_only;
grant select on table model_tb to read_only;
grant select on table trajectory_tb to read_only;
grant select on table uav_tb to read_only;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO read_only;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO read_only;


select * from uav_tb ut;
select * from eqc_battery_tb ebt ;
select * from eq_motor_tb emt ;
select mt.* from mission_tb mt order by mt.dt_start desc;
select * from battery_sensor_tb bst order by dt desc;
select fst.* from flight_sensor_tb fst where mission_id = 674 order by dt desc;
select * from degradation_parameter_tb order by mission_id desc;
select count(mission_id) from twin_params_tb groorder by id desc;
select * from trajectory_tb;
select mt.dt_stop from mission_tb mt order by dt_stop desc limit 1;

select * from trajectory_tb where id = 20;

select * from trajectory_tb order by path_time desc;


--drop table experiment_tb;
create table experiment_tb(
	id serial primary key,
	mission_ids varchar(256),
	notes varchar(512),
	unique(mission_ids, notes)
);

select * from experiment_tb;

insert into experiment_tb (mission_ids, notes) values ('1-52', 'first experiment with degradation curves downsampled to about 100 missions. motor degradation was too high');
insert into experiment_tb (mission_ids, notes) values ('55-187', 'second experiment with motor degradation back to original (500 cycles) and battery degradation at half (180 cycles)');
insert into experiment_tb (mission_ids, notes) values ('188-319', 'third experiment exact repeat of second experiment');
insert into experiment_tb (mission_ids, notes) values ('320-451', '4th experiment, allowed for better rul updates - still seeing true system failures before digital twin failures');
insert into experiment_tb (mission_ids, notes) values ('452-526', 'failed to write flight data for mission 526, error during simulation, matlab crashed and the simulation restarted form scratch with a new experiment');
insert into experiment_tb (mission_ids, notes) values ('527-630', 'now simulating digital twin 4x and using mean values, includes random trajectory exploration of path > rul time, stopped before experiment finished');
insert into experiment_tb (mission_ids, notes) values ('631-762', 'simulating digital twin 4x, random trajectory exploration, digital twin does not inform true system, mission 742 (and others), why did true system fail when it had worse degradradation parameters than the digital twin? are there trajectories with higher crash rates? (trajectory 10)');
insert into experiment_tb (mission_ids, notes) values ('764-830', 'same as above, digital twin informs true system, but in some cases the true system still did exploration - computer restarted in the middle of the experiment')
-- notes - mission 742 (and others), why did true system fail when it had worse degradradation parameters than the digital twin?
-- are there trajectories with higher crash rates?
-- trajectory 10 results in position error violation with a high percentage rage whereas this is not the case with the twin

select tt.* from trajectory_tb tt;



--insert into trajectory_tb (x_waypoints) values ('{30, 200, 100, 410, 450, 201}');

--alter degradation_parameter_tb set q_var = round(q_var, 2);
select * from degradation_parameter_tb order by mission_id desc;

select * from mission_tb;

update table mission_tb add column experiment;

--drop table twin_params_tb ;

select * from twin_params_tb order by id desc;

create table twin_params_tb(
	id serial primary key,
	mission_id int references mission_tb(id),
	trajectory_id int references trajectory_tb(id),
	rul_hat float not null,
	flight_time float not null,
	distance float not null,
	v_end float not null,
	z_end float not null,
	avg_err float not null,
	q_deg float not null,
	r_deg float not null,
	m_deg float not null,
	stop1 int not null,
	stop2 int not null,
	stop3 int not null,
	uav_id int references uav_tb(id)
);


