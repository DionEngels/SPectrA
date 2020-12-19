function VisualizationUpdateTTScatter(app, roi_number)
% Creates / Updates the scatter of the fits
% ----------------------
% Check if drift correction or show drift correction desired
try
    if app.checkbox_drift_correction.Value
        to_plot_x = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).result_post_drift(:, 2);
        to_plot_y = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).result_post_drift(:, 3);
    elseif app.checkbox_show_drift_correction.Value
        to_plot_x = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).drift(:, 1);
        to_plot_y = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).drift(:, 2);
    else
        to_plot_x = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).result(:, 2);
        to_plot_y = app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).result(:, 3);
    end
    
    scatter(app.plot_scatter,to_plot_x,to_plot_y,'r.');
    % set axis labels
    if strcmp(app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).dimension, 'nm')
        app.plot_scatter.XLabel.String = '(nm)';
    else
        app.plot_scatter.XLabel.String = '(pixels)';
    end
catch
    cla(app.plot_scatter);
end

end