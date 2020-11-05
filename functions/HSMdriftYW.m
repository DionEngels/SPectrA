function [data_output,frames,data_merged] = HSMdriftYW(data)
% The input for this function is the raw data obtained by command data = bfGetReader(FileND2)
% The output is drift-corrected set of frames and the number of frames.
% The call for this function is following: [img,frames] = HSMdrift(data);

% % % %  Needs to be tested for data showing large background.

%retrieve number of frames
omeMeta = data.getMetadataStore();
frames = omeMeta.getPixelsSizeT(0).getValue();

I = bfGetPlane(data, 1); 
data_output = zeros(size(I,1),size(I,2),frames);
data_merged = zeros(size(I,1),size(I,2),1);
offset = zeros(2,frames);



%% Here the cross correlation between neighbouring frames is done
    for i = 1:frames
        if i == 1   % because the first frame is already uploaded in I
            bg = mean(mean(I));
            data_output(:,:,i) = I;
            img_h2 = round(data_output(round(size(I,1)*0.5):round(size(I,1)*0.6),round(size(I,2)*0.5):round(size(I,2)*0.6),i)-bg);
            img_h2(img_h2<100) = 0;
            img_h2 = img_h2*10;
            img_h(:,:,i) = img_h2;        
        else
            data_output(:,:,i) = bfGetPlane(data, i);  % uploading of other frames
            bg = mean(mean(data_output(round(size(I,1)*0.5):round(size(I,1)*0.6),round(size(I,2)*0.5):round(size(I,2)*0.6),i)));
            img_h2 = round(data_output(round(size(I,1)*0.5):round(size(I,1)*0.6),round(size(I,2)*0.5):round(size(I,2)*0.6),i) - bg);
            img_h2(img_h2<100) = 0;
            img_h2 = img_h2*10;
            img_h(:,:,i) = img_h2; 
                
                % cross correlation between following frames
                C = xcorr2(double(img_h(:,:,i-1)),double(img_h(:,:,i)));
                [max_C, imax] = max(abs(C(:)));
                [ypeak, xpeak] = ind2sub(size(C),imax(1));
                offset(:,i) = [(ypeak-size(img_h,1)) (xpeak-size(img_h,2))];
                C = [];
        end    
    end

%% The drift between different frames is calculated here
                for i = 1:frames
                    if i == 1
                        offset2(:,i) = offset(:,i); 
                    else
                        offset2(:,i) = offset2(:,i-1) + offset(:,i); 
                    end       
                end

                for i = 1:frames
                     coord_corr(:,i) = offset2(:,round(frames/2)) - offset2(:,i);
                end

%% The drift between different frames is corrected here                
        max_corr = max(max(coord_corr));
        for i = 1:frames
            img_help = ones(size(I,1)+2*max_corr,size(I,2)+2*max_corr,1) .* mean(mean(data_output(:,:,i)));
            img_help(max_corr-coord_corr(1,i)+1:size(I,1)+max_corr-coord_corr(1,i),max_corr-coord_corr(2,i)+1:size(I,2)+max_corr-coord_corr(2,i),1) = data_output(:,:,i);
            data_output(:,:,i) = img_help(max_corr+1:size(I,1)+max_corr,max_corr+1:size(I,2)+max_corr,1);  
            data_merged = data_merged + double(round(abs(data_output(:,:,i) - mean(mean(data_output(:,:,i))))));            
        end
               

I = [];
img_h = [];
img_h2 = [];
bg = [];

end

