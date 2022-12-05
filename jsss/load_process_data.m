
process_type = 'degradation';
description = 'continuous';
process_tb = select(conn, eval(api.matlab.process.LOAD_ALL_PROCESSES));
process_tb = process_tb(contains(string(process_tb.description), description),:);
proc_tb = process_tb(contains(string(process_tb.subtype), 'battery'), :);
proc_tb = proc_tb((contains(string(proc_tb.description), "v3") & contains(string(proc_tb.subtype2), "capacitance")) | (contains(string(proc_tb.description), "v2") & contains(string(proc_tb.subtype2), "resistance")),:);
for i = 1:height(proc_tb)
    params = proc_tb(i, 'parameters').parameters{1};
    res = jsondecode(string(params));
    uav.battery.(sprintf("%s",string(fieldnames(res)))) = res.(sprintf("%s", string(fieldnames(res))))';
end
proc_tb =  process_tb(contains(string(process_tb.subtype), 'motor'), :);
for i = 1:height(proc_tb)
    params = proc_tb(i, 'parameters').parameters{1};
    res = jsondecode(string(params));
    uav.motors(i).(sprintf("%s",string(fieldnames(res)))) = res.(sprintf("%s", string(fieldnames(res))))';
end
process_type = 'environment';
process_tb = select(conn, eval(api.matlab.process.LOAD_ALL_PROCESSES));
for i = 1:height(process_tb)
    params = process_tb(i, 'parameters').parameters{1};
    res = jsondecode(string(params));
    fn = fieldnames(res);
    for j = 1:length(fn)
        processes.(sprintf("%s", process_type)).(sprintf("%s", process_tb(i, 'subtype').subtype{1})).(sprintf("%s", process_tb(i, 'subtype2').subtype2{1})).(sprintf("%s", fn{j})) = res.(fn{j});
    end
end

clear(description', 'i', 'j', 'params', 'proc_tb', 'process_tb', 'process_type', 'res', 'fn');