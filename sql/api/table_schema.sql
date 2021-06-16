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
        description here
*/
create table asset_tb(
    "id" serial primary key not null,
    "owner" varchar(32) not null,
    "type_id" int references asset_type_tb(id),
    "serial_number" varchar(32) unique,
    "age" float(16),
    "eol" float(16),
    "units" varchar(32)
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
	"Jb" float[9] not nullnull default '{0.0429, 0.0, 0.0,    0.0, 0.0429, 0.0,   0.0, 0.0, 0.0748}',
	"cd" float not null default 1.0,
	"Axy" float not null default 0.04,
	"Axz" float not null default 0.04,
	"Ayz" float not null default 0.04,
	"rho" float not null default 1.2,
	"lx" float not null default 0.2,
	"ly" float not null default 0.2,
	"lz" float not null default 0.2,
	"l" float not null default 0.45
);

/*
        description here
*/
create table public.dc_motor_tb(
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
	"R0" float not null default -0.0011,
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
	"motor1_id" int not null references asset_tb(id),
	"motor2_id" int not null references asset_tb(id),
	"motor3_id" int not null references asset_tb(id),
	"motor4_id" int references asset_tb(id),
	"motor5_id" int references asset_tb(id),
	"motor6_id" int references asset_tb(id),
	"motor7_id" int references asset_tb(id),
	"motor8_id" int references asset_tb(id),
	"max_flight_time" float not null default 18.0
);

/*
        description here
*/
create table trajectory_tb(
	"id" serial primary key,
	"path_distance" float not null,
	"path_time" float not null,
	"risk_factor" float not null default .01,
	"x_waypoints" float[16] not null,
	"y_waypoints" float[16] not null,
	"x_ref_points" float[1280] not null,
	"y_ref_points" float[1280] not null,
	"sample_time" int not null default 1,
	"reward" float not null default 1.0,
	unique(path_distance, path_time, x_waypoints, y_waypoints, sample_time, reward)
 );