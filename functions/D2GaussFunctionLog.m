function F = D2GaussFunctionLog(x,xdata)

 F = x(1) -( ( (xdata(:,:,1)-x(2)).^2 )./(2.*x(3)^2) + ((xdata(:,:,2)-x(4)).^2 )./(2.*x(3).^2) );

 