function HomeFindDatasets(app)
% Function to find all datasets within a loaded experiment
% ----------------------
% find a ROI with the most datasets in it
rois = fieldnames(app.file_results);
n_datasets_max = 0;
n_datasets_max_index = -1;
for i=1:size(rois)
    n_datasets = length((fieldnames(app.file_results.(rois{i}))));
    if n_datasets > n_datasets_max
        n_datasets_max = n_datasets;
        n_datasets_max_index = i;
    end
end
% find datasets
datasets = app.file_results.(['ROI_' int2str(n_datasets_max_index)]);
% remove x, y and index (those are ROI specific, not results)
fields = ["index", "x", "y"];
datasets = rmfield(datasets, fields);
% remove SingleParticle if there
try
    datasets = rmfield(datasets, "SingleParticle");
catch
    % if not there, do not remove
end

% make list of TTs and HSMs
app.datasets_names = fieldnames(datasets);

% find tts
app.tts = {};
app.hsms = {};
for i=1:numel(app.datasets_names)
    if strcmp(datasets.(app.datasets_names{i}).type, 'TT')
        app.tts{end+1} = app.datasets_names{i};
    elseif strcmp(datasets.(app.datasets_names{i}).type, 'HSM')
        app.hsms{end+1} = app.datasets_names{i};
    end
end
end