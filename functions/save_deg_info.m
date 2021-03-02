function save_deg_info(i, polys, R0i, Qi, RMi)

    S.(sprintf('polys_%d', i)) = polys;
    S.(sprintf('params_%d', i)) = [R0i Qi RMi];
    val1 = randi(12999);
    val2 = randi(8999);
    res = val1 + val2;
    name = num2str(res);
    sprintf('saving %d', i)
    save(sprintf('G:\\matlab\\deg_info\\%d_%s.mat', name, i), '-struct', 'S');
    clear S;


end

