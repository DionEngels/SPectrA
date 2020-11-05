clc;

progress = waitbar(0,'Loading files...','Name','Run Timetrace Analysis');

disp(app.ParticleFile);

% FileFolder = % no \
% newFieldName = 'Timetrace';
% MethodToUse = 1;
% PclesToAnal = 1;
% DriftCorrection = 1;
% ROI_size_gauss = 19;
% FileND2 = [FileFolder 'file.nd2'];

%% __________________________________________________________________________
% load multipage tiff (see https://www.openmicroscopy.org/ about details on the Bio-Formats package for matlab)
data = bfGetReader(FileND2);

omeMeta = data.getMetadataStore();
framestart = 1;
frames = omeMeta.getPixelsSizeT(0).getValue();
% frames = omeMeta.getPixelsSizeZ(0).getValue();
I = double(bfGetPlane(data, framestart));

PixelCallibration = double(omeMeta.getPixelsPhysicalSizeX(0).value).*1000;  % the size of the pixel in nanometers

close(progress);
%% Load the particles from the FOV

progress = waitbar(0,'Loading particle coordinates...','Name','Run Timetrace Analysis');

Population = load([app.FileFolder '\' app.FileName '_CoordinatesFile.mat' ]);

% corr_data = double(Population.FOVmerged - mean(mean(Population.FOVmerged)));
% corr_data( corr_data<0 ) = 0;
% I = double(I - mean(mean(I)));
% I( I<0 ) = 0;
[I_Corrected,~] = BackgroundCorrection_WaveletSet(I,2);
[FOV_corrected,~] = BackgroundCorrection_WaveletSet(Population.FOVmerged,2);

	C = xcorr2(I_Corrected,FOV_corrected);
    [max_C, imax] = max(abs(C(:)));
	[ypeak, xpeak] = ind2sub(size(C),imax(1));
	offset(:) = [(ypeak-size(I,1)) (xpeak-size(I,2))];
	C = [];
 
    
   % Selection of the right particles to be analyzed - variable PclesToAnal = 1 (all particles), 2 (single particles), 3 (significant particles) 
    if PclesToAnal == 1 
        Population.N_Process = Population.N_Object;
        Population.Number = Population.Pcles.Number;    
        Population.Location(:,1) = Population.Pcles.Location(:,1) + offset(2);
        Population.Location(:,2) = Population.Pcles.Location(:,2) + offset(1);    
    end
    
    if PclesToAnal == 2          
        inx = 1;
        for i = 1:Population.N_Object           
            if Population.Pcles.Single(i) == 1
                Population.Number(inx) = Population.Pcles.Number(i);
                Population.Location(inx,1) = Population.Pcles.Location(i,1) + offset(2);
                Population.Location(inx,2) = Population.Pcles.Location(i,2) + offset(1);
                inx = inx+1;
            end       
        end        
        Population.N_Process = inx-1;
    end
    
    if PclesToAnal == 3          
        inx = 1;
        for i = 1:Population.N_Object           
            if Population.Pcles.Significant(i) == 1
                Population.Number(inx) = Population.Pcles.Number(i);
                Population.Location(inx,1) = Population.Pcles.Location(i,1) + offset(2);
                Population.Location(inx,2) = Population.Pcles.Location(i,2) + offset(1);
                inx = inx+1;
            end       
        end        
        Population.N_Process = inx-1;
    end        
      

      figure
      imagesc(I)
      colorbar; colormap default;
      for i_Beads = 1:Population.N_Process
          rectangle('Position',[Population.Location(i_Beads,1)-0.5*(ROI_size_gauss-1),Population.Location(i_Beads,2)-0.5*(ROI_size_gauss-1),ROI_size_gauss,ROI_size_gauss],'EdgeColor','white')
          text(Population.Location(i_Beads,1)+0.5*(ROI_size_gauss+3),Population.Location(i_Beads,2)-1,num2str(Population.Number(i_Beads)),'Color','white','FontSize',8,'FontWeight','bold');
      end   
      title({'The localized particles'});
   
    close(progress)      
%% Extracting the intensity per frame per particle

progress = waitbar(0,'Calculating individual timetraces','Name','Run Timetrace Analysis');

% Generation of the time axis
time_axis = zeros(1, frames);
for i = framestart:frames
    time_axis(i) = omeMeta.getPlaneDeltaT(0 , i - 1).value;
end

% generate coordinate system for 2d Gauss fit
options = optimoptions('lsqcurvefit','Display','off','MaxIter',5000);
xx = linspace(-(ROI_size_gauss-1)/2,(ROI_size_gauss-1)/2,ROI_size_gauss);
yy = xx;     
[x,y] = meshgrid(xx,yy);
xdata(:,:,1) = x;
xdata(:,:,2) = y;

start = tic; 

for j = framestart:frames
    
    slice = bfGetPlane(data, j);
    bg = mean(mean(slice));
    
	for i = 1:Population.N_Process
        
        if j == framestart
           
            app.ParticleFile(Population.Number(i)).(newFieldName).Location = Population.Location(i,:);
            app.ParticleFile(Population.Number(i)).(newFieldName).Time = time_axis;

        end
   
        % crop the image around the particle        
        if app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2 > size(slice,2)-1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2 > size(slice,1)-1 
                 
        else
            
            [pcle_gauss] = slice((app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2):(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2),(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2):(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2));
                   
            app.ParticleFile(Population.Number(i)).(newFieldName).RawData(:,:,j) = [pcle_gauss];
                                          
            % Processing of the data: 1 = ROI mean, 2 = ROI sum, 3 = 2D Gaussian fit, 4 = 2D gaussian fit on log scale            
            if MethodToUse == 1 
                pcle_gauss = pcle_gauss - 350;  % 350 = dark counts
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = mean(mean(pcle_gauss));
                
                    pcle_gauss = abs(pcle_gauss);
                    pcle_gauss_Cutoff = 0.05*max(max(pcle_gauss)); 
                    pcle_gauss_Mask = pcle_gauss > pcle_gauss_Cutoff;
                    pcle_gauss = double(pcle_gauss_Mask) .* double(pcle_gauss - pcle_gauss_Cutoff);

                    % Meshgrid (Coordinate LUT)
                    [X,Y] = meshgrid(1:size(pcle_gauss,2), 1:size(pcle_gauss,1));
                    TotalIntensity = sum(sum(pcle_gauss));
                    CoM_X = sum(sum(X .* double(pcle_gauss))) / TotalIntensity;
                    CoM_Y = sum(sum(Y .* double(pcle_gauss))) / TotalIntensity;
                
                        app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 + CoM_X - 1 )   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 + CoM_Y - 1) ];            
                        app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                        
            end
            
            if MethodToUse == 2 
                pcle_gauss = pcle_gauss - 350;  % 350 = dark counts
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = sum(sum(pcle_gauss));
                
                    pcle_gauss = abs(pcle_gauss);
                    pcle_gauss_Cutoff = 0.05*max(max(pcle_gauss)); 
                    pcle_gauss_Mask = pcle_gauss > pcle_gauss_Cutoff;
                    pcle_gauss = double(pcle_gauss_Mask) .* double(pcle_gauss - pcle_gauss_Cutoff);

                    % Meshgrid (Coordinate LUT)
                    [X,Y] = meshgrid(1:size(pcle_gauss,2), 1:size(pcle_gauss,1));
                    TotalIntensity = sum(sum(pcle_gauss));
                    CoM_X = sum(sum(X .* double(pcle_gauss))) / TotalIntensity;
                    CoM_Y = sum(sum(Y .* double(pcle_gauss))) / TotalIntensity;
                
                        app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 + CoM_X - 1 )   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 + CoM_Y - 1) ];            
                        app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                        
            end
            
            if MethodToUse == 3
                [maxval idx] = max(pcle_gauss(:));
                [row,col] = ind2sub(size(pcle_gauss),idx);
                init_guess = [bg double(max(max(pcle_gauss-bg))) row-(ROI_size_gauss+1)/2 1.5 col-(ROI_size_gauss+1)/2];
 
                    [app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,:),~,~,~] = lsqcurvefit(@D2GaussFunction,init_guess,xdata,double(pcle_gauss),[],[],options);                
                
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = squeeze(2*pi*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2).*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4).^2);
                
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3)))   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,5))) ];            
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                        
            end

            if MethodToUse == 4
                bg_log = round(mean(mean([ double(pcle_gauss([1 end],:)') double(pcle_gauss(:,[1 end]))  ])));
                pcle_gauss = pcle_gauss - bg_log; 
                pcle_gauss(pcle_gauss<1) = 1;
                pcle_gauss = log(double(pcle_gauss));  
                [maxval idx] = max(pcle_gauss(:));
                [row,col] = ind2sub(size(pcle_gauss),idx);
                init_guess = [ double(max(max(pcle_gauss))) row-(ROI_size_gauss+1)/2 1.5 col-(ROI_size_gauss+1)/2];
                
                    [app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,:),~,~,~] = lsqcurvefit(@D2GaussFunctionLog,init_guess,xdata,double(pcle_gauss),[],[],options);
                
                app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = squeeze(2*pi*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,1).*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3).^2);    
               
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2)))   abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4))) ];                       
                app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) = app.ParticleFile(Population.Number(i)).(newFieldName).Tracking(j,:) .* PixelCallibration; % Gives the real units in nm
                        
            end            
            
                       
            % Drift correction is performed every 10 s
            if DriftCorrection == 1               
                
                app.ParticleFile(Population.Number(i)).(newFieldName).DriftCorrTrace(j) = 0;
                
                if ceil(round(time_axis(j),1)/10)==floor(round(time_axis(j),1)/10) % drift correction attempt happens every 10 seconds
                
                    if MethodToUse ~= 3 | MethodToUse ~= 4
                        [maxval idx] = max(pcle_gauss(:));
                        [row,col] = ind2sub(size(pcle_gauss),idx);
                        init_guess = [bg double(max(max(pcle_gauss-bg))) row-(ROI_size_gauss+1)/2 1.5 col-(ROI_size_gauss+1)/2];

                            [drift_corr(j,:),~,~,~] = lsqcurvefit(@D2GaussFunction,init_guess,xdata,double(pcle_gauss),[],[],options);
                    end 
                                                                          
                        if MethodToUse == 1 
                        	if or(gt(abs(drift_corr(j,3)),1),gt(abs(drift_corr(j,5)),1))
                                if squeeze(round(abs(drift_corr(j,3))))  < (ROI_size_gauss-1)/2 | squeeze(round(abs(drift_corr(j,5)))) < (ROI_size_gauss-1)/2 
                                    app.ParticleFile(Population.Number(i)).(newFieldName).Location = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(round(drift_corr(j,3))))  abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(round(drift_corr(j,5)))) ];   
                                    app.ParticleFile(Population.Number(i)).(newFieldName).DriftCorrTrace(j) = 1;
                                end
                            end
                        end

                        if MethodToUse == 2
                            if or(gt(abs(drift_corr(j,3)),1),gt(abs(drift_corr(j,5)),1))
                                if squeeze(round(abs(drift_corr(j,3))))  < (ROI_size_gauss-1)/2 | squeeze(round(abs(drift_corr(j,5)))) < (ROI_size_gauss-1)/2 
                                    app.ParticleFile(Population.Number(i)).(newFieldName).Location = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(round(drift_corr(j,3))))  abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(round(drift_corr(j,5)))) ];   
                                    app.ParticleFile(Population.Number(i)).(newFieldName).DriftCorrTrace(j) = 1;
                                end
                            end    
                        end

                        if MethodToUse == 3
                        	if or(gt(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3)),1),gt(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,5)),1))
                                if squeeze(round(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3))))  < (ROI_size_gauss-1)/2 | squeeze(round(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,5)))) < (ROI_size_gauss-1)/2 
                                    app.ParticleFile(Population.Number(i)).(newFieldName).Location = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(round(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,3))))  abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(round(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,5)))) ];   
                                    app.ParticleFile(Population.Number(i)).(newFieldName).DriftCorrTrace(j) = 1;
                                end
                            end
                        end

                        if MethodToUse == 4
                        	if or(gt(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2)),1),gt(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4)),1))
                                if squeeze(round(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2))))  < (ROI_size_gauss-1)/2 | squeeze(round(abs(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4)))) < (ROI_size_gauss-1)/2 
                                    app.ParticleFile(Population.Number(i)).(newFieldName).Location = [ abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+squeeze(round(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2))))  abs(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+squeeze(round(app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4)))) ];   
                                    app.ParticleFile(Population.Number(i)).(newFieldName).DriftCorrTrace(j) = 1;
                                end
                            end    
                        end                                               
                end                
            end            
        end    
    end
    
    waitbar(j/frames,progress,sprintf('%1d %% done...',round((100*j/frames))));
    
end    
   
elapsed = toc(start); 
formatSpec = 'Timetrace analysis took %4f seconds... \r\n';
fprintf(formatSpec,elapsed) 
      
close(progress);
%% Saving the Particle file - including all found and determined parameters

progress = waitbar(0,'Finalizing...','Name','Run Timetrace Analysis');

clear Population;

disp(app.ParticleFile);

close(progress);
  