function res = convert_for_insert(vals)
    val_str = sprintf('%.2f, ', vals);
    val_str = val_str(1:end-2);
    val_str = sprintf('{%s}', val_str);
    res = convertCharsToStrings(val_str);
end