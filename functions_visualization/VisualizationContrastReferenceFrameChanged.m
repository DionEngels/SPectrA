function VisualizationContrastReferenceFrameChanged(app, ~)
% Function triggered when you change the contrast reference frame
% ---------------------
if app.valid_tt && app.valid_hsm
    VisualizationUpdateTTContrast(app, app.spinner_particle.Value, false)
end
end