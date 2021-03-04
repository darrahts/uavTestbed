

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
	uav_id integer references uav_tb(id)
);

-- drop table eqc_battery_tb ;

insert into eqc_battery_tb(name, serial_number, uav_id) values ('plett_discrete', 'B001', 1);

-- select * from eqc_battery_tb where name ilike 'plett_discrete' and serial_number ilike 'B001' limit 1;


--create table motor_tb(
--
--);
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



