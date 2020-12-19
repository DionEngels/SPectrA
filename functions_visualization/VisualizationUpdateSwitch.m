function VisualizationUpdateSwitch(app, roi_number)
% Updates the switch and its lights for a roi number
% ----------------------
% change single value and light
app.switch_single.Value = app.parent_app.file_results.(app.rois{roi_number}).SingleParticle;
if app.switch_single.Value
    app.lamp_single.Color = 'Green';
else
    app.lamp_single.Color = 'Red';
end
end