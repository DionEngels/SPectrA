function SaveTimetraceSNR(signalN,signalSTD,signalSN,address,name,frame,time)
    
    mkdir([address '\' name]);
    
    figure('Name','Signal counts vs Noise and Shot Noise','NumberTitle','off')
    scatter(signalN,signalSTD,'bo');
    hold on;
    scatter(signalN,signalSN,'ro'); 
    xlabel('Signal counts N (arb.u.)')
    ylabel('Noise, Shot Noise (arb.u.)')
    title('Signal counts vs Noise and Shot Noise')
    xlim([0.9*min(signalN) 1.1*max(signalN)])
    ylim([-Inf Inf]) 
    legend( {'Noise', 'Shot Noise'},'Location','southeast' );
    legend('boxoff')
    set(gca,'xscale','log')
    set(gca,'yscale','log')
    annot1 = annotation('textbox',[0.14 0.82 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Frame: 1 - ' num2str(frame) ]);   
    annot2 = annotation('textbox',[0.14 0.765 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Time: 0 - ' num2str(round(time,3)) ' s']);   
        
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\' name '_SNR_frame' num2str(round(frame,1)) '.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\' name '_SNR_frame' num2str(round(frame,1)) '.fig'] ),'fig') %save file as matlab fig   
    

end