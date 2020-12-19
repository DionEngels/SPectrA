function VisualizationUpdateSingleValues(app, roi_number)
% updates the switch depending on the new particle
% ----------------------
% set switch
app.switch_single.Value = app.parent_app.file_results.(app.rois{roi_number}).SingleParticle;
% set lamp
if app.switch_single.Value == 1
    app.lamp_single.Color = 'Green';
else
    app.lamp_single.Color = 'Red';
end
end