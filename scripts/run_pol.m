%% run_pol

clc;

progress = waitbar(0,'Loading files...','Name','Run Polarization Analysis');

disp(app.ParticleFile);


%% load multipage tiff (see https://www.openmicroscopy.org/ about details on the Bio-Formats package for matlab)
data = bfGetReader(POLFileND2);
omeMeta = data.getMetadataStore();
framestart = 1;

[data,frames,data_merged,PixelCallibration] = HSMdrift(data); % in HSM every frame has a small shift comparing with the others, here the shift is corrected

%% Load the particles from the FOV
close(progress);

progress = waitbar(0,'Loading particle coordinates...','Name','Add HSM measurement');

Population = load([app.FileFolder '\' app.FileName '_CoordinatesFile.mat' ]);


C = xcorr2(data_merged,Population.FOVmerged);
[max_C, imax] = max(abs(C(:)));
[ypeak, xpeak] = ind2sub(size(C),imax(1));
offset(:) = [(ypeak-size(data_merged,1)) (xpeak-size(data_merged,2))];
C = [];

Population.N_Process = Population.N_Object;
Population.Number = Population.Pcles.Number;
Population.Location(:,1) = Population.Pcles.Location(:,1) + offset(2);
Population.Location(:,2) = Population.Pcles.Location(:,2) + offset(1);

figure
imagesc(data_merged)
colorbar; colormap jet;
for i_Beads = 1:Population.N_Process
    rectangle('Position',[Population.Location(i_Beads,1)-0.5*(ROI_size_gauss-1),Population.Location(i_Beads,2)-0.5*(ROI_size_gauss-1),ROI_size_gauss,ROI_size_gauss],'EdgeColor','white')
    text(Population.Location(i_Beads,1)+0.5*(ROI_size_gauss+3),Population.Location(i_Beads,2)-1,num2str(Population.Number(i_Beads)),'Color','white','FontSize',8,'FontWeight','bold');
end
title({'The localized particles'});


%% Gaussian fitting
% generate coordinate system for 2d Gauss fit
options = optimoptions('lsqcurvefit','Display','off','MaxIter',3000);
xx = linspace(-(ROI_size_gauss-1)/2,(ROI_size_gauss-1)/2,ROI_size_gauss);
yy = xx;
[x,y] = meshgrid(xx,yy);
xdata(:,:,1) = x;
xdata(:,:,2) = y;

close(progress)
progress = waitbar(0,'Calculating spectra of individual particles','Name','Add Pol measurement');


for i = 1:Population.N_Process
    
    app.ParticleFile(Population.Number(i)).(newFieldName).Degrees = Pol;
    app.ParticleFile(Population.Number(i)).(newFieldName).Location = Population.Location(i,:);
    % Extraction of ROI and intensities per individual wavelenghts
    for j = 1:frames
        
        if app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2 > size(data,1)-1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2 > size(data,2)-1
        else
            
            [pcle_gauss] = define_ROI(data(:,:,j), [app.ParticleFile(Population.Number(i)).(newFieldName).Location(1);app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)], ROI_size_gauss );
            
            app.ParticleFile(Population.Number(i)).(newFieldName).RawData(:,:,j) = [pcle_gauss];
            
            
            % Processing of the data: 1 = 2D Gaussian, 2 = ROI mean, 3 = Sum
            if MethodToUse == 1
                
                [maxval idx] = max(pcle_gauss(:));
                [row,col] = ind2sub(size(pcle_gauss),idx);
                init_guess = [min(min(pcle_gauss)) double(max(max(pcle_gauss-min(min(pcle_gauss))))) row-(ROI_size_gauss+1)/2 1.5 col-(ROI_size_gauss+1)/2];
                
                [app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,:),~,~,~] = lsqcurvefit(@D2GaussFunction,init_guess,xdata,double(pcle_gauss),[300, 300, -10, 0, -10],[65535, 65535 ,10,5, 10],options);
                
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = squeeze(2*pi*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2).*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4).^2);
                
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3)))   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,5))) ];
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                
            end
            
            if MethodToUse == 2
                
                pcle_gauss = pcle_gauss - 350;  % 350 = dark counts
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = mean(mean(pcle_gauss));

%                 
%                 pcle_gauss = abs(pcle_gauss);
%                 pcle_gauss_Cutoff = 0.05*max(max(pcle_gauss));
%                 pcle_gauss_Mask = pcle_gauss > pcle_gauss_Cutoff;
%                 pcle_gauss = double(pcle_gauss_Mask) .* double(pcle_gauss - pcle_gauss_Cutoff);
%                 
%                 % Meshgrid (Coordinate LUT)
%                 [X,Y] = meshgrid(1:size(pcle_gauss,2), 1:size(pcle_gauss,1));
%                 TotalIntensity = sum(sum(pcle_gauss));
%                 CoM_X = sum(sum(X .* double(pcle_gauss))) / TotalIntensity;
%                 CoM_Y = sum(sum(Y .* double(pcle_gauss))) / TotalIntensity;
%                 
%                 app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 + CoM_X - 1 )   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 + CoM_Y - 1) ];
%                 app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                
            end
            
            if MethodToUse == 3
                pcle_gauss = pcle_gauss - 350;  % 350 = dark counts
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = sum(sum(pcle_gauss));
                
%                 pcle_gauss = abs(pcle_gauss);
%                 pcle_gauss_Cutoff = 0.05*max(max(pcle_gauss));
%                 pcle_gauss_Mask = pcle_gauss > pcle_gauss_Cutoff;
%                 pcle_gauss = double(pcle_gauss_Mask) .* double(pcle_gauss - pcle_gauss_Cutoff);
%                 
%                 % Meshgrid (Coordinate LUT)
%                 [X,Y] = meshgrid(1:size(pcle_gauss,2), 1:size(pcle_gauss,1));
%                 TotalIntensity = sum(sum(pcle_gauss));
%                 CoM_X = sum(sum(X .* double(pcle_gauss))) / TotalIntensity;
%                 CoM_Y = sum(sum(Y .* double(pcle_gauss))) / TotalIntensity;
%                 
%                 app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 + CoM_X - 1 )   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 + CoM_Y - 1) ];
%                 app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                
            end
            
        end
    end
    waitbar(i/Population.N_Process,progress,sprintf('%1d %% done...',round((100*i/Population.N_Process))))
    
end

close(progress)
%% Cos^2 fitting

h = waitbar(0, 'Cos^2 fitting...');

for j = 1 : Population.N_Process
    
    % fit with cos^2 function
    fun = @(c,x) c(1)+c(2)*cos(x+c(3)).^2;
    options = optimoptions('lsqcurvefit','Display','off','MaxIter',3000);
    c0(1) = mean(app.ParticleFile(Population.Number(j)).(newFieldName).Intensity);
    c0(2) = max(app.ParticleFile(Population.Number(j)).(newFieldName).Intensity);
    c0(3) = pi/2;
    
    [app.ParticleFile(Population.Number(j)).(newFieldName).FitCos] = lsqcurvefit(fun, c0, app.ParticleFile(Population.Number(j)).(newFieldName).Degrees,app.ParticleFile(Population.Number(j)).(newFieldName).Intensity,[0 0 -pi],[Inf Inf 0],options);
    app.ParticleFile(Population.Number(j)).(newFieldName).OrientAng = app.ParticleFile(Population.Number(j)).(newFieldName).FitCos(3).*180./pi;
    
    waitbar( j / Population.N_Process, h );
    %     figure;
    %     subplot(1,2,1)
    %     plot(pol,signal_matrix(j,:),'o',linspace(0,pi,100),fun(fitCos(j,:),linspace(0,pi,100)),'b')
    %     xlabel('Angles (degree)')
    %     ylabel('Intensity')
    %     subplot(1,2,2)
    %     polarplot(pol,signal_matrix(j,:),'o',linspace(0,pi,100),fun(fitCos(j,:),linspace(0,pi,100)),'b')
    %     title(['Angle = ',num2str(orientAng(j)*180/pi)])
end


close(h)
% 
% figure;polarhistogram(deg2rad(-orientAng),30,'facecolor','r')
% set(gcf,'PaperPositionMode','auto','Color','white'); % maintain aspect ratio, background white
% print('histogram_angles','-dpng')
% saveas(gcf,'histogram_angles','fig') %save file as matlab fig
% save PolData signal_matrix
% save fitCos fitCos
% save orientAng orientAng


disp(app.ParticleFile);