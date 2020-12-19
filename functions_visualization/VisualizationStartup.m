function VisualizationStartup(app, mainapp)
% Start up
% ----------------------
app.parent_app = mainapp;
clear mainapp;
app.lamp_tt.Color = 'Red';
app.lamp_spectra.Color = 'Red';
app.rois = fieldnames(app.parent_app.file_results);

% set dropdowns
app.drop_tt.Items = app.parent_app.tts;
app.drop_spectra.Items = app.parent_app.hsms;

% if cannot set dropdown, this means that there is no valid
% TT/HSM present, will skip steps accordingly
try
    app.name_timetrace = app.drop_tt.Items{1};
    app.valid_tt = true;
catch
    app.name_timetrace = '';
    app.valid_tt = false;
end
try
    app.name_hsm = app.drop_spectra.Items{1};
    app.valid_hsm =  true;
catch
    app.name_hsm = '';
    app.valid_hsm = false;
end

% if SingleParticle does not exist, create it
% (and set all single particles to 1)
if ~isfield(app.parent_app.file_results.(app.rois{1}), 'SingleParticle')
    VisualizationDetermineSingleParticlesStandardSettings(app)
    VisualizationDetermineSingleParticles(app)
end

% set switches and buttons
app.switch_single.ItemsData = [ 0 , 1 ];
set(app.button_show_all, 'Enable','on')
app.spinner_particle.Limits = [1 length(app.rois)];

% check if single particles present, otherwise turn of buttons
VisualizationCheckSingleParticles(app)
VisualizationUpdateSwitch(app, app.spinner_particle.Value)

% update everything to show particle 1
VisualizationUpdateWithNewParticle(app, 1)

% set green
if app.valid_tt
    app.lamp_tt.Color = 'Green';
end
if app.valid_hsm
    app.lamp_spectra.Color = 'Green';
end

end