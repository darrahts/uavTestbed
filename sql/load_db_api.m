

conn = database('uavtestbed2', 'postgres', get_password('#4KRx39Dn@09'));

db_api.view_tables   = "select table_name from information_schema.tables where table_schema = 'public'";

db_api.get_uavs      = "select * from uav_tb;";
db_api.get_batteries = "select * from eqc_battery_tb;";
db_api.get_motors    = "select * from eq_motor_tb;";

db_api.get_uav       = "select * from uav_tb ut where name ilike '%s' and serial_number ilike '%s' limit 1;";
db_api.get_battery   = "select * from eqc_battery_tb where name ilike '%s' and serial_number ilike '%s' limit 1;";
db_api.get_motor     = "select * from eq_motor_tb where name ilike '%s' and serial_number ilike '%s' limit 1;";
