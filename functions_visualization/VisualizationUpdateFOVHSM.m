function VisualizationUpdateFOVHSM(app, roi_number)
% Creates / Updates the particle view
% ----------------------
% plot ROI
if app.valid_hsm && isfield(app.parent_app.file_results.(app.rois{roi_number}), app.name_hsm)
    imagesc(app.plot_hsm_fov, app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).raw(:, :, app.slider_hsm_frame.Value))
    app.plot_hsm_fov.XLim = [0.5 size(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).raw, 1)+0.5];
    app.plot_hsm_fov.YLim = [0.5 size(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).raw, 2)+0.5];
    colormap(app.plot_hsm_fov, "jet");
    colorbar(app.plot_hsm_fov);
else
    % clear it if not possible
    cla(app.plot_hsm_fov);
end
end