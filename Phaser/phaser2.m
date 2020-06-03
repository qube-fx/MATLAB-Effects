function phaser2(filename,speed,mix,feedback)
%% Phaser 2 model
% This model reads in a mono .wav file and writes a processed version to a
% new file called "phaser2.wav", saved in current MATLAB directory.
% It uses two second order allpass filters in the phase shifting stage.
%
% Input arguments:
%   - filename - filename, syntax: 'file.wav'
%   - speed - position of the "Speed" control potentiometer on the analog
%     pedal, on a scale from 0 to 100
%   - mix - position of the "Mix" control potentiometer on the analog
%     pedal, on a scale from 0 to 100
%   - feedback - 1 for feedback switch engaged, 0 for disengaged.

%% Initialization
% readn in the audio file and extract the sampling frequency
[input, fs] = audioread(filename);
% extract the speed parameter
SP = speed;
% extract the mix parameter and convert it to the amount of wet signal, 
% as part of the combined output, on a scale from 0 to 1 (mix potentiometer
% has a linear taper)
W = mix/100;
% extract feedback parameter
FB = feedback;
%% Generate LFO
% define minimum and maximum LFO rates measured on the device, in Hz
fmin = 0.0559;
fmax = 5.8824;
% define number of sample points on the vector corresponding to "Speed"
% potentiometer position
n=100;
% generate logarithimic vector from min to max LFO rate (the potentiometer
% on the analog device has a logarithmic taper)
fLFOvect=exp(linspace(log(fmin),log(fmax),n));
% extract the LFO rate from the selected potentiometer position
fLFO = fLFOvect(SP);
% extract the length of input signal
dur = length(input)/fs;
% clculate sampling time
ts = 1/fs;
% generate time vector
t = 0:ts:dur-ts; 
% define LFO shape parameter controlling the position of peaks
LFOpar = 0.82;
% generate LFO waveform
baseLFO = sawtooth(2*pi*fLFO*t,LFOpar);
% raise and scale the waveform to be positioned between 0 and 1 (amplitude)
baseLFO = (baseLFO+1)/2;
% define min and max values for the first notch frequency, in Hz
fn1min = 57.74;
fn1max = 728.99;
% map the values to the LFO1 vector
LFO1 = fn1min + (fn1max-fn1min)*baseLFO;
% define min and max values for the second notch frequency, in Hz
fn2min = 336.7;
fn2max = 4250.67;
% map the values to the LFO2 vector
LFO2 = fn2min + (fn2max-fn2min)*baseLFO;
%% Highpass filter 1
% define the highpass filter 1 cutoff frequency
fchp1 = 33;
% process the input signal with the first highpass filter
outputHighpass1 = highpassFirstOrder(input,fchp1,fs);
%% COLA preparation
% define window parameters for constant overlap-add section
winSize = 128;
% hop size defined as 1/4 of window size: 3/4 overlap
hop = 32;
% generate Hann type window 
wn = hann(winSize*2+1);
wn = wn(2:2:end);
% rotate the input vector if needed
if size(outputHighpass1,1) < size(outputHighpass1,2) 
    outputHighpass1 = transpose(outputHighpass1);
end
% pad the input signal with zeros, depending on the hop size, necessary for
% correct windowing
outputHighpass1 = [zeros(hop*3,1) ; outputHighpass1];
% create a frame matrix to store the input signal
[inputFrames,numberFramesInput] = createFrames(outputHighpass1,hop,winSize);
% preassign a frame matrix to receive processed frames
numberFramesOutput = numberFramesInput;
outputFrames = zeros(numberFramesOutput,winSize);
% preassign vector to store central sample number (with respect to
% the whole signal) of each frame
frameCentre = zeros(1,numberFramesInput);
% preassign a vector to store the first notch frequency
frameFreq1 = zeros(1,numberFramesInput);
% preassign a vector to store the second notch frequency
frameFreq2 = zeros(1,numberFramesInput);
%% Phase shifting stage
for i=1:numberFramesInput
    % get the current frame to be processed
    currentFrame = inputFrames(i,:);
    % calculate the index of central sample for each frame
    frameCentre(i) = ceil(winSize/2) + hop*(i-1);
    % get the break frequency for each frame from the LFO vector,
    % corresponding to the central sample
    frameFreq1(i) = LFO1(frameCentre(i));
    frameFreq2(i) = LFO2(frameCentre(i));
    % process each frame with the 2 second order allpass filter cascade
    outputFrame = allpassCascadeSecondOrder(currentFrame,frameFreq1(i),frameFreq2(i),fs,FB);
    % window each frame, ready for combining back to recreate the processed
    % signal
    outputFrames(i,:) = outputFrame .* wn' / sqrt(((winSize/hop)/2));    
end
% combine the frames to recreate the signal
outputPhaseShifted = combineFrames(outputFrames,hop);
% pad the end of the signal with zeros to match the length of the input
% (length changed because of COLA processing)
outputPhaseShifted = [outputPhaseShifted; zeros((length(outputHighpass1)-length(outputPhaseShifted)),1)];
%% Summing stage
% phase shifted signal is summed with the original 'dry' signal, ratio
% defined by the W parameter, extracted from the mix setting
outputSummed = (1-W).*outputHighpass1 + W.*outputPhaseShifted;
%% Highpass filter 2
% define the highpass filter 2 cutoff frequency
fchp2 = 22;
% process the signal with the highass filter
output = highpassFirstOrder(outputSummed,fchp2,fs);
%% Output
% write the signal processed by the phaser to a .wav file
audiowrite('phaser2.wav',output,fs);
end
