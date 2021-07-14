function cols = get_column_names(conn, table_name)

    cols = table2array(select(conn, sprintf("select array(select ''''||column_name||'''' column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = '%s')", table_name)));
    cols = [string(cols{1}).replace('{', '').replace('}', '').replace('''', '').split(',')];

end

