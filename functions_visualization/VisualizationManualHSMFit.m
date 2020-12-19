function VisualizationManualHSMFit(app, roi_number, save)
% Function that allows you to do manual fits of HSMs
% ----------------------

% get input
initial_guess = [ app.manual_fit_par1.Value app.manual_fit_par2.Value app.manual_fit_par3.Value app.manual_fit_par4.Value ];
datapoints = str2num(app.manual_fit_datapoints.Value);
% remove nans
x_axis = 1240./app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).wavelengths(datapoints);
y_axis = app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).intensity(datapoints);
x_axis = x_axis(~isnan(y_axis));
y_axis = y_axis(~isnan(y_axis));

% fit
options = optimoptions('lsqcurvefit','MaxIter',5000,'Display','off','Algorithm', 'levenberg-marquardt'); % do not show output of lsqcurvefit
[fit_result, ~, ~, ~ ] = lsqcurvefit( @LorentzFunction, initial_guess, x_axis, y_axis, [], [], options );

% post process, get R^2
fit_result(4) = abs(fit_result(4));  % sometimes lsqcurvefit finds a negative linewidth. This is the correction.
fit_result = [fit_result rsquare(y_axis,LorentzFunction(fit_result,x_axis))]; % determines the R2 (coefficient of determination) of the fit

% update plot
VisualizationUpdateHSMPlot(app, roi_number, fit_result)

% if save is true, save
if save
    app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).lambda = 1240 / fit_result(3);
    app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).linewidth = 1000 * fit_result(4);
    app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).fit_parameters = fit_result(1:4);
    app.parent_app.file_results.(app.rois{roi_number}).(app.name_hsm).R2 = fit_result(5) ;
    
end
end