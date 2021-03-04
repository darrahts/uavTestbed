


create table uav_tb(
	id serial primary key,
	name varchar(32),

);


create table component_tb(
	id serial primary key,
	name varchar(32) default 'default_uav',
	age_hours float default 0.0,
	age_missions integer default 0, 

);


create table battery_chemistry_tb(

);

create table battery_circuit_tb(
	id serial primary key,
	name varchar(32) default 'default_battery',
	serial_number varchar(16) unique,
	age_hours float default 0.0,
	age_cycles integer default 0,
	status varchar(32) default 'GREEN',
	Q float not null default 15.0,
	G float not null default 163.4413,
	M float not null default 0.0092,
	M0 float not null default 0.0019,
	RC float not null default 3.6572,
	R float not null default .00028283,
	R0 float not null default -.0011,
	n float not null default 0.9987,
	EOD float not null default 3.04,
	z float not null default 1.0,
	Ir float not null default 0.0,
	h float not null default 0.0,
	v float not null default 4.2,
	v0 float not null default 4.2,
	dt float not null default 1.0,
	uav_id integer references uav_tb(id)
);


create table motor_tb(


);



create table sensor_reading_tb(

);



create table twin_sim_params(
	


);