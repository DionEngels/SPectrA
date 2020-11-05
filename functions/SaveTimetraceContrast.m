function SaveTimetraceContrast(wavelength,contrast,address,name,frame,time,limY)
    
    mkdir([address '\' name]);

%     wavelength = wavelength( abs(contrast)<2.5 );
%     contrast = contrast( abs(contrast)<2.5 );   
    
    wavelength_mu = mean(wavelength);
    wavelength_sigma = std(wavelength);
            
    figure('Name','Contrast vs Wavelength','NumberTitle','off')
    plot(wavelength,contrast,'bo')
    xlabel('Plasmon wavelength (nm)')
    ylabel('Contrast (arb.u.)')
    title('Contrast vs Wavelength')
    xlim([round(wavelength_mu-3*wavelength_sigma) round(wavelength_mu+3*wavelength_sigma)])
    ylim( limY )    
    annot1 = annotation('textbox',[0.14 0.82 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Frame: ' num2str(frame) ]);   
    annot2 = annotation('textbox',[0.14 0.765 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Time: ' num2str(round(time,3)) ' s']);   
        
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\' name '_contrast_frame' num2str(round(frame,1)) '.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\' name '_contrast_frame' num2str(round(frame,1)) '.fig'] ),'fig') %save file as matlab fig            

end