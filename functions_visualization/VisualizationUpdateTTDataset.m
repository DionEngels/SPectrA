function VisualizationUpdateTTDataset(app, length_tt)
% set limit of frame slider, spinner, entry contrast, and
% min/max y-axis entries
% ----------------------
app.slider_frame.Limits = [1, length_tt];
app.spinner_frame.Limits = [1, length_tt];
app.entry_contrast_frame.Limits = [1, length_tt];
app.entry_ref_frame.Limits = [1, length_tt];
app.entry_contrast_frame.Value = length_tt;
if 200 > length_tt
    app.entry_ref_frame.Value = length_tt;
else
    app.entry_ref_frame.Value = 200;
end
app.entry_y_axis_max.Limits = [app.entry_y_axis_min.Value Inf];
app.entry_y_axis_min.Limits = [-Inf app.entry_y_axis_max.Value];
end