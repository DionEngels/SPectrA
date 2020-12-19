function VisualizationClickOnContrast(app, event)
% Function that is called when you click on contrast plot
% ----------------------
pos_plot_contrast = app.plot_contrast.InnerPosition;
pos_click = event.Source.CurrentPoint;
% check if you clicked within contrast
if pos_click(1) > pos_plot_contrast(1) && pos_click(1) < pos_plot_contrast(1) + pos_plot_contrast(3) && pos_click(2) > pos_plot_contrast(2) && pos_click(2) < pos_plot_contrast(2) + pos_plot_contrast(4)
    % get xy click
    pos_click_fig = pos_click;
    pos_click_fig(1) = (pos_click_fig(1) - pos_plot_contrast(1)) / pos_plot_contrast(3);
    pos_click_fig(2) = (pos_click_fig(2) - pos_plot_contrast(2)) / pos_plot_contrast(4);
    
    % get all datapoints from fig
    xy_data = cat(1, app.contrast_info.wavelength, app.contrast_info.contrast);
    % normalize to axis
    xlim = app.plot_contrast.XLim;
    ylim = app.plot_contrast.YLim;
    xy_data(1,:) = (xy_data(1,:) - xlim(1)) / (xlim(2) - xlim(1));
    xy_data(2,:) = (xy_data(2,:) - ylim(1)) / (ylim(2) - ylim(1));
    
    % find closest
    dist = sqrt(sum((xy_data - pos_click_fig').^2));
    [~, min_index] = nanmin(dist);
    
    % select new particle
    app.spinner_particle.Value = app.contrast_info.indices(min_index);
    
    % Update particle
    VisualizationUpdateSwitch(app, app.spinner_particle.Value)
    % Update dataset if need be
    if app.valid_tt
        VisualizationUpdateTT(app, app.spinner_particle.Value)
    end
    if app.valid_hsm
        VisualizationUpdateHSM(app, app.spinner_particle.Value)
    end
    % update particle views
    VisualizationUpdateFOVTT(app, app.spinner_particle.Value)
    VisualizationUpdateFOVHSM(app, app.spinner_particle.Value)
end
end