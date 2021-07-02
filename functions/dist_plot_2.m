function ret_fig = dist_plot_1(mean_vals, std_vals, style, earliest_failure)


    ret_fig = figure(randi(100000)); clf;
    ret_fig.Position = [0 0 500 300];

    x = [1:1:earliest_failure];
    upper1 = smoothdata(mean_vals+std_vals);
    lower1 = smoothdata(mean_vals-std_vals);
    upper = mean_vals+std_vals;
    lower = mean_vals-std_vals;
    
    hold on;
    x2 = [x fliplr(x)];
    inBetween = [upper' fliplr(lower')];
    fill(x2, inBetween, [.9 .9 .9]);
    bounds = plot(x, upper, 'Color', [.5 .5 .5], 'LineWidth', 1);
    avg = plot(x, mean_vals, 'm', 'LineWidth', 1);
    plot(x, lower, 'Color', [.5 .5 .5], 'LineWidth', 1);
    hold off;
    
    if style == 'z'
        title("State of Charge Distribution Over Time");
        xlabel("Flight Number");
        ylabel("Ending State of Charge (%)");
        legend([bounds avg], '95% CB', 'mean');
        
    elseif style == 'v'
        title("Output Voltage Distribution Over Time");
        xlabel("Flight Number");
        ylabel("Voltage (V)");
        legend([bounds avg], '95% CB', 'mean');
        
    elseif style == 'a'
        title("Mean Position Error Distribution Over Time");
        xlabel("Flight Number");
        ylabel("Euclidean Position Error (avg) (m)");
       
    elseif style == 's'
        title("Position Error Standard Deviation Distribution Over Time");
        xlabel("Flight Number");
        ylabel("Euclidean Position Error (std)(m)");

    end
    
end

