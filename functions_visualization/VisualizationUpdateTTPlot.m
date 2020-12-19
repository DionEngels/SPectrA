function VisualizationUpdateTTPlot(app, roi_number)
% Creates / Updates the intensity plot of a TT
% ----------------------

if isfield(app.parent_app.file_results.(app.rois{roi_number}), app.name_timetrace)
    try
        app.tt_to_plot = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).result(:, 4);
    catch
        % if this row does not exist, you cannot plot it
        cla(app.plot_tt);
        return;
    end
    
    % do outlier rejection if desired
    if app.button_rmv_spikes.Value
        app.tt_to_plot = hampel(app.tt_to_plot, 5);
    end
    
    % normalize if desired
    if app.button_normalize.Value
        ref = nanmean(app.tt_to_plot);
        app.tt_to_plot = app.tt_to_plot ./ ref;
    end
    
    % Update values / slider / spinnners
    VisualizationUpdateTTDataset(app, length(app.tt_to_plot))
    
    % updating time
    time_axis = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).time_axis;
    if strcmp(app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).time_axis_dim, 't')
        app.field_time.Value = time_axis(app.spinner_frame.Value);
        app.plot_tt.XLabel.String = 'Time (s)';
    else
        app.field_time.Value = 'No time';
        app.plot_tt.XLabel.String = 'Frames';
    end
    
    % Plotting the timetrace
    cla(app.plot_tt)
    hold(app.plot_tt,'on')
    plot(app.plot_tt, time_axis(1:app.spinner_frame.Value), app.tt_to_plot(1:app.spinner_frame.Value),'-','color', [1 0 0]);
    plot(app.plot_tt, time_axis(app.spinner_frame.Value:end), app.tt_to_plot(app.spinner_frame.Value:end),'-','color', [1 0.5 0.5]);
    app.plot_tt.Title.String = app.name_timetrace;
    set(app.plot_tt.Title,'Interpreter','none');
    app.plot_tt.XLim = [time_axis(1)  time_axis(end)];
    
    % set y limits
    if app.button_manual_y_axis.Value == 1
        app.plot_tt.YLim = [app.entry_y_axis_min.Value  app.entry_y_axis_max.Value ];
    else
        app.plot_tt.YLim = [-Inf Inf];
    end
else
    cla(app.plot_tt);
end
end