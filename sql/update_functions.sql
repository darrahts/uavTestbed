--------------------------------------------------------
-- insert battery asset into db
do $$
	declare 
		battery_type_id integer := (select id from asset_type_tb where "type" ilike 'battery');
	begin
		insert into asset_tb("owner", "type_id", "process_id", "serial_number", "common_name", "eol", "units")
					values (current_user, battery_type_id, '{8, 10}', (select upper(substr(md5(random()::text), 0, 7))), 'tarot battery', 7000, 'amp-hours');
end $$


-- insert tarot battery component into db
do $$
	declare
		battery_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
	begin			
		insert into eqc_battery_tb ("id", "Q", "EOD", "v", "v0", "RC", "soc_ocv") 
					values (battery_id, 22, 17.01, 22.2, 22.2, 14.25, '{"z_coef": [1.508751457102164e-11,3.858124930644635e-09,-2.019172143263859e-06,2.774710592348129e-04,-0.017479820176959,0.527755975723267,15.000000953674316]}');
end $$
--------------------------------------------------------


--------------------------------------------------------
-- insert uav asset into db 
do $$
	declare 
		ser_num varchar(6) := '9E196B';
		uav_type_id integer := (select id from asset_type_tb where "type" ilike 'uav');
		vers integer := (select "version" from asset_tb where serial_number ilike ser_num) + 1;
		uav_id integer := (select "id" from asset_tb where serial_number ilike ser_num);
		
	begin
		insert into asset_tb("id", "owner", "type_id", "serial_number", "version", "common_name")
				values (uav_id, current_user, uav_type_id, ser_num, vers, 'tarot t18 uav');
end $$

-- insert uav component into component table
do $$
	declare 
		ser_num varchar(6) := '9E196B';
		uav_id integer := (select max("id") from asset_tb where serial_number ilike ser_num);
		batt_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
		vers integer := (select max("version") from asset_tb where id = uav_id);
		
	begin
		INSERT INTO uav_tb ("id", "version", 
					"airframe_id", 
					"battery_id", 
					"m1_id", "m2_id", "m3_id", "m4_id", 
					"m5_id", "m6_id", "m7_id", "m8_id", 
					"gps_id", 
					"max_flight_time", 
					"dynamics_srate", 
					"motors_id")  
		SELECT uav_id, vers, 
				"airframe_id", 
				batt_id, 
				"m1_id", "m2_id", "m3_id", "m4_id", 
				"m5_id", "m6_id", "m7_id", "m8_id", 
				"gps_id", 
				"max_flight_time", 
				"dynamics_srate", 
				"motors_id"
		  FROM uav_tb
		 WHERE id = uav_id and "version" = vers - 1;
end $$

