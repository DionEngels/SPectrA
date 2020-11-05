clc;

progress = waitbar(0,'Loading of coordinates','Name','Initializing...');

% FileFolder = % no \
% FileND2 = [FileFolder 'file.nd2'];
% threshold = [ 0.005 0.75 ];
ROI_size_gauss = 13;

%%__________________________________________________________________________
% load multipage tiff (see https://www.openmicroscopy.org/ about details on the Bio-Formats package for matlab)
data = bfGetReader(FileND2);
[data,frames,data_merged] = HSMdrift(data); % in HSM every frame has a small shift comparing with the others, here the shift is corrected
% Find the particles in the FOV
[Population] = FindParticles(data_merged,threshold,ROI_size_gauss,[app.FileFolder '\']);

close(progress)

%% Creation and saving of the coordinates and the main file

progress = waitbar(0,'Preparing working files','Name','Initializing...');

Particle = struct;
CoordinatesFile = struct;

CoordinatesFile.FOVmerged = data_merged;
CoordinatesFile.N_Object = Population.N_Object;

    for i = 1:Population.N_Object    
        Particle(i).Number = i;  
        Particle(i).SinglePart = 0; % creation of SingleParticle property - for starter all parts are set to 0
        Particle(i).SignificantPart = 0;  % creation of SingleParticle property - for starter all parts are set to 0
        CoordinatesFile.Pcles.Number(i,:) = i;  % All particles will be saved for HSM
        CoordinatesFile.Pcles.Location(i,:) = Population.Location(i,:); 
        Population.Pcles.Single(i) = Particle(i).SinglePart;       
        Population.Pcles.Significant(i) = Particle(i).SignificantPart;
    end

save( [app.FileFolder '\' app.FileName  '_CoordinatesFile.mat' ] ,'-struct', 'CoordinatesFile','-v7.3');  % saving the coordinates file
save( [app.FileFolder '\' app.FileName '.mat' ] , 'Particle','-v7.3');  % saving the coordinates file

clear Particle;
clear CoordinatesFile;

close(progress)