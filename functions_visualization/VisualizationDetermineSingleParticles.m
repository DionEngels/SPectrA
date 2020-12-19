function VisualizationDetermineSingleParticles(app)
% Find the single particles based on the settings. Triggered when
% loading on click on button
if app.valid_hsm
    for k=1:numel(app.rois)
        if isfield(app.parent_app.file_results.(app.rois{k}), app.name_hsm)
            %tmp copy
            lambda = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).lambda;
            lw = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).linewidth;
            r2 = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).R2;
            % determine single or not
            if lambda > app.entry_lambda_min.Value && lambda < app.entry_lambda_max.Value && lw > app.entry_linewidth_min.Value && lw < app.entry_linewidth_max.Value && r2 > app.entry_r2_min.Value
                app.parent_app.file_results.(app.rois{k}).SingleParticle = 1;
            else
                app.parent_app.file_results.(app.rois{k}).SingleParticle = 0;
            end
        else
            % if not in HSM, not single
            app.parent_app.file_results.(app.rois{k}).SingleParticle = 0;
        end
        
    end
else
    % if no HSM, all single
    for k=1:numel(app.rois)
        app.parent_app.file_results.(app.rois{k}).SingleParticle = 1;
    end
end
end