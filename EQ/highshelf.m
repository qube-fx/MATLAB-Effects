 function [b, a]=highshelf(f0,S,dBgain,fs)
 % lowshelf function returns filter coefficients b and a 
 % for a highshelf type filter.
 %
 % Structure:
 % [b, a]=highshelf(f0,S,dBgain,fs)
 %
 % Input arguments:
 % f0 - highshelf midpoint frequency, in Hz (f0>0)
 % S - highshelf slope steepnes parameter (0<S<=1)
 % dBgain - boost/cut gain, in dB
 % fs - sampling frequency, in Hz
 %
 % Example:
 %  [b,a] = highshelf(10000,1,-2,44100)
 %  returns coefficients for a highshelf filter with 10000Hz midpoint
 %  frequency, 2dB cut, steepest possible monotonous slope, for 44100Hz
 %  sampling frequency.
 %
 % This method and calculations are taken from "Audio EQ Cookbook" by
 % Robert Bristow-Johnson. Available <a href="matlab: 
 % web('http://www.musicdsp.org/files/Audio-EQ-Cookbook.txt')">here</a>.
 
% Calculate intermediate variables:
A = 10^(dBgain/40);
w0 = 2*pi*f0/fs;
alpha = sin(w0)/2 * sqrt( (A + 1/A)*(1/S - 1) + 2 );
% Calculate filter coefficients:
b(1) = A*( (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha );
b(2) = -2*A*( (A-1) + (A+1)*cos(w0) );
b(3) = A*( (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha );
a(1) = (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha;
a(2) = 2*( (A-1) - (A+1)*cos(w0) );
a(3) = (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha;

end