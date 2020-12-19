function VisualizationSwitchSingleChanged(app, ~)
% Function triggered when particle status (single) is changed
% ----------------------
% Change value and light
app.parent_app.file_results.(app.rois{app.spinner_particle.Value}).SingleParticle = app.switch_single.Value;
if app.switch_single.Value
    app.lamp_single.Color = 'Green';
else
    app.lamp_single.Color = 'Red';
end
% check again if there are still single particles left
VisualizationCheckSingleParticles(app)

% update contrast plot if only single are shown
if app.valid_hsm && app.valid_tt && app.button_show_single.Value
    VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
end
end
