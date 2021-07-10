/*
	Add some default asset types (i.e. types that we have models implemented for)
*/
insert into asset_type_tb("type", "subtype", "description")
	values ('airframe', 'octorotor', 'osmic_2016'),
		   ('battery', 'discrete-eqc', 'plett_2015'),
		   ('motor', 'dc', 'generic'),
		   ('uav', '-', '-');


/*
	Create a uav
		1: insert the asset information first with a 6 digit random serial number (make it whatever you want)
		2: then create the derived component model record entries
*/
do $$	
declare 
	airframe_type_id integer := (select id from asset_type_tb where "type" ilike 'airframe');	 
	battery_type_id integer := (select id from asset_type_tb where "type" ilike 'battery');
	motor_type_id integer := (select id from asset_type_tb where "type" ilike 'motor');
	uav_type_id integer := (select id from asset_type_tb where "type" ilike 'uav');
 begin
insert into asset_tb("owner", "type_id", "serial_number")
	values (current_user, airframe_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, battery_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, motor_type_id, (select upper(substr(md5(random()::text), 0, 7)))),
		   (current_user, uav_type_id, (select upper(substr(md5(random()::text), 0, 7))));
end $$;	

do $$
declare num_motors integer = 8;
	    airframe_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'airframe') order by id desc limit 1);
	    battery_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
	    motor_ids integer[] = (array(select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'motor') order by id desc limit 8));
begin
	insert into default_airframe_tb ("id", "num_motors")
		values (airframe_id, num_motors);
	insert into eqc_battery_tb ("id")
		values (battery_id);
	insert into dc_motor_tb (id)
		values (motor_ids[1]),
			   (motor_ids[2]),
			   (motor_ids[3]),
			   (motor_ids[4]),
			   (motor_ids[5]),
			   (motor_ids[6]),
			   (motor_ids[7]),
			   (motor_ids[8]);
end $$;
