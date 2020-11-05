function SaveSPHist(wavelength,address,name)

    mkdir([address '\' name]);

    pre_mu = mean(wavelength);
    pre_sigma = std(wavelength);
    
    wavelength = wavelength( (pre_mu-3*pre_sigma)<wavelength & wavelength<(pre_mu+3*pre_sigma) );

    figure('Name','Plasmon Wavelength','NumberTitle','off')
    histfit(wavelength,50)
    xlabel('Plasmon Wavelength (nm)')
    ylabel('Occurence')
    title('Plasmon Wavelength [nm]')
    [wavelength_mu,wavelength_sigma] = normfit(wavelength);
    xlim([round(wavelength_mu-3*wavelength_sigma) round(wavelength_mu+3*wavelength_sigma)])
    ylim([0 inf])
    annot = annotation('textbox',[0.14 0.8 0.1 0.1],'LineStyle','none','BackgroundColor','none','String',['\mu = ' num2str(round(wavelength_mu,1)) ' nm, \sigma = ' num2str(round(wavelength_sigma,1)) ' nm']);

            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\' name '_SPlambda_histogram.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\' name '_SPlambda_histogram.fig'] ),'fig') %save file as matlab fig

end