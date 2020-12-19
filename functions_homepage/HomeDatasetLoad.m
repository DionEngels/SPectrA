function HomeDatasetLoad(app, ~)
% Function to load in experiment
% ----------------------
% saved to red
app.status_saved.Color = 'Red';

% check if already loaded in results
if isempty(app.file_results) == 0
    answer = questdlg('This will erase the currently loaded in experiment. Are you sure?', ...
        'Currently loaded experiment will be cleared', ...
        'Yes', 'No', 'Yes');
    switch answer
        case 'Yes'
            app.listbox_status.Value = '';
            app.file_results = [];
            app.file_metadata = [];
        case 'No'
            return
    end
end

app.status_loaded.Color = 'Yellow';

% check if user clicked folder
[tmp_filename, tmp_pathname] = uigetfile({'*.mat';'*.*'},'Select results to load in. This can be both PLASMON as SPectrA results');
% prevent minimizing
app.UIFigure.Visible = 'off';
app.UIFigure.Visible = 'on';
drawnow;
figure(app.UIFigure)
if all(tmp_pathname == 0)
    app.status_loaded.Color = 'Red';
    warndlg('You have to specify a file!','!! Warning !!')
    return
end
drawnow;
figure(app.UIFigure)

% check valid directory
if ~exist([tmp_pathname '\Metadata.mat'], 'file')
    app.status_loaded.Color = 'Red';
    warndlg('Metadata.mat missing from directory, cannot be loaded! It has to be named Metadata.mat!','!! Warning !!')
    return
end

% set variables for new dataset
app.label_dir.Text = tmp_pathname;
app.file_dir = tmp_pathname;
app.filename = tmp_filename;
app.load_last_dir = tmp_pathname;
split_filename = split(app.file_dir,'\');
app.label_filename.Text = split_filename(end-1);

% load data
app.file_results = load([app.file_dir '\' app.filename]);
app.file_metadata = load([ app.file_dir '\Metadata.mat']);

% sort the ROIs by 1, 2, 3 ... (not ascii based, which matlab
% saves as)
fields = fieldnames(app.file_results);
fields = split(fields, '_');
fields = cellfun(@str2num, fields(:, 2));
[~, field_sorted] = sort(fields);
app.file_results = orderfields(app.file_results, field_sorted);

% find datasets
HomeFindDatasets(app);

% update listbox
app.listbox_status.Value = app.datasets_names;

% update buttons
app.status_loaded.Color = 'Green';
set(app.button_edit, 'Enable','on')
set(app.button_save, 'Enable','on')
set(app.button_visualization, 'Enable','on')
end