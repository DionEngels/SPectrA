function VisualizationSpinnerParticleChanged(app, ~)
% Function that is triggered when new particle is selected
% ----------------------
% Update particle
VisualizationUpdateSwitch(app, app.spinner_particle.Value)
% Update dataset if need be
if app.valid_tt
    VisualizationUpdateTT(app, app.spinner_particle.Value)
end
if app.valid_hsm
    VisualizationUpdateHSM(app, app.spinner_particle.Value)
end
% update particle views
VisualizationUpdateFOVTT(app, app.spinner_particle.Value)
VisualizationUpdateFOVHSM(app, app.spinner_particle.Value)
end