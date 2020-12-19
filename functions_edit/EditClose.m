function EditClose(app, ~)
% Function to close window
% ----------------------
try
    CloseChildApp(app.parent_app);
    delete(app)
catch
    delete(app)
end
end