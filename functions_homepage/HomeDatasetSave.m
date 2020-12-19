function HomeDatasetSave(app, ~)
% Function to save experiment
% ----------------------
app.status_saved.Color = 'Yellow';

tmp_struct = app.file_results;
save([app.file_dir '\Results_SPectrA.mat'], '-struct', 'tmp_struct', '-v7.3');
clear tmp_struct

app.status_saved.Color = 'Green';
end