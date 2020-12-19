function VisualizationUpdateFOVTT(app, roi_number)
% Creates / Updates the particle view
% ----------------------
% plot ROI
if app.valid_tt && isfield(app.parent_app.file_results.(app.rois{roi_number}), app.name_timetrace)
    imagesc(app.plot_tt_fov, app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).raw(:,:, app.spinner_frame.Value))
    app.plot_tt_fov.XLim = [0.5 size(app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).raw, 1)+0.5];
    app.plot_tt_fov.YLim = [0.5 size(app.parent_app.file_results.(app.rois{roi_number}).(app.name_timetrace).raw, 2)+0.5];
    colormap(app.plot_tt_fov, "jet");
else
    % clear it if not possible
    cla(app.plot_tt_fov);
end
end