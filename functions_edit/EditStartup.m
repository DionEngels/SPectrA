function EditStartup(app, mainapp)
% Start up
% ----------------------
app.parent_app = mainapp;
clear mainapp;

app.list_datasets.Items = app.parent_app.datasets_names;

% disable button if need be
rois = fieldnames(app.parent_app.file_results);
if isfield(app.parent_app.file_results.(rois{1}), 'SingleParticle')
    app.button_erase_all_clusters.Enable = 'On';
else
    warndlg('Single particles unknown at the moment, button disabled!','!! Warning !!')
    app.button_erase_all_clusters.Enable = 'Off';
end
end