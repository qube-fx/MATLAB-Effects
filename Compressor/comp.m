function [compoutput,fs] = comp(filename, compType, ratio, thdB, knee, makeUpGaindB, attackms, releasems)
 % comp function applies compression with user specified parameters 
 % to a mono or stereo .wav file and returns a signal representing 
 % the processed audio, and its sampling frequency.
 %
 % Structure:
 % [compoutput,fs] = comp(filename, compType, ratio, thdB, knee, makeUpGaindB, attackms, releasems)
 %
 % Input arguments:
 %
 % filename - .wav file to which compression will be applied,
 % must be typed in with apostrophes at start and end: ex. 'kick.wav'
 %
 % compType - compression metering type. Compressor offers two types of
 % signal amplitude metering: using RMS or peak signal values.
 % use: 
 % 1 for RMS metering
 % 2 for peak metering
 % For any other input, RMS metering is used by default.
 %
 % ratio - compression ratio for positive values, presented as 1:ratio
 % For negative ratio values, the function turns into an expander. 
 % Ratio should not be set to 0.
 %
 % thdB - compressor threshold, expressed in dB 
 % Must be a negative value.
 %
 % knee - the smoothing parameter of the compressor (0<=knee<=1)
 % knee should be equal or bigger then 0 and should not exceed 1.
 % knee = 0 - hard knee, no smoothing. Sharp transition between
 % uncompressed an compressed portions of signal.
 %
 % makeUpGaindB - gain to be applied to the signal after compression, in dB
 %
 % attackms - attack time of the compressor, in ms
 % The time it takes for the compressor to start fully compressing.
 %
 % releasems - release time of the compressor, in ms
 % The time it takes for the compressor to stop compressing after the
 % signal has dropped below the threshold.
 %
 % Example:
 % [output,fs] = comp('kick.wav',2,5,-10,0.2,2,2,8)
 % returns a signal 'ouput' representing a compressed version of 'kick.wav'
 % file using peak metering, with a ratio of 1:5 and threshold set at -5dB.
 % Knee parameter is set to 0.2, attack an release to 2ms and 8ms
 % respectively.
 
% read in the .wav file as 'input' and extract the sampling frequency fs
[input, fs] = audioread(filename);
% extract the number os channels in the signal, using size function
[~,numChan] = size(input);
% if the signal is stereo
if (numChan == 2)
    % save it in a separate matrix
    inputStereo = input;
    % sum the input to mono for faster compressor performance
    input = sum(input, 2)/size(input, 2);
else
end
% translate dB gain values from logarithmic to linear
th = 10.^(thdB/20);
makeUpGain = 10.^(makeUpGaindB/20);
% set the length (in samples) of the frame over which the peak or RMS value
% is caculated to create a loudness envelope of the signal
frameLen = 100; 
% initialize the frame position
frStart = 1;
frEnd   = frameLen;
% calculate the number of frames in the input signal
% function floor used to round the number to an integer value
numFrames = floor(length(input)/frameLen);
% calculate the sampling time (time between sample points, in s)
ts = 1/fs;
% calculate the duration of the inpur, in s
dur = length(input)/fs;
% create a time representing vector
t = 0 :ts:dur-ts;
% loop over each frame to compute the loudness envelope
for i = 1:numFrames
   % create a time vector reflecting center position of each frame
   frameCtrs(i) = t(frStart+round(frEnd-frStart));
   % if RMS metering was selected
   if     (compType == 1)
       % generate RMS loudness envelope by taking th square root of the
       % mean of the sum the squared sample values in each frame 
       envPre(i) = sqrt(mean(input(frStart:frEnd).^2)); %Peak Amplitude
   % if peak metering was selected
   elseif (compType == 2)
       % generate peak loudness envelope by taking the largest value from
       % each frame
       envPre(i) = max(abs(input(frStart:frEnd)));
   % for any other user input
   else
       % use RMS metering by default
       envPre(i) = sqrt(mean(input(frStart:frEnd).^2));
   end
   % move onto the next frame
   frStart = frStart+frameLen;
   frEnd = frEnd+frameLen;
end
% interpolate the envelope using frame center positions, actual values of
% the envelope and the time vector
env = interp1(frameCtrs, envPre, t);
% to ensure error free operation, non-numerical envelope arguments (which might have
% been generated during envelope creation) are removed with the help of
% isnan function
env = env(~isnan(env));
% the same process is applied to the time vector...
t   = t(~isnan(env));
% and the input signal, to ensure the same length of all those arrays
input   = input(~isnan(env));
% calculate the quadratic spline knee coffeicients from threshold and knee
% arguments
c0 = -((ratio - 1.0) * (th * th - knee * th + knee * knee / 4.0)) / (2.0 * knee * ratio);
c1 = ((ratio - 1) * th + (ratio + 1) * knee / 2.0) / (knee * ratio);
c2 = (1 - ratio) / (2.0 * knee * ratio);
% preallocate the gain reduction array, which will hold gain values for each
% sample after compression
gain = zeros(length(env), 1);
% prellocate the output envelope, used to calculate the gain reduction
envOut = zeros(1, length(env)); 
% loop over every sample in the loudness envelope
for n = 1:length(env)
    % calculate the uncompressed part of the signal:
    % if the envelope value is smaller than the threshold minus half of the
    % knee parameter...
    if (env(n) <= th - (knee*0.5))
        % there is no gain reduction for that sample (linear gain = 1)
        gain(n) = 1;
        % the output envelope value is the same as the loudness envelope
        envOut(n) = env(n);
    % calculate the compressed part of the signal:
    % if the envelope value is bigger than the threshold plus half of the
    % knee parameter...
    elseif (env(n) > th + (knee*0.5))
        % the output envelope for that sample is compressed according to
        % the threshold and ratio values
        envOut(n) = th + (env(n)-th)/ratio;
        % gain reduction for that sample is calculated from the envelopes
        gain(n) = envOut(n)/env(n);
    % if the signal falls within the knee parameter width
    else
        % calculate the output envelope using precomputed knee coefficients
        envOut(n) = env(n) * env(n) * c2 + env(n) * c1 + c0;
        % gain reduction for that sample is calculated from the envelopes
        gain(n) = envOut(n)/env(n);   
    end
end
% translate attack and relese times from ms to samples
attacksam = (attackms/1000)*fs;
releasesam = (releasems/1000)*fs;
% calculate exponential coefficients for a smoothing filter to be applied
% to the gain reduction array to reflect the effects of attack and release 
attackC = exp(-1 / attacksam);
releaseC = exp(-1 / releasesam);
% loop over the gain array
for j=2:length(gain-1)
    % if the gain of a sample is smaller than the gain of the previous one
    % (if the gain reduction is increasing - the compressor compresses more)
    if  gain(j) < gain(j-1)
        % apply smoothng to the gain reduction array using the attack coefficient
        gain(j) = attackC * gain(j-1) + (1-attackC) * gain(j);
    % if the gain is increasing (the gain reduction decreasing - compressor is compressing less)
    else
        % apply smoothing to the gain reduction array using the release
        % coefficient
        gain(j) = releaseC * gain(j-1) + (1-releaseC) * gain(j);
    end
end
% if the input is mono
if (numChan == 1)
    % the output of the compressor if calculated by multiplying the input
    % and the gain reduction array
    compoutput = input.*gain;
% in the input is stereo
else
    % isolate the left channel
    inputL = inputStereo(:,1);
    % isolate the right channel
    inputR = inputStereo(:,2);
    % apply non-numerical values removal process to both channels
    % individually, to ensure the same length as the envelope and gain
    % reduction array
    inputL = inputL(~isnan(env));
    inputR = inputR(~isnan(env));
    % join the channels back together to a new matrix
    inputStereo = [inputL, inputR];
    % create stereo gain matrix with the same gain reduction for both
    % channels
    gainStereo = [gain, gain];
    % apply the gain reduction
    compoutput = inputStereo.*gainStereo;
end
% apply the makeup gain to the signal
compoutput = compoutput*makeUpGain;
end