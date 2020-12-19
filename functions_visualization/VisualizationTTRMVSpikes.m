function VisualizationTTRMVSpikes(app, ~)
% Function triggered when remove spikes is clicked
% ----------------------
if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    if app.valid_hsm
        VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
    end
end
end