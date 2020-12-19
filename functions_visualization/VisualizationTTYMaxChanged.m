function VisualizationTTYMaxChanged(app, ~)
% Function triggered when you change the max_y for manual y-axis
% ---------------------
app.entry_y_axis_min.Limits = [-Inf app.entry_y_axis_max.Value];
if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    if app.valid_hsm
        VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
    end
end
end