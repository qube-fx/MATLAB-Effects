function reverbOutput = moorersReverb2(input,fs,dryWet,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS)


earlyRefTimeS = [0.0043,0.0215,0.0225,0.0268,0.0270,0.0298,0.0458, 0.0485, 0.0572,0.0587, 0.0595, 0.0612,0.0707, 0.0708, 0.0726, 0.0741, 0.0753, 0.0797];

earlyRefGains = [0.841, 0.504, 0.491,0.379, 0.380, 0.346,0.289, 0.272, 0.192,0.193, 0.217, 0.181,0.180, 0.181, 0.176,0.142, 0.167, 0.134];

combDlyTimeS = [0.05,0.056,0.061,0.068,0.072,0.078];

earlyRefGains = [1, earlyRefGain*earlyRefGains];
earlyRefSam = [1 round(fs*earlyRefTimeS)];
earlyRefIR = zeros(1,fs);

for i=1:length(earlyRefSam)
    earlyRefIR(earlyRefSam(i)) = earlyRefGains(i);
end

earlyRefOutput = conv(earlyRefIR,input);

earlyRefOutput = earlyRefOutput./max(earlyRefOutput);

%audiowrite('rev.wav',y,fs);


combDlySam = round(fs*combDlyTimeS);
% comb-filter phase:


combOutputMain = combPar6(input,combGain,combLPGain,combDlySam);

APoutput = allpass(combOutputMain, APGain, APDlyS);

if (lateRefDlyMS >= 0)
    lateRefDlySam = round((lateRefDlyMS/1000)*fs);
    lateRefOutput = [zeros(lateRefDlySam, 1); APoutput];
    %lateRefOutput(length(input)+1:length(lateRefOutput)) = [];
elseif (lateRefDlyMS < 0)
    lateRefDlySam = round((abs(lateRefDlyMS)/1000)*fs);
    APoutput(1:lateRefDlySam) = [];
    lateRefOutput = APoutput;
end

lateRefOutput = [lateRefOutput; zeros((length(earlyRefOutput)-length(lateRefOutput)),1)];

earlyRefOutput = earlyRefOutput';

reverbWet = earlyRefOutput+lateRefOutput;
reverbWet = reverbWet./max(reverbWet);

input = [input; zeros((length(earlyRefOutput)-length(input)),1)];

reverbOutput = (1-dryWet)*input+dryWet*reverbWet;
reverbOutput = reverbOutput./max(reverbOutput);
end