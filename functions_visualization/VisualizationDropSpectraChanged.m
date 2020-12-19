function VisualizationDropSpectraChanged(app, ~)
% Function to change value of HSM dropdown
% ----------------------
app.lamp_spectra.Color = 'Yellow';
app.name_hsm = app.drop_spectra.Value;
app.lamp_spectra.Color = 'Green';
%Change the plots
if app.valid_hsm
    VisualizationUpdateHSM(app, app.spinner_particle.Value)
end
end