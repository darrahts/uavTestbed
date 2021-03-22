
conn = database('uavtestbed2', 'postgres', get_password('#4KRx39Dn@09'));

db_api.view_tables    = "select table_name from information_schema.tables where table_schema = 'public'";

db_api.get_uavs       = "select * from uav_tb;";
db_api.get_batteries  = "select * from eqc_battery_tb;";
db_api.get_motors     = "select * from eq_motor_tb;";

db_api.get_battery = "select ebt.* from eqc_battery_tb ebt join uav_tb ut on ebt.uav_id = ut.id where ut.serial_number ilike '%s' and ebt.serial_number ilike '%s';";
db_api.get_motors  = "select emt.* from eq_motor_tb emt join uav_tb ut on emt.uav_id = ut.id where ut.serial_number ilike 'X001';";

db_api.get_uav        = "select ut.* from uav_tb ut where serial_number ilike '%s' limit 1;";
%db_api.get_battery    = "select * from eqc_battery_tb where name ilike '%s' and serial_number ilike '%s' limit 1;";
db_api.get_motor      = "select * from eq_motor_tb where name ilike '%s' and serial_number ilike '%s' limit 1;";


