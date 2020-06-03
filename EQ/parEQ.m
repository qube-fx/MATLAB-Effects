
function [output,fs] = parEQ(filename, f0LS,f0P1,f0P2,f0P3,f0P4,f0HS, dBgainLS,dBgainP1,dBgainP2,dBgainP3,dBgainP4,dBgainHS, SLS,QP1,QP2,QP3,QP4,SHS,vis) 
 % parEQ function applies user specified EQ parameters to a .wav file
 % and returns a signal representing the processed audio and its sampling
 % frequency fs.
 %
 % Structure:
 % [output,fs] = parEQ(filename, f0LS,f0P1,f0P2,f0P3,f0P4,f0HS, 
 % dBgainLS,dBgainP1,dBgainP2,dBgainP3,dBgainP4,dBgainHS, 
 % SLS,QP1,QP2,QP3,QP4,SHS,vis)
 %
 %
 % Input arguments:
 %
 % filename - .wav file to which EQ will be applied,
 % must be typed in with apostrophes at start and end: ex. 'guitar.wav'
 %
 % f0LS - lowshelf midpoint frequency, in Hz (f0LS>0)
 % f0P1-4 - center frequencies of four peaking filters, in Hz (f0P1-4>0)
 % f0HS - highshelf midpoint frequency, in Hz (f0LS>0)
 %
 % For each gain paremeter: 
 % positive values - boost, nagetive values - cut
 % dBgainLS - lowshelf gain, in dB
 % dBgainP1-4 - peaking EQ gain values, in dB
 % dBgainHS - highshelf gain, in dB
 % 
 % SLS - lowshelf slope steepnes parameter, proportional to slope in dB/octave
 % SLS must be a positive value (0<SLS<=1)
 % SLS=1 gives the steepest possible slope which is monotonically
 % decreasing or increasing with frequency. 
 %
 % QP1-4 - peaking EQ 'q' width or 'sharpness' factor values (QP1-4>0)
 % QP must be a positive value, the sharpness of the filters increases with it.
 %
 % SHS - highshelf slope steepnes parameter, analogically to SLS
 %
 % vis - parameter giving user the option to visualise the response of each
 % filter and the overall EQ curve
 % 'y' generates the response curves
 % 'n' or any other input - no visualisation
 %
 % Example:
 % [EQd, fs] = parEQ('drums.wav',30,90,400,1500,5000,10000,-10,3,-5,-6,2,4, 1,10,15,20,12,0.5, 'n');
 % Applies EQ to the file 'drums.wav' with a lowshelf cut of -10 dB at 30Hz,
 % peaking1 boost of 3dB at 90Hz, peaking2 cut of -5dB at 400Hz, peaking3
 % cut of -6dB at 1500Hz, highshelf boost of 4dB at 1000Hz. 
 % Parameters: SLS=1,QP1=10,QP2=15,QP3=20,QP4=12,SHS=0.5
 
% read in the .wav file as 'input' and extract the sampling frequency fs
[input, fs] = audioread(filename);
% derive the coefficients for each filter using separate functions
% (each explained in its corresponding function file)
[LS_b,LS_a] = lowshelf(f0LS,SLS,dBgainLS,fs);
[P1_b,P1_a] = peaking(f0P1,QP1,dBgainP1,fs);
[P2_b,P2_a] = peaking(f0P2,QP2,dBgainP2,fs);
[P3_b,P3_a] = peaking(f0P3,QP3,dBgainP3,fs);
[P4_b,P4_a] = peaking(f0P4,QP4,dBgainP4,fs);
[HS_b,HS_a] = highshelf(f0HS,SHS,dBgainHS,fs);
% to calculate coefficients for the overall EQ, the coefficients
% of all filters are convolved unsing conv() function:
% first, cofficients of the first two filters are convolved
% (lowshelf:LS_b,LS_a, peaking1 (P1_b,P1_a)
b1 = conv(LS_b,P1_b);
a1 = conv(LS_a,P1_a);
% resulting coefficients b1 and b2 are then convolved
% with coefficients of the next filter (peaking2: P2_b,P2_a)
b2 = conv(b1,P2_b);
a2 = conv(a1,P2_a);
% analogically
b3 = conv(b2,P3_b);
a3 = conv(a2,P3_a);
b4 = conv(b3,P4_b);
a4 = conv(a3,P4_a);
% until final coefficients b and a are calculated
b = conv(b4,HS_b);
a = conv(a4,HS_a);
% apply the final EQ coefficients to the input signal
% using filter()function
output = filter(b,a,input);
% normlise to avoid clipping
output = output./max(output);
% if statement controlling the visualisation:
  if vis == 'y'
    % if the user types in 'y' as the last function argument,
    % curves of each filter and overall EQ curve are visualised
    % using Filter Visualization tool fvtool()
    h = fvtool(LS_b,LS_a,P1_b,P1_a,P2_b,P2_a,P3_b,P3_a,P4_b,P4_a,HS_b,HS_a,b,a,'Fs',fs);
    set(h,'Legend','on');
    legend(h,'lowshelf','peaking1','peaking2','peaking3','peaking4','highshelf','FinalCurve');
  else
    % if the user types in 'n' or anything else, EQ is not visualised
  end
%quit the function
end