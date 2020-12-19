function EditEraseClusters(app, ~)
% Function to erase all clusters
% ----------------------

rois = fieldnames(app.parent_app.file_results);
to_delete = {};
for k=1:numel(rois)
    
    % if not single particle
    if ~app.parent_app.file_results.(rois{k}).SingleParticle
        to_delete{end+1} = rois{k};
    end
end
app.parent_app.file_results = rmfield(app.parent_app.file_results, to_delete);
msgbox('Clusters deleted!','Success');
end