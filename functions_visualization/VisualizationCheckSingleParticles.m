function VisualizationCheckSingleParticles(app)
% check if single particles present, otherwise
% turn of buttons
% ----------------------
single_counter = 0;
for k=1:numel(app.rois)
    single_counter = single_counter + app.parent_app.file_results.(app.rois{k}).SingleParticle;
end
if single_counter > 0
    app.button_show_single.Enable = 'on';
else
    app.button_show_single.Enable = 'off';
end
end