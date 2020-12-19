function VisualizationTTNormalize(app, ~)
% Function triggered when normalize is clicked
% ----------------------
if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
end
end