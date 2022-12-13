create or replace function create_table() 
returns trigger as $trg_create_table$
begin 
	execute format('create table if not exists %s_%s_tb(
							    "id" serial not null,
    							"version" int not null default 1,
								"params" json default ''{}'',
								unique("id", "version"),
								primary key ("id", "version"),
								foreign key (id, "version") references asset_tb("id", "version")
					)', new."subtype", new."type");
	return new;
end;
$trg_create_table$ 
language plpgsql;

create or replace trigger trg_create_on_asset_type 
	after insert on asset_type_tb
	for each row
	execute procedure create_table();