function VisualizationSliderFrameChanging(app, event)
% Function triggered when TT frame slider is moved
% ----------------------
% round value and update spinnner
app.slider_frame.Value = round(event.Value);
app.spinner_frame.Value = app.slider_frame.Value;

if app.valid_tt
    VisualizationUpdateTTPlot(app, app.spinner_particle.Value)
    VisualizationUpdateFOVTT(app, app.spinner_particle.Value)
end
end