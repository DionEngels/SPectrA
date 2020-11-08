%% Lorentzian fitting
%  This function fits data 'sca' of any scattering spectrum to a Lorentian
%  lineshape. The inital conditions are fully calculated, therefore no more
%  user input is needed for initial conditions of fitting.
%  input:       sca ---- the scattering spectrum
%               enei---- the wavelength vector (same length as sca)
%  output:      fit ---- fitted curve, the same length as enei
%               fit_Lorentz ---- fitted parameters ( Background linewidth/2pi peak linewidth  ) 
%               Rsquared ---- R2 (coefficient of determination) of the fit
%               for saving results
function [ fit_Lorentz , fit , Rsquared ] = LorentzFit( sca, enei )

    for j = 1:length(sca)
        if sca(j) <= 0
           sca(j) = 0; 
           enei(j) = 0; 
        end
    end

    sca(sca==0) = []; sca = reshape(sca,1,[]);
    enei(enei==0) = []; enei = reshape(enei,1,[]);  

    
% photon setup for Lorentzian fit
enei_ev = 1248./enei ;
lorentz_eV = linspace( 1248/min(enei), 1248/max(enei), length( enei )*7 );
lorentz_wl = 1248./lorentz_eV;   

%[ max_sca, idx_max ] = max( real( sca(:) ) ) ; % return the index of wavelength where scattering is the biggest
[ max_sca, idx_max ] = max( real(sca( real(sca(:))<max(real(sca(:))) )) ); % return the index of wavelength where scattering is the second biggest

[ min_sca, ~ ] = min( abs(real( sca(:) )) ) ; % return the index of wavelength where scattering is the smallest
init_lw =  abs(2/(pi*max_sca)*trapz( 1248./enei, real(sca) ));  % estimated value for Lorentzian fit, the linewidth. With this value, other parameters of lorentzian fit can be estimated with the maximum value of sca.

initial_guess = [min_sca min_sca.*init_lw./(2*pi) enei_ev(idx_max) init_lw];  % 3rd is the SP - put expected value according tu aspect ratio

options = optimoptions('lsqcurvefit','MaxIter',5000,'Display','off','Algorithm', 'levenberg-marquardt'); % do not show output of lsqcurvefit

[ fit_Lorentz, ~, ~, ~ ] = lsqcurvefit( @Lorentzfunction, initial_guess, enei_ev, real(sca) , [], [], options );

fit_Lorentz(4) = abs(fit_Lorentz(4));  % sometimes lsqcurvefit finds a negative linewidth. This is the correction.

if fit_Lorentz(4) < 0.02    
    lowb = abs(idx_max - round(length(sca)/4,0));
        if lowb == 0
            lowb = 1;
        end    
    highp = abs(round(3*length(sca)/4,0));
    initial_guess = [min_sca min_sca.*init_lw./(2*pi) enei_ev(idx_max) init_lw];  % 3rd is the SP - put expected value according tu aspect ratio
	[ fit_Lorentz, ~, ~, ~ ] = lsqcurvefit( @Lorentzfunction, initial_guess, enei_ev(lowb:highp), real(sca(lowb:highp)) , [], [], options );
    fit_Lorentz(4) = abs(fit_Lorentz(4));
else    
end

[Rsquared] = rsquare(real(sca),Lorentzfunction(fit_Lorentz(:),enei_ev)); % determines the R2 (coefficient of determination) of the fit

if Rsquared<0.9    
    [ fit_Lorentz, ~, ~, ~ ] = lsqcurvefit( @Lorentzfunction, [ -10 100 1248./enei(idx_max) 0.15 ], enei_ev, real(sca) , [], [], options );
    fit_Lorentz(4) = abs(fit_Lorentz(4));  % sometimes lsqcurvefit finds a negative linewidth. This is the correction.
    [Rsquared] = rsquare(real(sca),Lorentzfunction(fit_Lorentz(:),enei_ev)); % determines the R2 (coefficient of determination) of the fit
end 

fit(:,1) = lorentz_wl;
fit(:,2) = Lorentzfunction(fit_Lorentz(:),lorentz_eV); % generate fitted curve on our own energy scale

[Rsquared] = rsquare(real(sca),Lorentzfunction(fit_Lorentz(:),enei_ev)); % determines the R2 (coefficient of determination) of the fit


end