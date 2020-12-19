function VisualizationUpdateHSM(app, roi_number)
% update everything related to HSM
% ----------------------
VisualizationDetermineSingleParticlesStandardSettings(app)
VisualizationUpdateHSMFrameSlider(app, roi_number)
VisualizationUpdateFOVHSM(app, roi_number)
VisualizationUpdateHSMPlot(app, roi_number, [])
VisualizationUpdateHSMFitData(app, roi_number)
% if there is a valid TT, also contrast
if app.valid_hsm && app.valid_tt
    VisualizationUpdateTTContrast(app, roi_number, false)
end
end