function VisualizationDetermineSingleParticlesStandardSettings(app)
% Determines the standard settings for single particles. Different
% per dataset
% ----------------------
if app.valid_hsm
    % find the wavelengths used from a valid partilce
    for k=1:numel(app.rois)
        if isfield(app.parent_app.file_results.(app.rois{k}), app.name_hsm)
            wavelengths = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).wavelengths;
            break;
        end
    end
    % check all lambdas and linewidths
    lambdas = zeros(1, length(app.rois));
    linewidths = zeros(1, length(app.rois));
    for k=1:numel(app.rois)
        if isfield(app.parent_app.file_results.(app.rois{k}), app.name_hsm)
            lambdas(k) = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).lambda;
            if app.parent_app.file_results.(app.rois{k}).(app.name_hsm).linewidth < 500
                linewidths(k) = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).linewidth;
            end
        end
    end
    % filter to ensure within range of wavelengths used
    lambdas = lambdas(lambdas > wavelengths(1) & lambdas < wavelengths(end));
    linewidths = linewidths(lambdas > wavelengths(1) & lambdas < wavelengths(end));
    linewidths = linewidths(linewidths ~= 0);
    linewidths = linewidths(~isnan(linewidths));
    
    [linewidth_mean,linewidth_sigma] = normfit(linewidths);
    
    app.button_single_particles.Enable = 'on';
    app.entry_lambda_min.Value = double(wavelengths(1) + 5);
    app.entry_lambda_max.Value = double(wavelengths(end) - 5);
    app.entry_linewidth_max.Value = linewidth_mean+1.2*linewidth_sigma;
    app.entry_linewidth_min.Value = linewidth_mean-1.2*linewidth_sigma;
    app.entry_r2_min.Value = 0.9;
else
    % if no HSM, disable
    app.button_single_particles.Enable = 'off';
    app.entry_lambda_min.Value = 0;
    app.entry_lambda_max.Value = 0;
    app.entry_linewidth_max.Value = 0;
    app.entry_linewidth_min.Value = 0;
    app.entry_r2_min.Value = 0;
end

end