function VisualizationUpdateTT(app, roi_number)
% update everything related to TT
% ----------------------
VisualizationUpdateTTPlot(app, roi_number)
VisualizationUpdateTTScatter(app, roi_number)

% if there is a valid HSM, also contrast
if app.valid_tt && app.valid_hsm
    VisualizationUpdateTTContrast(app, roi_number, false)
end
end