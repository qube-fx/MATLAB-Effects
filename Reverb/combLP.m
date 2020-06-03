function output =combLP(input,FBgain,LPgain,delay)
% combLP function applies a feedback comb filter with a low pass filter
% in the feedback to a specified input and returns a filtered output.
%
% Structure:
% output =combLP(input,FBgain,LPgain,delay)
%
% Input arguments:
%
% input - the input signal
%
% FBgain - feedback gain of the comb filter (0<FBgain<1)
% Should be less than 1 and more than 0.
%
% LPgain - the feedback gain of the low pass filter (0<LPgain<1)
% Should be less than 1 and more than 0.
%
% delay - the delay length in samples

%if the feedback gain is more than 1, set it to 0.7
if FBgain>=1
   FBgain=0.7;
end   
%if the low pass feedback gain is more than 1, set it to 0.7 .
if LPgain>=1
   LPgain=0.7;
end   
%Set the b and a coefficients of the transfer function depending on
%FBgain,LPgain and dely
b=[zeros(1,delay) 1 -LPgain];
a=[1 -LPgain zeros(1,delay-2) -FBgain*(1-LPgain)];
%filter the input signal 
output=filter(b,a,input);