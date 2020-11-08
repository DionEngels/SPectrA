function SaveSignalHist(signal,NBins,boundaries,address,name,limY,number)
 
%     SaveSignalHist(app.TimetraceToPlot,NBins,[floor(min(app.TimetraceToPlot)) ceil(max(app.TimetraceToPlot))],app.MainApp.FileFolder,app.TimetraceName,limY,app.PartSpinner.Value);                      
                     
    mkdir([address '\' name]);
    
    figure('Name','Signal Levels','NumberTitle','off')
    histogram(signal,NBins,'BinLimits',boundaries,'FaceColor','red','LineWidth',0.5); 
    xlabel('Signal Intensity (arb.u.)')
    ylabel('Frequency')
    title('Signal counts vs Noise and Shot Noise')
    title( [ 'Signal levels - Particle no.' num2str(number) ] )           
    xlim(limY)
%     ylim([-Inf Inf])
            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\' name '_SignalLevels_part_' num2str(number) '.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\' name '_SignalLevels_part_' num2str(number) '.fig'] ),'fig') %save file as matlab fig   
    

end




                     