function [pcle]=define_ROI(tiff_stack,coord,ROI_size)

ROI = [coord(1)-(ROI_size-1)/2 coord(1)+(ROI_size-1)/2 coord(2)-(ROI_size-1)/2 coord(2)+(ROI_size-1)/2];% define the x and y coordinates of an ROI by given coord file and ROI size.

pcle = tiff_stack(round(ROI(3)):round(ROI(4)),round(ROI(1)):round(ROI(2)),:); % get the data points in the ROI. note that for image coordinate indexing, img(y,x) is used.

end