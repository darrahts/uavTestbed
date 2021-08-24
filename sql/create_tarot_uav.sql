do $$	
	declare 
		airframe_type_id integer := (select id from asset_type_tb where "type" ilike 'airframe');	 
		battery_type_id integer := (select id from asset_type_tb where "type" ilike 'battery');
		motor_type_id integer := (select id from asset_type_tb where "type" ilike 'motor');
		uav_type_id integer := (select id from asset_type_tb where "type" ilike 'uav');
	begin
		insert into asset_tb("owner", "type_id", "serial_number", "common_name")
		values (current_user, airframe_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot airframe'),
		
			(current_user, battery_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot battery'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor'),
			(current_user, uav_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot t18 uav');
end $$;	


do $$
	declare 
		num_motors integer = 8;
		airframe_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'airframe') order by id desc limit 1);
		battery_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
		motor_ids integer[] = (array(select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'motor') order by id desc limit 8));
		uav_id integer := (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'uav') order by id desc limit 1);
	begin
		insert into default_airframe_tb ("id", "num_motors", "mass", "Jb", "cd", "Axy", "Axz", "Ayz", "l")
			values (airframe_id, num_motors, 10.66, '{0.2506,0.0, 0.0,     0.0, 0.2506, 0.0,   0.0, 0.0, 0.4538}', 1.0, 1.6129, 0.508, 0.508, .635);
		insert into eqc_battery_tb ("id", "Q", "EOD", "v", "v0", "RC") 
			values (battery_id, 22, 17.01, 22.2, 22.2, 14.25);
		insert into dc_motor_tb ("id", "motor_number", "Req", "Ke_eq", "J", "cd", "ct", "cq", "cq2", "current_limit")
			values (motor_ids[1], 1, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[2], 2, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[3], 3, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[4], 4, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[5], 5, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[6], 6, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[7], 7, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38),
				   (motor_ids[8], 8, .27, .0265, .00005, .0000018503, .000098419, .00000002138, -.00001279, 38);
		insert into uav_tb("id", 
				"airframe_id", 
				"battery_id", 
				"m1_id",
				"m2_id",
				"m3_id",
				"m4_id",
				"m5_id",
				"m6_id",
				"m7_id",
				"m8_id", 
				"max_flight_time")
			values (uav_id,
				airframe_id,
				battery_id,
				motor_ids[1],
				motor_ids[2],
				motor_ids[3],
				motor_ids[4],
				motor_ids[5],
				motor_ids[6],
				motor_ids[7],
				motor_ids[8],
				14.9);	  
end $$;