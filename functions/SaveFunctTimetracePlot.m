function SaveFunctTimetracePlot(address,timename,nameX,nameY,time,timetrace,lambdaX,lambdaY,scaX,scaY,fit_LorentzX,fit_LorentzY,number)

    mkdir([address '\' timename]);

    Lorentz_eV = linspace(1248/(min(lambdaX)-30),1248/(max(lambdaX)+30),100);
    Lorentz_curveX = fit_LorentzX(1)+fit_LorentzX(2)./((Lorentz_eV-fit_LorentzX(3)).^2+(0.5*fit_LorentzX(4)).^2);
    Lorentz_curveY = fit_LorentzY(1)+fit_LorentzY(2)./((Lorentz_eV-fit_LorentzY(3)).^2+(0.5*fit_LorentzY(4)).^2);

    
    FigHandle = figure('Name',['Particle ' num2str(number)]);
	set(FigHandle, 'Position', [50, 50, 1300, 400]);   
    
    pos1 = [0.06 0.12 0.28 0.8];
    subplot('Position',pos1)
    plot(1248./Lorentz_eV,Lorentz_curveX,'r-',1248./Lorentz_eV,Lorentz_curveY,'b-',lambdaX,scaX,'ro',lambdaY,scaY,'bo')
    hold on;
    xlim([min(1248./Lorentz_eV) max(1248./Lorentz_eV)])
    ylim([0 abs(max([Lorentz_curveX Lorentz_curveY])*1.1)])
    xlabel( 'Wavelength (nm)' );
    ylabel( 'Scattering cross section (arb.u.)' );
    legend( nameX, nameY );
    title( [ 'Particle no.' num2str(number) ] )
        annot1 = annotation('textbox',[0.06 0.81 0.1 0.1],'LineStyle','none','FontSize',10,'BackgroundColor','none','String',['\lambda = ' num2str(round(1248./fit_LorentzX(3),1)) ' nm, \Gamma = ' num2str(round(fit_LorentzX(4)*1000)) ' meV']);   
        annot2 = annotation('textbox',[0.06 0.76 0.1 0.1],'LineStyle','none','FontSize',10,'BackgroundColor','none','String',['\Delta\lambda = '  num2str(round( (1248./fit_LorentzY(3) - 1248./fit_LorentzX(3)) ,1)) ' nm, \Delta\Gamma = ' num2str(round( (fit_LorentzY(4)-fit_LorentzX(4))*1000 )) ' meV' ]);   

    
    pos2 = [0.4 0.12 0.59 0.8];
    subplot('Position',pos2)
    plot( time, timetrace,  'r-' );  
    hold on;
    xlim([min(time) max(time)])
    ylim([-inf inf])
    xlabel( 'Time (s)' );
    ylabel( 'Scattering signal (arb.u.)' );
    title( [ timename ] )  
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
           print(gcf,strcat( [ address '\' timename '\Particle_' num2str(number) '.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' timename '\Particle_' num2str(number) '.fig'] ),'fig') %save file as matlab fig
    
end