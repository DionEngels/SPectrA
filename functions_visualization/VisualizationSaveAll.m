function VisualizationSaveAll(app, ~)
% Function triggered when saving all particles is asked
% ----------------------
for k=1:numel(app.rois)
    TTPageSaveParticle(app.parent_app.file_dir, app.parent_app.file_results.(app.rois{k}), app.valid_tt, app.name_timetrace, app.valid_hsm, app.name_hsm, app.parent_app.file_metadata)
end
end