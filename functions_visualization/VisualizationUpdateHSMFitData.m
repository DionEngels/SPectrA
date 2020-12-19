function VisualizationUpdateHSMFitData(app, roi_number)
% updates the HSM self fit fields whenever needed
% ----------------------
if app.valid_hsm && isfield(app.parent_app.file_results.(app.rois{roi_number}), app.name_hsm) && ~isnan(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters(1))
    app.manual_fit_par1.Value = app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters(1);
    app.manual_fit_par2.Value = app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters(2);
    app.manual_fit_par3.Value = app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters(3);
    app.manual_fit_par4.Value = app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters(4);
    app.manual_fit_datapoints.Value = num2str(1:length(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths),'%1.0d ');
else
    app.manual_fit_par1.Value = 0;
    app.manual_fit_par2.Value = 0;
    app.manual_fit_par3.Value = 0;
    app.manual_fit_par4.Value = 0;
    app.manual_fit_datapoints.Value = '';
end
end