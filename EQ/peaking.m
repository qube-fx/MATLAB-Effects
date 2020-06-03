%% Part 2. Peaking EQ filter function
 function [b, a] = peaking(f0,Q,dBgain,fs)
 % f0 is the center frequency
 % Q is the quality factor

 % dBgain is user adjustable gain in dB
 % Fs is sampling frequency
 %intermediate variables:
 A = 10^(dBgain/40);
 w0 = 2*pi*f0/fs;
 alpha = sin(w0)/(2*Q);
%filter coefficients:
b(1) = 1 + alpha*A;
b(2) = -2*cos(w0);
b(3) = 1 - alpha*A;
a(1) = 1 + alpha/A;
a(2) = -2*cos(w0);
a(3) = 1 - alpha/A;

end