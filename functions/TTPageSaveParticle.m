function SaveParticle(dir, roi, valid_tt, name_tt, valid_hsm, name_hsm, metadata)
%SAVEPARTICLE Saves the summary of a particle to disk

if ~exist([dir '\Graphs_SPectrA'], 'dir')
    mkdir([dir '\Graphs_SPectrA'])
end

% create figure
FigHandle = figure('Name',['Particle ' num2str(roi.index)], 'visible','off');
set(FigHandle, 'Position', [50, 50, 1300, 400]);
pos1 = [0.06 0.12 0.28 0.8];
subplot('Position',pos1)

% HSM Prep
if valid_hsm
    results_hsm = roi.(name_hsm);
    % convert wavelengths to double
    results_hsm.wavelengths = double(results_hsm.wavelengths);
    wavelength_ev = linspace(1248/(min(results_hsm.wavelengths)-30), 1248/(max(results_hsm.wavelengths)+30),100);
    fit = LorentzFunction(results_hsm.fit_parameters, wavelength_ev);
    
    % plot HSM
    plot(results_hsm.wavelengths, results_hsm.intensity, 'ro', 1248./wavelength_ev, fit,'r-');
    hold on;
    xlim([min(results_hsm.wavelengths)-30 max(results_hsm.wavelengths)+30 ])
    ylim([0 abs(max([results_hsm.intensity, fit])*1.1)])
    xlabel( 'Wavelength (nm)' );
    ylabel( 'Scattering cross section (arb.u.)' );
    legend( 'Measured', 'Fit' );
    title( name_hsm , 'interpreter', 'none')
    annotation('textbox',[0.06 0.81 0.1 0.1],'LineStyle','none','FontSize',10,'BackgroundColor','none','String',['\lambda = ' num2str(round(results_hsm.lambda, 1)) ' nm, \Gamma = ' num2str(round(results_hsm.linewidth, 1)) ' meV']);
end

% create second subfigure
pos2 = [0.4 0.12 0.59 0.8];
subplot('Position',pos2)
% TT Prep
if valid_tt
    results_tt = roi.(name_tt);
    intensity = results_tt.result(:, 4);
    % try to find time axis
    try
        time_axis = metadata.(['meta_' name_tt(5:end)]).timesteps;
        time_axis = time_axis(1:size(intensity));
        found_time = true;
    catch
        % else use frames
        time_axis = 1:size(intensity);
        found_time = false;
    end
    % TT Plot
    
    plot( time_axis, intensity,  'r-' );
    hold on;
    xlim([floor(min(time_axis)) ceil(max(time_axis))])
    ylim([-inf inf])
    if found_time
        xlabel( 'Time (s)' );
    else
        xlabel( 'Frames (-)');
    end
    ylabel( 'Scattering signal (arb.u.)' );
    title( name_tt, 'interpreter', 'none' )
end

% save
set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
print(gcf,strcat( [dir '\Graphs_SPectrA\ROI_' num2str(roi.index) '.png'] ),'-dpng','-r300','-opengl') %save file as png
saveas(gcf,strcat( [dir '\Graphs_SPectrA\ROI_' num2str(roi.index) '.fig'] ),'fig') %save file as matlab fig

end
