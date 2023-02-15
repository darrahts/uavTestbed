do $$	
	declare 

		airframe_type_id integer := (select id from asset_type_tb where "type" ilike 'airframe');	 
		battery_type_id integer := (select id from asset_type_tb where "type" ilike 'battery');
		motor_type_id integer := (select id from asset_type_tb where "type" ilike 'motor');
		esc_type_id integer := (select id from asset_type_tb where "type" ilike 'esc');
		gps_type_id integer := (select id from asset_type_tb where "type" ilike 'sensor');
		uav_type_id integer := (select id from asset_type_tb where "type" ilike 'uav');

		bat_cap_type integer := (select id from process_type_tb where subtype = 'battery' and subtype2 = 'capacitance');
		bat_res_type integer := (select id from process_type_tb where subtype = 'battery' and subtype2 = 'internal resistance');                                                           -- 
		mot_res_type integer := (select id from process_type_tb where subtype = 'motor' and subtype2 = 'internal resistance');
		esc_fail_type integer := (select id from process_type_tb where subtype = 'electronic speed controller' and subtype2 = 'abrupt onset');
		
		bat_cap_ps integer := (select randchoice(array(select id from process_tb where type_id = bat_cap_type and id > 17)));
		bat_res_ps integer := (select randchoice(array(select id from process_tb where type_id = bat_res_type and id > 17)));
		
		mot1_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot2_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot3_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot4_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot5_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot6_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot7_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		mot8_res_ps integer := (select randchoice(array(select id from process_tb where type_id = mot_res_type and id > 17)));
		
		esc1_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc2_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc3_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc4_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc5_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc6_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc7_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));
		esc8_res_ps integer := (select randchoice(array(select id from process_tb where type_id = esc_fail_type and id > 17)));

	begin
		insert into asset_tb("owner", "type_id", "process_id", "serial_number", "common_name")
			values (current_user, airframe_type_id, '{4}', (select upper(substr(md5(random()::text), 0, 7))), 'tarot airframe');
		
		insert into asset_tb("owner", "type_id", "process_id", "serial_number", "common_name", "eol", "units")
			values (current_user, battery_type_id, array[bat_cap_ps, bat_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot battery', 7000, 'amp-hours'),
				(current_user, motor_type_id, array[mot1_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot2_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot3_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot4_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot5_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot6_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot7_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, motor_type_id, array[mot8_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot motor', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc1_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc2_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc3_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc4_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc5_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc6_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc7_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, esc_type_id, array[esc8_res_ps], (select upper(substr(md5(random()::text), 0, 7))), 'tarot esc', 10000, 'amp-hours'),
				(current_user, gps_type_id, null, (select upper(substr(md5(random()::text), 0, 7))), 'tarot gps', 9999, 'hours');
		
		insert into asset_tb("owner", "type_id", "serial_number", "common_name")
			values 	(current_user, uav_type_id, (select upper(substr(md5(random()::text), 0, 7))), 'tarot t18 uav');
end $$;	


do $$
	declare 
		num_motors integer = 8;
		airframe_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'airframe') order by id desc limit 1);
		battery_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
		motor_ids integer[] = (array(select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'motor') order by id desc limit 8));
		esc_ids integer[] = (array(select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'esc') order by id desc limit 8));
		gps_id integer = (select id from  asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'sensor') order by id desc limit 1);
		uav_id integer := (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'uav') order by id desc limit 1);
	begin
		insert into airframe_tb ("id", "num_motors", "mass", "Jb", "cd", "Axy", "Axz", "Ayz", "l")
			values (airframe_id, num_motors, 10.66, '{0.2506,0.0, 0.0,     0.0, 0.2506, 0.0,   0.0, 0.0, 0.4538}', 1.0, 1.6129, 0.508, 0.508, .635);
		insert into eqc_battery_tb ("id", "Q", "EOD", "v", "v0", "RC", "soc_ocv") 
			values (battery_id, 22, 17.01, 22.2, 22.2, 14.25, '{"z_coef": [1.508751457102164e-11,3.858124930644635e-09,-2.019172143263859e-06,2.774710592348129e-04,-0.017479820176959,0.527755975723267,15.000000953674316]}');
		insert into dc_motor_tb ("id", "motor_number", "Req", "Ke_eq", "J", "cd", "ct", "cq", "cq2", "current_limit")
			values (motor_ids[1], 1, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[2], 2, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[3], 3, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[4], 4, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[5], 5, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[6], 6, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[7], 7, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38),
				   (motor_ids[8], 8, .27, .0265, .00005, .0000018503, .00022144, .000000016035, -.00001279, 38);
		insert into esc_tb ("id", "esc_number")
			values (esc_ids[1], 1),
				   (esc_ids[2], 2),
				   (esc_ids[3], 3),
				   (esc_ids[4], 4),
				   (esc_ids[5], 5),
				   (esc_ids[6], 6),
				   (esc_ids[7], 7),
				   (esc_ids[8], 8);
		insert into sensor_tb("id") values (gps_id);
		insert into uav_tb("id", 
				"airframe_id", 
				"battery_id", 
				"motors_id",
				"escs_id",
				"m1_id",
				"m2_id",
				"m3_id",
				"m4_id",
				"m5_id",
				"m6_id",
				"m7_id",
				"m8_id", 
				"gps_id",
				"max_flight_time")
			values (uav_id,
				airframe_id,
				battery_id,
				motor_ids,
				esc_ids,
				motor_ids[1],
				motor_ids[2],
				motor_ids[3],
				motor_ids[4],
				motor_ids[5],
				motor_ids[6],
				motor_ids[7],
				motor_ids[8],
				gps_id,
				25);	  
end $$;