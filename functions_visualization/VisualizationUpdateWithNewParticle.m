function VisualizationUpdateWithNewParticle(app, roi_number)
% updates everything when a new particle is selected
% ----------------------
% set switches
VisualizationUpdateSingleValues(app, roi_number)

if app.valid_tt
    VisualizationUpdateTT(app, roi_number)
end

if app.valid_hsm
    VisualizationUpdateHSM(app, roi_number)
end

VisualizationUpdateFOVTT(app, roi_number)
VisualizationUpdateFOVHSM(app, roi_number)

end