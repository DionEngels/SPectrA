clc;
 
progress = waitbar(0,'Loading files...','Name','Add HSM measurement');

% FileFolder = % no \
% newFieldName = 'HSM';
% PclesToAnal = 1;
% ROI_size_gauss = 19;
% FileND2 = [FileFolder 'file.nd2'];
% FileSpecCorr  = [ app.ProgramFolder '\spectral_corrections\file.mat'  ];
% DoSingle = 1;

load(FileSpecCorr);
lambdaFile = SpectralCorrection.Lambda;
spec_shapeFile = SpectralCorrection.SpecShape;

foldercontent = dir(app.FileFolder);
foldercontent(1:2)=[];
foldercontent = extractfield(foldercontent,'name');
lambda = zeros(1,length(foldercontent));
for i = 1:length(foldercontent)
    lambda(i) = str2double(foldercontent{i}(1:end-4));
end

lambda = lambda(~isnan(lambda));
spec_shape = zeros(1,length(lambda));
for i = 1:length(lambda)
    [~,ind] = min(abs(lambdaFile - lambda(i)));
    spec_shape(i) = spec_shapeFile(ind);
end

%%__________________________________________________________________________
% load multipage tiff (see https://www.openmicroscopy.org/ about details on the Bio-Formats package for matlab)
data = bfGetReader(FileND2);

[data,frames,data_merged] = HSMdrift(data); % in HSM every frame has a small shift comparing with the others, here the shift is corrected

%% Load the particles from the FOV
close(progress);

progress = waitbar(0,'Loading particle coordinates...','Name','Add HSM measurement');

Population = load([app.FileFolder '\' app.FileName '_CoordinatesFile.mat' ]);

	C = xcorr2(data_merged,Population.FOVmerged);
	[max_C, imax] = max(abs(C(:)));
	[ypeak, xpeak] = ind2sub(size(C),imax(1));
	offset(:) = [(ypeak-size(data_merged,1)) (xpeak-size(data_merged,2))];
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
      imagesc(data_merged)
      colorbar; colormap default;
      for i_Beads = 1:Population.N_Process
          rectangle('Position',[Population.Location(i_Beads,1)-0.5*(ROI_size_gauss-1),Population.Location(i_Beads,2)-0.5*(ROI_size_gauss-1),ROI_size_gauss,ROI_size_gauss],'EdgeColor','white')
          text(Population.Location(i_Beads,1)+0.5*(ROI_size_gauss+3),Population.Location(i_Beads,2)-1,num2str(Population.Number(i_Beads)),'Color','white','FontSize',8,'FontWeight','bold');
      end   
      title({'The localized particles'});
    
        
% generate coordinate system for 2d Gauss fit
options = optimoptions('lsqcurvefit','Display','off','MaxIter',3000);
xx = linspace(-(ROI_size_gauss-1)/2,(ROI_size_gauss-1)/2,ROI_size_gauss);
yy = xx;     
[x,y] = meshgrid(xx,yy);
xdata(:,:,1) = x;
xdata(:,:,2) = y;

close(progress)
progress = waitbar(0,'Calculating spectra of individual particles','Name','Add HSM measurement');


for i = 1:Population.N_Process  
    
    app.ParticleFile(Population.Number(i)).(newFieldName).Location = Population.Location(i,:);
    app.ParticleFile(Population.Number(i)).(newFieldName).Lambda = lambda;
    app.ParticleFile(Population.Number(i)).(newFieldName).SpectralShape = spec_shape; 
    
    % Extraction of ROI and intensities per individual wavelenghts
    for j = 1:frames
    
        if app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2 > size(data,1)-1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2 > size(data,2)-1                 
        else
        
            %[pcle_gauss] = data((app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2):(app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2),(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2):(app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2),j);
            [pcle_gauss] = define_ROI(data(:,:,j), [app.ParticleFile(Population.Number(i)).(newFieldName).Location(1);app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)], ROI_size_gauss );
            app.ParticleFile(Population.Number(i)).(newFieldName).RawData(:,:,j) = [pcle_gauss];

            % 2D gauss fit
            init_guess = [min(min(pcle_gauss)) max(max(pcle_gauss)) 0 1.5 0];
            [app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,:),~,~,~] = lsqcurvefit(@D2GaussFunction,double(init_guess),xdata,double(pcle_gauss),[300, 300, -3, 0, -3],[16385, 16385 ,3 ,2, 3],options);

            app.ParticleFile(Population.Number(i)).(newFieldName).RawIntensity(j) = squeeze(2*pi*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,2).*app.ParticleFile(Population.Number(i)).(newFieldName).twoDGauss(j,4).^2); % volume under 2D gauss  
            %app.ParticleFile(Population.Number(i)).(newFieldName).RawIntensity(j) = mean(mean(pcle_gauss));
            app.ParticleFile(Population.Number(i)).(newFieldName).Intensity(j) = app.ParticleFile(Population.Number(i)).(newFieldName).RawIntensity(j)./spec_shape(j); % volume under 2D gauss

        end
    end 
    
    % Lorentzian fit to data
    if app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(1)+(ROI_size_gauss-1)/2 > size(data,1)-1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)-(ROI_size_gauss-1)/2 < 1 | app.ParticleFile(Population.Number(i)).(newFieldName).Location(2)+(ROI_size_gauss-1)/2 > size(data,2)-1                 
        
        app.ParticleFile(Population.Number(i)).(newFieldName).SPlambda = 0;
        app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth = 0;
    else
        [ app.ParticleFile(Population.Number(i)).(newFieldName).Lorentz(:), fit, app.ParticleFile(Population.Number(i)).(newFieldName).LorentzR ] = LorentzFit(app.ParticleFile(Population.Number(i)).(newFieldName).Intensity,lambda);

        app.ParticleFile(Population.Number(i)).(newFieldName).SPlambda = 1248./app.ParticleFile(Population.Number(i)).(newFieldName).Lorentz(3);
        app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth = 1000*app.ParticleFile(Population.Number(i)).(newFieldName).Lorentz(4);
    end
    

    waitbar(i/Population.N_Process,progress,sprintf('%1d %% done...',round((100*i/Population.N_Process))))
    
end 
close(progress)




%% determination of single particles

if DoSingle == 1

    progress = waitbar(0,'Evaluation of single particles','Name','New file: start with HSM measurement');

    for i = 1:Population.N_Process

        SPlambda_dist(i) = app.ParticleFile(Population.Number(i)).(newFieldName).SPlambda;

        if app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth<500
           Linewidth_dist(i) = app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth; 
        else
           Linewidth_dist(i) = 0;  
        end

    end 

    SPlambda_dist = SPlambda_dist( SPlambda_dist>lambda(1) & SPlambda_dist<lambda(end) );
    Linewidth_dist = Linewidth_dist( SPlambda_dist>lambda(1) & SPlambda_dist<lambda(end) );
    Linewidth_dist(Linewidth_dist==0) = []; Linewidth_dist = reshape(Linewidth_dist,1,[]);

    [Gamma_mu,Gamma_sigma] = normfit(Linewidth_dist);

    clear SPlambda_dist;
    clear Linewidth_dist;

    inx_1 = 1;
        for i = 1:Population.N_Process
            if app.ParticleFile(Population.Number(i)).(newFieldName).SPlambda>(lambda(1)+5) & app.ParticleFile(Population.Number(i)).(newFieldName).SPlambda<(lambda(end)-5) & app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth>(round(Gamma_mu-1.2*Gamma_sigma)) & app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth<(round(Gamma_mu+1.2*Gamma_sigma)) & app.ParticleFile(Population.Number(i)).(newFieldName).LorentzR>0.9                     
                app.ParticleFile(Population.Number(i)).SinglePart = 1;
                Linewidth_dist(inx_1) = app.ParticleFile(Population.Number(i)).(newFieldName).Linewidth;
                inx_1 = inx_1+1;
            else
                app.ParticleFile(Population.Number(i)).SinglePart = 0;               
            end
            
            % app.ParticleFile(Population.Number(i)).SignificantPart = 0; % This property already created while initiating file

            waitbar(i/Population.N_Process,progress,sprintf('%1d %% done...',round((100*i/Population.N_Process))))

        end 

    Linewidth_dist = [];

    close(progress)

    %% Editing of coordinates file 

    progress = waitbar(0,'Creating coordinates file','Name','New file: start with HSM measurement');
    
        for i = 1:Population.N_Object
       
            Population.Pcles.Single(i) = app.ParticleFile(i).SinglePart;       
            Population.Pcles.Significant(i) = app.ParticleFile(i).SignificantPart;
            
        end
        
    Population = rmfield(Population,{'Number','N_Process','Location'});
    
    save( [app.FileFolder '\' app.FileName '_CoordinatesFile.mat' ] ,'-struct', 'Population','-v7.3');  % saving the coordinates file
    
    close(progress)

end
%% Saving the Particle file - including all found and determined parameters

progress = waitbar(0,'Finalizing...','Name','Add HSM measurement');

disp(app.ParticleFile);

close(progress)
