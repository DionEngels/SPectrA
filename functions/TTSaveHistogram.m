function TTSaveHistogram(signal,n_bins,boundaries,dir,name,lim_y,index)

if ~exist([dir '\Graphs_SPectrA'], 'dir')
    mkdir([dir '\Graphs_SPectrA'])
end

figure('Name','Signal Levels','NumberTitle','off', 'visible','off')
histogram(signal,n_bins,'BinLimits',boundaries,'FaceColor','red','LineWidth',0.5);
xlabel('Signal Intensity (arb.u.)')
ylabel('Frequency')
title('Signal counts vs Noise and Shot Noise')
title( [ 'Signal levels - ROI no.' num2str(index) ] )
xlim(lim_y)
%ylim([-Inf Inf])
set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
print(gcf,strcat( [ dir '\Graphs_SPectrA\ROI_' num2str(index) '_SignalLevels_' name '.png'] ),'-dpng','-r300','-opengl') %save file as png
saveas(gcf,strcat( [ dir '\Graphs_SPectrA\' num2str(index) '_SignalLevels_part_' name '.fig'] ),'fig') %save file as matlab fig


end




