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
	CONSTRAINT eq_motor_tb_serial_number_motor_number_key UNIQUE (serial_number, motor_number),
	CONSTRAINT eq_motor_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
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
	uav_id int4 NULL,
	CONSTRAINT eqc_battery_tb_pkey PRIMARY KEY (id),
	CONSTRAINT eqc_battery_tb_serial_number_key UNIQUE (serial_number),
	CONSTRAINT eqc_battery_tb_uav_id_fkey FOREIGN KEY (uav_id) REFERENCES uav_tb(id)
);