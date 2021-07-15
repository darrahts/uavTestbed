function tt = sync_telemetry_data(data_struct, sample_rate, time_vec)
%%
%       @brief: synchronizes a struct of timeseries data into a timetable.
%           This function works for first and second level structs. I.e.
%           main_struct
%               -> timeseries data here (or not here, doesnt matter)
%               -> another struct
%                    -> more timeseries (this is ok too)
%                    -> more timeseries (this is ok too)
%                    -x another struct (this is not ok)
%               -> another struct (this is ok, you get the idea)  
%
%       @params:
%           data_struct: the struct with the timeseries data
%           sample_rate: the sample rate in herts to interpolate to
%           time_vec: the time vector with which to resample to
%
%       @returns:
%           tt: the timetable of data
%
%%
    sample_interval = 1/sample_rate;
    vars = [];
    var_names = {};
    fn = fieldnames(data_struct);
    time_vec = [time_vec(1):sample_interval:time_vec(end)]';
    for k=1:numel(fn)
        % fprintf("field name: %s\n", fn{k})
        % fprintf("class: %s\n", class(data_struct.(fn{k})))
        if ~strcmp('struct', class(data_struct.(fn{k})))
            if strcmp('timeseries', class(data_struct.(fn{k})))
                data_struct_synced.(fn{k}) = resample(data_struct.(fn{k}), time_vec);
                vars = [vars, data_struct_synced.(fn{k}).Data];
                sz = size(data_struct_synced.(fn{k}).Data);
                if sz(2) > 1
                    for n = 1:sz(2)
                        % disp(fn{k})
                        var_names = [var_names, sprintf("%s-%d", fn{k},n)];
                    end
                else
                    var_names = [var_names, sprintf("%s", fn{k})];
                end
            end
        else
            params = fieldnames(data_struct.(fn{k}));
            for j = 1:length(params)
                % disp(params{j})
                % disp(data_struct.(fn{k}).(params{j}))
                % disp(class(data_struct.(fn{k}).(params{j})))
                data_struct_synced.(fn{k}).time = [time_vec(1):sample_interval:time_vec(end)]';
                data_struct_synced.(fn{k}).(params{j}) = resample(data_struct.(fn{k}).(params{j}), time_vec);
                if length(data_struct_synced.(fn{k}).(params{j})) > length(data_struct_synced.(fn{k}).time)
                    amt = length(data_struct_synced.(fn{k}).(params{j})) - length(data_struct_synced.(fn{k}).time);
                    data_struct_synced.(fn{k}).(params{j}) = data_struct_synced.(fn{k}).(params{j})(1:end-amt);
                end
                vars = [vars, data_struct_synced.(fn{k}).(params{j}).Data(:)];
                var_names = [var_names, sprintf("%s_%s", fn{k}, params{j})];
            end
        end
    end
    tt = array2timetable(vars, 'SampleRate', sample_rate, 'VariableNames', var_names);
end

