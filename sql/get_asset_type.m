function asset_type = get_asset_type(conn, type_name)
    asset_type_tb = sqlread(conn, 'asset_type_tb');
    asset_type_tb = asset_type_tb(strcmp(asset_type_tb.type, type_name),:);
    asset_type = table2struct(asset_type_tb);
    clear airframe_tb;
end

