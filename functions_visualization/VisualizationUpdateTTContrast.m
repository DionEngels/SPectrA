function VisualizationUpdateTTContrast(app, roi_number, to_save)
% Creates / Updates the contrast figure
% ----------------------

% find contrast
contrast = zeros(1, length(app.rois));
wavelength = zeros(1, length(app.rois));
indices = 1:length(app.rois);

for k=1:numel(app.rois)
    if app.button_show_all.Value || (app.button_show_single.Value && app.parent_app.file_results.(app.rois{k}).SingleParticle)
        if isfield(app.parent_app.file_results.(app.rois{k}), app.name_timetrace) && isfield(app.parent_app.file_results.(app.rois{k}), app.name_hsm)
            tt_intensity = app.parent_app.file_results.(app.rois{k}).(app.name_timetrace).result(:, 4);
            % if compenstae for spikes
            if app.button_rmv_spikes.Value
                % find signal
                if app.entry_contrast_frame.Value < 6
                    sig = nanmean(hampel(tt_intensity(1:10),5));
                elseif app.entry_contrast_frame.Value > length(tt_intensity)-6
                    sig = nanmean(hampel(tt_intensity(end-10:end),5));
                else
                    sig = nanmean(hampel(tt_intensity(app.entry_contrast_frame.Value-5:app.entry_contrast_frame.Value+5),5));
                end
                ref = nanmean(hampel(tt_intensity(3:app.entry_ref_frame.Value),5)); %reference value for the contrast
            else
                % find signal
                if app.entry_contrast_frame.Value < 6
                    sig = nanmean(tt_intensity(1:10));
                elseif app.entry_contrast_frame.Value > length(tt_intensity)-6
                    sig = nanmean(tt_intensity(end-10:end));
                else
                    sig = nanmean(tt_intensity(app.entry_contrast_frame.Value-5:app.entry_contrast_frame.Value+5));
                end
                ref = nanmean(tt_intensity(3:app.entry_ref_frame.Value)); %reference value for the contrast
            end
            
            contrast(k) = (sig./ref - 1);
            wavelength(k) = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).lambda;
            
            if k==roi_number
                active_contrast = sig./ref - 1;
                active_wavelength = app.parent_app.file_results.(app.rois{k}).(app.name_hsm).lambda;
            end
        end
    end
    
end

% if wavelength is filled with anything else than zeros
if size(wavelength(wavelength~=0), 1) > 0
    % Contrast additional calculation and plotting
    % remove bad values
    contrast = contrast(wavelength~=0);
    indices = indices(wavelength~=0);
    wavelength = wavelength(wavelength~=0);
    wavelength = wavelength( abs(contrast)<2.5 );
    indices = indices(abs(contrast)<2.5);
    contrast = contrast( abs(contrast)<2.5 );
    app.contrast_info.wavelength = wavelength;
    app.contrast_info.contrast = contrast;
    app.contrast_info.indices = indices;
    
    % get mean and sigma
    wavelength_mu = nanmean(wavelength);
    wavelength_sigma = nanstd(wavelength);
    
    cla(app.plot_contrast);
    hold(app.plot_contrast,'on');
    scatter(app.plot_contrast,wavelength,contrast,'bo', 'Tag', 'allData');
    if exist('active_contrast','var')
        scatter(app.plot_contrast,active_wavelength,active_contrast,'ro', 'filled');
    end
    
    app.plot_contrast.XLim = [round(wavelength_mu-3*wavelength_sigma) round(wavelength_mu+3*wavelength_sigma)];
    
    % if manual y_axis
    if app.button_manual_y_axis.Value
        app.plot_contrast.YLim = [app.entry_y_axis_min.Value-1  app.entry_y_axis_max.Value-1 ];
    else
        % calculate ylim
        if nanmax(abs(contrast)) == 0
            % only happens as fail state
            app.plot_contrast.YLim = [-Inf Inf];
            lim_y = app.plot_contrast.YLim;
        elseif -nanmax(contrast) < nanmax(contrast)
            % if maximum is positive
            app.plot_contrast.YLim = [-nanmax(contrast)*1.1  nanmax(contrast)*1.1];
            lim_y = [-nanmax(contrast)*1.1  nanmax(contrast)*1.1];
        else
            % if maximum is negative
            app.plot_contrast.YLim = [nanmax(contrast)*1.1  -nanmax(contrast)*1.1];
            lim_y = [nanmax(contrast)*1.1  -nanmax(contrast)*1.1];
        end
    end
else
    cla(app.plot_contrast);
end

if to_save
    time = app.parent_app.file_metadata.(['meta_' app.name_timetrace(5:end)]).timesteps(app.entry_contrast_frame.Value);
    VisualizationSaveContrast(wavelength, contrast, app.parent_app.file_dir, app.name_timetrace, app.entry_contrast_frame.Value, time, lim_y)
end
end