function VisualizationUpdateHSMPlot(app, roi_number, custom_fit)
% Creates / Updates the spectrum plot of a ROI
% ----------------------
% Particle spectra plot
cla(app.plot_spectra)
if isfield(app.parent_app.file_results.(app.rois{roi_number}), app.name_hsm)
    % convert wavelengths to double
    app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths = double(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths);
    % plot
    wavelength_ev = linspace(1240/(min(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)-30), 1240/(max(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)+30),100);
    hold(app.plot_spectra,'on')
    plot(app.plot_spectra, app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths, app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).intensity, 'ro');
    if ~isnan(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).lambda) && isempty(custom_fit)
        % if no custom fit, and fit exists
        plot(app.plot_spectra, 1240./wavelength_ev, LorentzFunction(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters, wavelength_ev),'r-')
        app.plot_spectra.XLim = [min(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)-30 max(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)+30 ];
        % set labels
        app.plot_spectra_label_SP_lambda.Text = ['? = ' num2str(round(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).lambda, 1)) ' nm'];
        app.plot_spectra_label_SP_gamma.Text = ['? = ' num2str(round(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).linewidth, 1)) ' meV'];
        app.plot_spectra_label_SP_r2.Text = ['R^2 = ' num2str(round(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).R2, 2))];
    elseif ~isempty(custom_fit)
        % if custom fit
        plot(app.plot_spectra, 1240./wavelength_ev, LorentzFunction(custom_fit(1:4), wavelength_ev),'r-')
        app.plot_spectra.XLim = [min(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)-30 max(app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths)+30 ];
        % set labels
        app.plot_spectra_label_SP_lambda.Text = ['? = ' num2str(round(1240 / custom_fit(3), 1)) ' nm'];
        app.plot_spectra_label_SP_gamma.Text = ['? = ' num2str(round(1000 * custom_fit(4), 1)) ' meV'];
        app.plot_spectra_label_SP_r2.Text = ['R^2 = ' num2str(round(custom_fit(5), 2))];
    else
        % if nothing at all
        app.plot_spectra_label_SP_lambda.Text = 'No data';
        app.plot_spectra_label_SP_gamma.Text = 'No data';
        app.plot_spectra_label_SP_r2.Text = 'No data';
    end
    
    
else
    app.plot_spectra_label_SP_lambda.Text = 'No data';
    app.plot_spectra_label_SP_gamma.Text = 'No data';
    app.plot_spectra_label_SP_r2.Text = 'No data';
    
end
end