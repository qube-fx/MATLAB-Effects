function stereoReverbOutput = moorersReverbStereo(input,fs,dryWet,LorR,chanDlyMS,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS)
inputL = input;
inputR = input;
inputL(:,2) = [];
inputR(:,1) = [];
reverbL = moorersReverb2(inputL,fs,dryWet,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS);
reverbR = moorersReverb2(inputR,fs,dryWet,earlyRefGain,combGain,combLPGain,APGain,APDlyS,lateRefDlyMS);
chanDlySam = round((chanDlyMS/1000)*fs);
if (LorR == 1)
    reverbL = delay(reverbL,chanDlySam);
    reverbR = [reverbR; zeros(chanDlySam,1)];
elseif (LorR == 2)
    reverbR = delay(reverbR,chanDlySam);
    reverbL = [reverbL; zeros(chanDlySam,1)];
else
    reverbL = delay(reverbL,chanDlySam);
    reverbR = [reverbR; zeros(chanDlySam,1)];
end
stereoReverbOutput = [reverbL,reverbR];
