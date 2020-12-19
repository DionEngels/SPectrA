function VisualizationSpinnerFrameChanged(app, event)
% Function triggered when TT frame spinner is changed
% ----------------------
% round value and update slider
app.spinner_frame.Value = round(event.Value);
app.slider_frame.Value = app.spinner_frame.Value;

if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    VisualizationUpdateFOVTT(app, app.spinner_particle.Value)
end

end