function TTPageSaveSNR(signal_n,signal_std,signal_sn,dir,name,frame,time)

if ~exist([dir '\Graphs_SPectrA'], 'dir')
    mkdir([dir '\Graphs_SPectrA'])
end

figure('Name','Signal counts vs Noise and Shot Noise','NumberTitle','off', 'visible', 'off')
scatter(signal_n,signal_std,'bo');
hold on;
scatter(signal_n,signal_sn,'ro');
xlabel('Signal counts N (arb.u.)')
ylabel('Noise, Shot Noise (arb.u.)')
title('Signal counts vs Noise and Shot Noise')
xlim([0.9*min(signal_n) 1.1*max(signal_n)])
ylim([-Inf Inf])
legend( {'Noise', 'Shot Noise'},'Location','southeast' );
legend('boxoff')
set(gca,'xscale','log')
set(gca,'yscale','log')
annotation('textbox',[0.14 0.82 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Frame: 1 - ' num2str(frame) ]);
annotation('textbox',[0.14 0.765 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Time: 0 - ' num2str(round(time,3)) ' s']);

set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
print(gcf,strcat( [ dir '\Graphs_SPectrA\' name '_SNR_frame_' num2str(round(frame,1)) '.png'] ),'-dpng','-r300','-opengl') %save file as png
saveas(gcf,strcat( [ dir '\Graphs_SPectrA\' name '_SNR_frame_' num2str(round(frame,1)) '.fig'] ),'fig') %save file as matlab fig


end