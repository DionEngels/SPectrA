function TTPageSaveContrast(wavelength,contrast,dir,name,frame,time,lim_y)

if ~exist([dir '\Graphs_SPectrA'], 'dir')
    mkdir([dir '\Graphs_SPectrA'])
end

wavelength_mu = nanmean(wavelength);
wavelength_sigma = nanstd(wavelength);

figure('Name','Contrast vs Wavelength','NumberTitle','off', 'visible','off')
plot(wavelength,contrast,'bo')
xlabel('Plasmon wavelength (nm)')
ylabel('Contrast (arb.u.)')
title('Contrast vs Wavelength')
xlim([round(wavelength_mu-3*wavelength_sigma) round(wavelength_mu+3*wavelength_sigma)])
ylim( lim_y )
annotation('textbox',[0.14 0.82 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Frame: ' num2str(frame) ]);
annotation('textbox',[0.14 0.765 0.1 0.1],'LineStyle','none','FontSize',12,'BackgroundColor','none','String',['Time: ' num2str(round(time,3)) ' s']);

set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
print(gcf,strcat( [ dir '\Graphs_SPectrA\' name '_contrast_frame_' num2str(round(frame,1)) '.png'] ),'-dpng','-r300','-opengl') %save file as png
saveas(gcf,strcat( [ dir '\Graphs_SPectrA\' name '_contrast_frame_' num2str(round(frame,1)) '.fig'] ),'fig') %save file as matlab fig

end