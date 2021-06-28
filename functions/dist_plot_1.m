function ret_fig = dist_plot_1(dist_data, idx_vals, style)


    ret_fig = figure(randi(100000)); clf;
    ret_fig.Position = [0 0 500 300];
    hold on;
    plot(dist_data.(sprintf("flight_%d", idx_vals(1))){1}, dist_data.(sprintf("flight_%d", idx_vals(1))){2}, "DisplayName", "1st Flight");
    plot(dist_data.flight_25{1}, dist_data.flight_25{2}, "DisplayName", "25th Flight");
    plot(dist_data.flight_50{1}, dist_data.flight_50{2}, "DisplayName", "50th Flight");
    plot(dist_data.flight_73{1}, dist_data.flight_73{2}, "DisplayName", "75th Flight");
    plot(dist_data.(sprintf("flight_%d", idx_vals(5))){1}, dist_data.(sprintf("flight_%d", idx_vals(5))){2}, "DisplayName", "78th Flight");
    hold off;
    legend;
    
    if style == 'z'
        title("State of Charge Evolution");
        xlabel("Ending State of Charge (%)");
        ylabel("Probability (%)");
        x = [.71 .39];
        y = [.495 .495];
        annotation('arrow',x, y, 'linewidth', 3, 'Color', [170 170 170]/255);
        text(.439, 40.5, 'degradation over time', 'FontSize', 11, 'Color',[170 170 170]/255);
    elseif style == 'v'
        title("Output Voltage Evolution");
        xlabel("Ending Voltage (%)");
        ylabel("Probability (%)");
        %xlim([0 1]);
        x = [.71 .39];
        y = [.495 .495];
        annotation('arrow',x, y, 'linewidth', 3, 'Color', [170 170 170]/255);
        text(3.82, 6, 'degradation over time', 'FontSize', 11, 'Color',[170 170 170]/255); 
    
    elseif style == 'a'
        title("Position Error (Mean) Evolution");
        xlabel("Average Position Error (m)");
        ylabel("Probability (%)");
        yticklabels([0 10 20 30 40 50 60 70]);
        %xlim([0 1]);
        x = [.71 .39];
        y = [.495 .495];
        annotation('arrow',x, y, 'linewidth', 3, 'Color', [170 170 170]/255);
        text(1.219, 280, 'degradation over time', 'FontSize', 11, 'Color',[170 170 170]/255); 
 
    elseif style == 's'
        title("Position Error (Standard Deviation) Evolution");
        xlabel("Position Error Standard Deviation (m)");
        ylabel("Probability (%)");
        yticklabels([0 10 20 30 40 50 60 70]);
        %xlim([0 1]);
        x = [.71 .39];
        y = [.495 .495];
        annotation('arrow',x, y, 'linewidth', 3, 'Color', [170 170 170]/255);
        text(.661, 390, 'degradation over time', 'FontSize', 11, 'Color',[170 170 170]/255); 
    end
    
end

