function [reverbOutput,fs] = moorersReverb(filename,dryWet,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS)
 % moorersReverb function adds reverb with user specified parameters 
 % to a .wav file and returns a signal representing the processed audio 
 % and its sampling frequency fs. Early reflections are simulated by a tap
 % delay line with predefined delay times and gains. Late reflections
 % network consists of six parllel comb filters with a lowpass filter in
 % the feedback loop. Their output is then processed by an allpass filter,
 % delayed by a delay line and summed with the outut of the early
 % reflections network. The reverb output is then summed with the original
 % signal, depending on the 'wetness' factor.
 %
 % Structure:
 % [reverbOutput,fs] = moorersReverb(filename,dryWet,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS)
 %
 % Input arguments:
 % filename - .wav file to which reverb will be added,
 % must be typed in with apostrophes at start and end: ex. 'snare.wav'
 %
 % dryWet - the reverb 'wetness' parameter (0<=dryWet<=1)
 % must be over or equal to zero and max 1
 % dryWet = 1 is equivalent to 100% wet
 % dryWet = 0 is equivalent to 100% dry
 %
 % earlyRefGain - is the overall gain to be applied to the gains of 
 % nineteen predefined early reflection times (0<earlyRefGain<=1)
 % Times and individual gains are based on a concert hall simulation and 
 % were used in Moorer's original reverb algorithm.
 %
 % combGain - the feedback gain in each of the comb filters (0<combGain<1)
 % Should be larger than 0 and below 1. It has an effect on the reverb
 % length (decay). The larger the value, the longer the reverb.
 %
 % combLPGain - the gain of the lowpass filter in the feedback loop of each
 % of the comb filters (0<combLPGain<1)
 % Should be larger than 0 and below 1. It has an effect on the reverb
 % length (decay). The larger the value, the longer the reverb.
 %
 % APGain - the gain of the allpass filter which processes the output of
 % comb filters (0<APGain<1).
 % It has an effect on the overall gain of the late reflections.
 %
 % APDlyS - the delay of the allpass filter, in seconds.
 %
 % lateRefDlyMS - the delay applied to the whole late reflections network,
 % in ms
 % If a negative value is used, the late reflections are shifted closer to
 % the original signal.
 %
 %  Example:
 %  [reverbOutput,fs] = moorersReverb('snare.wav',0.4,0.8,0.7,0.5,0.6,0.3,30)
 %  returns a signal extracted from 'snare.wav' with reverb at 40% wet and following parameters:
 %  earlyRefGain=0.8; combGain=0.7; combLPGain=0.5, APGain=0.6;
 %  APDlyS=0.3s and with the late reflections delyed by 30ms.
 %
 % The early reflecion times and gains and comb filter delay times were
 % taken from the original Moorer reverb design, simulating a concert hall
 % and can be found <a href="matlab: 
 % web('https://christianfloisand.wordpress.com/2012/10/18/algorithmic-reverbs-the-moorer-design/')">here</a>.
 
% read in the .wav file as 'input' and extract the sampling frequency fs
[input,fs] = audioread(filename);
% define the eraly reflecions delay times in s
earlyRefTimeS = [0.0043,0.0215,0.0225,0.0268,0.0270,0.0298,0.0458, 0.0485, 0.0572,0.0587, 0.0595, 0.0612,0.0707, 0.0708, 0.0726, 0.0741, 0.0753, 0.0797];
% define the early reflecions gains
earlyRefGains = [0.841, 0.504, 0.491,0.379, 0.380, 0.346,0.289, 0.272, 0.192,0.193, 0.217, 0.181,0.180, 0.181, 0.176,0.142, 0.167, 0.134];
% define the delay time for each comb filter
combDlyTimeS = [0.05,0.056,0.061,0.068,0.072,0.078];
%% Early reflections network
% scale the early reflections gains according to the overall gain, add 1 as
% the first argument
earlyRefGains = [1, earlyRefGain*earlyRefGains];
% convert the early reflection times from seconds to samples, add 1 as the
% first argument
earlyRefSam = [1 round(fs*earlyRefTimeS)];
% preallocate early reflections impulse response
earlyRefIR = zeros(1,fs);
% loop over the early reflections impulse response
for i=1:length(earlyRefSam)
    % assign early reflecions gain values to corresponding samples in the
    % inpulse response
    earlyRefIR(earlyRefSam(i)) = earlyRefGains(i);
end
% use convolution to combine the input signal and the early reflections
% impulse response and create a new signal
earlyRefOutput = conv(earlyRefIR,input);
% normalise the early reflections network output
earlyRefOutput = earlyRefOutput./max(earlyRefOutput);
%% Late reflections network
% convert the comb filter delay times from seconds to samples, use round
% function to ensure all values are integers
combDlySam = round(fs*combDlyTimeS);
% use the created combPar6 function to generate a combined response of six
% parallel comb filters with low pass filters in feedback loop
combOutputMain = combPar6(input,combGain,combLPGain,combDlySam);
% process the outpt of the comb filters with an allpass filter, using
% allpass function
APoutput = allpass(combOutputMain, APGain, APDlyS);
% late reflections delay line
if (lateRefDlyMS >= 0)
    % convert the late reflections delay time form ms to samples
    lateRefDlySam = round((lateRefDlyMS/1000)*fs);
    % delay the signal by padding it at the start with a number of zeros 
    % equal to the lateRefDly parameter 
    lateRefOutput = [zeros(lateRefDlySam, 1); APoutput];
    % if the signal is to be shifted closer to the original singal
elseif (lateRefDlyMS < 0)
    % take the absolute value in ms and convert it to samples
    lateRefDlySam = round((abs(lateRefDlyMS)/1000)*fs);
    % delete from the start a number of samples equal to lateRefDlySam
    APoutput(1:lateRefDlySam) = [];
    lateRefOutput = APoutput;
end
% pad the late reflections network ouput with zeros at the end to match its
% length with the length of the early reflecions output
lateRefOutput = [lateRefOutput; zeros((length(earlyRefOutput)-length(lateRefOutput)),1)];
% flip the early reflecions output array to the conventional audio format
earlyRefOutput = earlyRefOutput';
% sum the overall reverb by addaind the output of early and late reflecions
% network
reverbWet = earlyRefOutput+lateRefOutput;
% normalise to avoid clipping
reverbWet = reverbWet./max(reverbWet);
% pad the input with zeros at the end to match ist length with the length
% of the early reflecions output
input = [input; zeros((length(earlyRefOutput)-length(input)),1)];
% apply the dryWet parameter by multiplying the reverb signal by it and
% adding it to the original signal multiplied by (1-dryWet)
reverbOutput = (1-dryWet)*input+dryWet*reverbWet;
% normalise to avoid clipping
reverbOutput = reverbOutput./max(reverbOutput);