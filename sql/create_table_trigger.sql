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
					)', new."type", new."subtype");
	return new;
end;
$trigger_create_table$ 
language plpgsql;

create or replace trigger trg_create_on_insert 
	after insert on test
	for each row
	execute procedure create_table();