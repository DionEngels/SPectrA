function VisualizationDriftCorrectionCheckbox(app, ~)
% Function triggered when you want to see the drift corrected
% results
% ---------------------
if app.checkbox_show_drift_correction.Value
    app.checkbox_drift_correction.Value = 0;
    warndlg('You only apply drift correction or show drift correction, not at the same time!','!! Warning !!')
end

if app.valid_tt
    VisualizationUpdateTTScatter(app, app.spinner_particle.Value)
end
end