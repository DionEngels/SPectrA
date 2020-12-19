function VisualizationTTFrame(app, ~)
% Function triggered when reference frame is changed
% ----------------------
if app.valid_tt && app.valid_hsm
    VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
end
end