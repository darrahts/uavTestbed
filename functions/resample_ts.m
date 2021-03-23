function ts = resample_ts(ts, sample_rate, start)


    stop = start + seconds(ts.Time(end, 1));
    time_vec = [start: seconds(sample_rate) : stop]';
    time_vec.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
    time_vec = cellstr(time_vec);
    ts.TimeInfo.StartDate = time_vec(1);
    ts.TimeInfo.Format = 'uuuu-MM-dd HH:mm:ss.SSS';
    ts = resample(ts, time_vec, 'linear');


end

