function HomeCloseChildApp(app)
% Function to close child app
% ----------------------
app.child_app.delete
app.status_saved.Color = 'red';
end