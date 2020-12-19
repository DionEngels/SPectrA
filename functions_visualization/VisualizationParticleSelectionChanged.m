function VisualizationParticleSelectionChanged(app, ~)
% Function triggered when asked to use different particle to make images
% ----------------------
if app.valid_tt && app.valid_hsm
    VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
end
end