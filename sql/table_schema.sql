

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

drop table foresight_model_tb;

create table foresight_model_tb(
	id serial not null,
	parameter varchar(32) not null,
	size_mb float not null,
	lstm_layers int not null,
	dense_layers int not null,
	lookback_hours int not null,
	horizon_hours int not null,
	path_header varchar(256) not null,
	model_path varchar(128) not null,
	scaler_x_path varchar(128) not null,
	scaler_y_path varchar(128) not null,
	train_date date default now()::date,
	train_samples_start timestamptz not null,
	train_samples_end timestamptz not null,
	train_samples int not null,
	test_samples int not null,
	validate_samples int not null,
	test_score float not null,
	validate_score float not null,
	penalty float,
	min_delta float,
	patience int,
	batch_size int not null,
	validation_split float not null,
	dropout float not null,
	epochs int not null
);

--
--
--
--create table sensor_reading_tb(
--	dt timestamptz default now(),
--);
--
--
--
--create table twin_sim_params(
--	
--
--);
--
--
--create table battery_sensor_tb(
--	dt timestamptz default now(),
--	
--);



