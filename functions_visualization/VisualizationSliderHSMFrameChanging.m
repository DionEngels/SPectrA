function VisualizationSliderHSMFrameChanging(app, event)
% Function triggered when you change the HSM frame slider
% ---------------------
% update FOV HSM when moving the slider
app.slider_hsm_frame.Value = round(event.Value);
VisualizationUpdateFOVHSM(app, app.spinner_particle.Value)
end