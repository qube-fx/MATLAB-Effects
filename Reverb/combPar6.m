function combOutput = combPar6(input, combGain, combLPgain, combDlySam)
% combPar6 function applies six parallel comb filters with lowpass filters 
% in the feedback loop to the specified input and sums them together 
% to create the main function output.
%
% Structure:
% combOutput = combPar6(input, combGain, combLPgain, combDlySam)
%
% Input arguments:
% input - the input signal
%
%combGain - the feedback gain in each of the comb filters (0<combGain<1)
% Should be larger than 0 and below 1.
%
% combLPGain - the gain of the lowpass filter in the feedback loop of each
% of the comb filters (0<combLPGain<1)
%
% combDlySam - an array containing the delay times of the comb filters, in
% samples
 
% apply six parallel comb filters with lowpass filter in the feedback path
% using the created combLP function
combOutput1 = combLP(input, combGain, combLPgain, combDlySam(1));
combOutput2 = combLP(input, combGain, combLPgain, combDlySam(2));
combOutput3 = combLP(input, combGain, combLPgain, combDlySam(3));
combOutput4 = combLP(input, combGain, combLPgain, combDlySam(4));
combOutput5 = combLP(input, combGain, combLPgain, combDlySam(5));
combOutput6 = combLP(input, combGain, combLPgain, combDlySam(6));
 
% mix filtered signals together
combOutput = combOutput1+combOutput2+combOutput3+combOutput4+combOutput5+combOutput6;
% normalise to avoid clipping
combOutput = combOutput./max(combOutput);