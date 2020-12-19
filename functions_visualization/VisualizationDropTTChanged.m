function VisualizationDropTTChanged(app, ~)
% Function to change value of TT dropdown
% ----------------------
% Load new TT
app.lamp_tt.Color = 'Yellow';
app.name_timetrace = app.drop_tt.Value;
% Change the plots
if app.valid_tt
    VisualizationUpdateTT(app, app.spinner_particle.Value)
end
app.lamp_tt.Color = 'Green';
end