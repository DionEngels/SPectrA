function SaveParticlePlot(wavelength,scattering,fit_Lorentz,rsquared,address,name,number,single)

    mkdir([address '\' name]);

    Lorentz_eV = linspace(1248/(min(wavelength)-30),1248/(max(wavelength)+30),100);
    Lorentz_curve = fit_Lorentz(1)+fit_Lorentz(2)./((Lorentz_eV-fit_Lorentz(3)).^2+(0.5*fit_Lorentz(4)).^2);
    
        figure;
        plot(1248./Lorentz_eV,Lorentz_curve,'k','LineWidth',2)
        
        hold;
        plot(wavelength,scattering,'ro','MarkerSize',8,'LineWidth',2)
        xlim([min(wavelength)-30 max(wavelength)+30])
        ylim([min(Lorentz_curve)*0.7 max(Lorentz_curve)*1.1])
        xlabel('Wavelength (nm)', 'FontSize', 12)
        ylabel('Scattered intensity (arb. u.)', 'FontSize', 12)
        title([ name ': Particle ' num2str(number)], 'FontSize', 16)
        annot1 = annotation('textbox',[0.14 0.82 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['\lambda = ' num2str(round(1248./fit_Lorentz(3))) ' nm (' num2str(round(fit_Lorentz(3),2)) ' eV)']);   
        annot2 = annotation('textbox',[0.14 0.765 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['\Gamma = ' num2str(round(fit_Lorentz(4)*1000)) ' meV']);   
        annot3 = annotation('textbox',[0.14 0.72 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['R^{2} = ' num2str(round(rsquared,3)) ]); 
        
        if single == 1
            annot4 = annotation('textbox',[0.75 0.82 0.1 0.1],'LineStyle','none','FontSize',14,'Color','green','FontWeight','bold','BackgroundColor','none','String',['SINGLE']); 
        else
            annot4 = annotation('textbox',[0.72 0.82 0.1 0.1],'LineStyle','none','FontSize',14,'Color','red','FontWeight','bold','BackgroundColor','none','String',['CLUSTER']); 
        end    
            
            
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\Particle_' num2str(number) '.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\Particle_' num2str(number) '.fig'] ),'fig') %save file as matlab fig
    
end