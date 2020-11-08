function SaveSPshiftHistCorr(wavelength,shift,address,timetracename,nameX,nameY)

    mkdir([address '\' timetracename]);

    wavelength = wavelength(-20<shift & shift<60 );
    shift = shift(-20<shift & shift<60 );
    
    wavelength_mu = mean(wavelength);
    wavelength_sigma = std(wavelength);
        
    figure('Name','Plasmon shift','NumberTitle','off')
    histfit(shift,50)
    xlabel('Plasmon shift (nm)')
    ylabel('Occurence')
    title('Plasmon shift (nm)]')
    [shift_mu,shift_sigma] = normfit(shift);
    xlim([round(shift_mu-3*shift_sigma) round(shift_mu+3*shift_sigma)])
    ylim([0 inf])
    annot = annotation('textbox',[0.14 0.8 0.1 0.1],'LineStyle','none','BackgroundColor','none','String',['\mu = ' num2str(round(shift_mu,1)) ' nm, \sigma = ' num2str(round(shift_sigma,1)) ' nm']);
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' timetracename '\' nameX '_' nameY '_SPshift_histogram.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' timetracename '\' nameX '_' nameY '_SPshift_histogram.fig'] ),'fig') %save file as matlab fig
    
    figure('Name','Plasmon shift vs Wavelength','NumberTitle','off')
    plot(wavelength,shift,'bo')
    xlabel('Plasmon wavelength (nm)')
    ylabel('Plasmon shift (nm)')
    title('Shift vs Wavelength')
    xlim([round(wavelength_mu-3*wavelength_sigma) round(wavelength_mu+3*wavelength_sigma)])
    ylim([round(shift_mu-3*shift_sigma) round(shift_mu+3*shift_sigma)])
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' timetracename '\' nameX '_' nameY '_SPshift_correlation.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' timetracename '\' nameX '_' nameY '_SPshift_correlation.fig'] ),'fig') %save file as matlab fig

end