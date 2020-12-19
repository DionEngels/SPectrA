function VisualizationUpdateHSMFrameSlider(app, roi_number)
% updates the HSM Frame slider whenever needed
% ----------------------
app.slider_hsm_frame.MajorTicks = 1:length(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths);
app.slider_hsm_frame.MinorTicks = [];
app.slider_hsm_frame.FontSize = 9;
app.slider_hsm_frame.MajorTickLabels = cellstr(num2str(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths(:)))';
app.slider_hsm_frame.Limits = [ 1 length(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)  ];
app.slider_hsm_frame.Value = round(length(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)/2);
end