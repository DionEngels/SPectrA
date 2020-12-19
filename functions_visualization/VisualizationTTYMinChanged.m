function VisualizationTTYMinChanged(app, ~)
% Function triggered when you change the min_y for manual y-axis
% ---------------------
app.entry_y_axis_max.Limits = [app.entry_y_axis_min.Value Inf];
if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    if app.valid_hsm
        VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
    end
end
end