function y = virtualAnalogAllpass(x, fb, fs)
% This function takes the input signal (x) with a specified sampling 
% frequency (fs) and passes it through a first order virtual analog allpass
% filter with a specified break frequency (fb), in Hz.
% Filter coefficients based on equations in Smith (2010), available at:
% https://ccrma.stanford.edu/~jos/pasp/Classic_Virtual_Analog_Phase.html

% calculate sampling time from sampling frequency
T = 1/fs;
% calculate the break frequency in rad/s
wb = 2*pi*fb;
% define filter coefficients
b(1) = 1 - wb*T;
b(2) = -1;
a(1) = 1;
a(2) = wb*T - 1;
% process the signal
y = filter(b,a,x);
end