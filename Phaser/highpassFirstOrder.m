function y = highpassFirstOrder(x,fc,fs)
% This function takes the input signal (x) with a specified sampling 
% frequency (fs) and passes it through a first order highpass filter with a
% specified cutoff frequency (fc), in Hz.
% Filter coefficients based on equations in Zolzer (2011).

% calculate the k parameter from fc and fs
k = tan(pi*fc/fs);
% define the filter coefficients extracted from the transfer function
b(1) = 1/(k+1);
b(2) = -1/(k+1);
a(1) = 1;
a(2) = (k-1)/(k+1);
% process the input signal
y = filter(b,a,x);
end