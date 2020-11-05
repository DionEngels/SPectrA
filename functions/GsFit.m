%% Gaussian fitting for HSM and POL analysis
%  Input
%  -------------------------------------------------------------------
%       data: ome data structure from HSMGetfile
%       pcles: number of particles to analyze
%       frames: number of frames in the movie to analyze
%       ROI_size: size of square ROI around each particle
%       coord: coordinates of each particle, same length as pcles.
%       method: choose from 'Sum','Mean', or 'Gaussian'
%  Output
%  -------------------------------------------------------------------
%       results_params: Gaussian fitting results
%       signal_matrix: time traces of each particles. Dimension: pcles (rows) *
%       frames (cols)
%       coord: coordinates of the each particle.
%       pcle_ROIs: cropped ROIs during the analysis
%       bg: average background value for each frame.

function [results_params,signal_matrix,coord,bg] = GsFit(data, pcles, frames, ROI_size_gauss, coord, Method)

%parpool

results_params = zeros(5,pcles,frames);
signal_matrix = zeros(pcles,frames);

switch Method
    case 'Gaussian'
        %% Gaussian Fit
        % initialize variables
        %ROI_size_gauss = 6;
        h = waitbar(0, 'Please wait for Gaussian fitting...');
        for i = 1 : frames
            img = double(bfGetPlane(data,i));
            %img = double(bfGetPlane(data,i));
            bg = mean(mean(img));
            % suppress output from curvefit and specify intial parameters
            options = optimoptions('lsqcurvefit','Display','off');
            
            % generate coordinate system for 2d Gauss fit
            xx = linspace(-(ROI_size_gauss-1)/2,(ROI_size_gauss-1)/2,ROI_size_gauss);
            yy = xx;
            [x,y] = meshgrid(xx,yy);
            xdata(:,:,1) = x;
            xdata(:,:,2) = y;
            for k = 1 : pcles
                if any(coord(:, k)) == 0
                    continue
                end
                
                [pcle_gauss] = define_ROI( img, abs(coord(:,k)), ROI_size_gauss);
                
                [maxval,idx] = max( pcle_gauss(:) ); % If A is a matrix, then max(A) is a row vector containing the maximum value of each column. Get the x index where the maxval is.
                [row,col] = ind2sub( size(pcle_gauss), idx ); % subscript of the biggest pixel in ROI
                init_guess = ([ bg double(max(max(pcle_gauss-bg))) row-(ROI_size_gauss+1)/2 1 col-(ROI_size_gauss+1)/2]);
                
                [fit_Gs_full2(:,k),resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction, init_guess, xdata, double(pcle_gauss),[300 300 -5 1 -5],[65535 65535 5 5 5],options);
                
                %pcle_ROIs(:,:,i,k) = pcle_gauss;
                
            end
            results_params(:,:,i) = fit_Gs_full2;
            signal_matrix(:,i) = squeeze(2*pi*results_params(2,:,i).*results_params(4,:,i).^2); % volume under 2D gauss
            waitbar(i/frames,h,['Fitting frame ',num2str(i)])
        end
        close(h)
        
    case 'Mean'
        %% mean values without Gaussian fit
        h = waitbar(0, 'Please wait for averaging...');
        for i = 1 : frames
            img = double(bfGetPlane(data,i));
            for j = 1 : pcles
                
                if any(coord(:, j)) == 0
                    continue
                end
                
                [pcle_gauss] = define_ROI( img, abs(coord(:,j)), ROI_size_gauss);
                [maxval,idx] = max( pcle_gauss(:) ); % If A is a matrix, then max(A) is a row vector containing the maximum value of each column. Get the x index where the maxval is.
                [row,col] = ind2sub( size(pcle_gauss), idx ); % subscript of the biggest pixel in ROI
                signal_matrix ( j, i ) = mean(pcle_gauss(:)) ;
                
                pcle_ROIs(:,:,i,j) = pcle_gauss;
            end
            
            waitbar(i/frames,h)
        end
        close(h)
        
    case 'Sum'
        %% Sum over ROI
        h = waitbar(0, 'Please wait for summation...');
        if isa(data,'double')
            bg = squeeze(mean(mean(data,2),1));
            for j = 1 : pcles
                
                if any(coord(:, j)) == 0
                    continue
                end
                
                [pcle_gauss] = define_ROI( data, abs(coord(:,j)), ROI_size_gauss);
                
                signal_matrix ( j, : ) = squeeze(sum(sum(pcle_gauss,2),1)) - bg.*ROI_size_gauss^2;
                waitbar(j/pcles,h)
            end
        else
            bg = zeros(frames,1);
            for i = 1 : frames
                img = double(bfGetPlane(data,i));
                bg(i) = mean2(img);
                for j = 1 : pcles
                    
                    if any(coord(:, j)) == 0
                        continue
                    end
                    
                    [pcle_gauss] = define_ROI( img, abs(coord(:,j)), ROI_size_gauss);
                    
                    signal_matrix ( j, i ) = sum(sum((pcle_gauss(:))) - bg(i).*ROI_size_gauss^2) ;
                end
                
                waitbar(i/frames,h)
            end
        end
        close(h)
        
    case 'Sum2'
        %% Sum over ROI with more sophisticated background subtraction
        h = waitbar(0, 'Please wait for summation...');
        if isa(data,'double')
            
            dataBG = data;
            bg_temp = zeros(pcles,frames);
            xx = linspace(-(ROI_size_gauss-1)/2,(ROI_size_gauss-1)/2,ROI_size_gauss);
            [x,y] = meshgrid(xx,xx);
            xx = linspace(-(ROI_size_gauss+1)/2,(ROI_size_gauss+1)/2,ROI_size_gauss+2);
            [x2,y2] = meshgrid(xx,xx);
            for i = 1 : pcles
                ROIx = coord(1,i) + x;
                ROIy = coord(2,i) + y;
                dataBG(ROIy,ROIx,:) = NaN;
            end
            for i = 1 : pcles
                ROIx2 = coord(1,i) + x2;
                ROIy2 = coord(2,i) + y2;
                bg_temp(i,:) = mean(dataBG(ROIy2,ROIx2,:),[1 2],'omitnan');
            end
            for i = 1 : pcles
                ROIx = coord(1,i) + x;
                ROIy = coord(2,i) + y;
                dataBG(ROIy,ROIx,:) = reshape(repmat(bg_temp(i,:),ROI_size_gauss^4,1),ROI_size_gauss^2,ROI_size_gauss^2,frames);
            end
            
            bg = zeros(size(data));
            
            for i = 1 : frames
                [~, bg(:,:,i)] = BackgroundCorrection_WaveletSet(dataBG(:,:,i),5);
                if mod(i,100) == 0
                    waitbar(i/frames,h)
                end
            end
            data = data - bg;
            
            for j = 1 : pcles
                
                if any(coord(:, j)) == 0
                    continue
                end
                
                [pcle_gauss] = define_ROI( data, abs(coord(:,j)), ROI_size_gauss);
                
                signal_matrix ( j, : ) = squeeze(sum(sum(pcle_gauss,2),1));
                waitbar(j/pcles,h)
            end
        else
            img = double(bfGetPlane(data,i));
            bg = zeros([size(img) frames]);
            for i = 1 : frames
                img = double(bfGetPlane(data,i));
                [img, bg(:,:,i)] = BackgroundCorrection_WaveletSet(img,5);
                for j = 1 : pcles
                    
                    if any(coord(:, j)) == 0
                        continue
                    end
                    
                    [pcle_gauss] = define_ROI( img, abs(coord(:,j)), ROI_size_gauss);
                    
                    signal_matrix ( j, i ) = sum(sum(pcle_gauss(:))) ;
                end
                
                waitbar(i/frames,h)
            end
        end
        close(h)
end
end
%remove rows in signal_matrix that contain zero elements

% [zero_row,zero_col] = find(signal_matrix ==0 );
% zero_pcles = unique(zero_row);
% signal_matrix(zero_pcles,:)=[];
% coord(:,zero_row) = [];
