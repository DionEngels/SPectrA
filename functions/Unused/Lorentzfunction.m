function F = Lorentzfunction(x,xdata)
 F = x(1)+x(2)./((xdata-x(3)).^2+(0.5*x(4)).^2);