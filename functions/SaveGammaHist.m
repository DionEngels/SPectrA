function SaveGammaHist(linewidth,address,name)

    mkdir([address '\' name]);

    linewidth = linewidth( 30<linewidth & linewidth<500 );
                
    figure('Name','Plasmon Linewidth','NumberTitle','off')
    histfit(linewidth,50)
    xlabel('Plasmon Linewidth (meV)')
    ylabel('Occurence')
    title('Plasmon Linewidth [meV]')
    [linewidth_mu,linewidth_sigma] = normfit(linewidth);
    xlim([round(linewidth_mu-3*linewidth_sigma) round(linewidth_mu+3*linewidth_sigma)])
    ylim([0 inf])  
    annot = annotation('textbox',[0.14 0.8 0.1 0.1],'LineStyle','none','BackgroundColor','none','String',['\mu = ' num2str(round(linewidth_mu,1)) ' meV, \sigma = ' num2str(round(linewidth_sigma,1)) ' meV']);

            set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
            print(gcf,strcat( [ address '\' name '\' name '_Linewidth_histogram.png'] ),'-dpng','-r300','-opengl') %save file as png
            saveas(gcf,strcat( [ address '\' name '\' name '_Linewidth_histogram.fig'] ),'fig') %save file as matlab fig

end