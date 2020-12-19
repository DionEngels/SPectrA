function VisualizationButtonDetermineSingleParticls(app, ~)
% Function triggered when you want to determine the single particles
% ---------------------
VisualizationDetermineSingleParticles(app)
VisualizationUpdateSingleValues(app, app.spinner_particle.Value)
% update contrast plot if only single are shown
if app.valid_hsm && app.valid_tt && app.button_show_single.Value
    VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
end

end