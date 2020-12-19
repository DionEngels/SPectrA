function VisualizationTTManualAxis(app, ~)
% Function triggered when asked to use manual axis
% ----------------------
if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    if app.valid_hsm
        VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
    end
end
end