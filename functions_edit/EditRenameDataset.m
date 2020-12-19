function EditRenameDataset(app, ~)
% Functino to rename a single dataset for all ROIs
% ----------------------
new_name = app.entry_new_name.Value;
if strtrim(new_name) ~= ""
    if isvarname(new_name)
        rois = fieldnames(app.parent_app.file_results);
        for k=1:numel(rois)
            % if holds selected dataset in the roi
            if isfield(app.parent_app.file_results.(rois{k}), app.list_datasets.Value)
                % take it out
                tmp_roi = app.parent_app.file_results.(rois{k});
                % take data out
                tmp_data = tmp_roi.(app.list_datasets.Value);
                % remove data
                tmp_roi = rmfield(tmp_roi, app.list_datasets.Value);
                % re-add
                tmp_roi.(new_name) = tmp_data;
                app.parent_app.file_results.(rois{k}) = tmp_roi;
            end
        end
    else
        warndlg('Invalid name. Check MATLAB requirements for variable names!','!! Warning !!')
    end
end
% update GUI
app.entry_new_name.Value = "";
HomeFindDatasets(app.parent_app)
app.list_datasets.Items = app.parent_app.datasets_names;
app.parent_app.listbox_status.Value = app.parent_app.datasets_names;
end