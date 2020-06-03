function y  = allpassSecondOrder(x,fn,fs,r)
% This function takes the input signal (x) with a specified sampling 
% frequency (fs) and passes it through a second order allpass
% filter with a specified notch frequency (fn, in Hz) and r parameter.
% Filter coefficients based on equations in Zozler (2011).

% define filter coefficients
b(1) = r^2;
b(2) = -2*r*cos(2*pi*fn/fs);
b(3) = 1;
a(1) = 1;
a(2) = -2*r*cos(2*pi*fn/fs);
a(3) = r^2;
% process the signal
y = filter(b,a,x);
end