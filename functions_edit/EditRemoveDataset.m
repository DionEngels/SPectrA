function EditRemoveDataset(app, ~)
% Functino to remove a single dataset for all ROIs
% ----------------------
rois = fieldnames(app.parent_app.file_results);
for k=1:numel(rois)
    % if holds selected dataset in the roi
    if isfield(app.parent_app.file_results.(rois{k}), app.list_datasets.Value)
        % take it out
        tmp_roi = app.parent_app.file_results.(rois{k});
        % remove data
        tmp_roi = rmfield(tmp_roi, app.list_datasets.Value);
        % re-add
        app.parent_app.file_results.(rois{k}) = tmp_roi;
    end
end
% update GUI
app.entry_new_name.Value = "";
app.parent_app.FindDatasets()
app.list_datasets.Items = app.parent_app.datasets_names;
app.parent_app.listbox_status.Value = app.parent_app.datasets_names;
end