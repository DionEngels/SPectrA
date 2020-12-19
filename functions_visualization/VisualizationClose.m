function VisualizationClose(app, ~)
% Function to close window
% ----------------------
try
    HomeCloseChildApp(app.parent_app);
    try
        app.delete;
    catch
        
    end
catch
    app.delete;
end
end