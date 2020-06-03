function y = allpassCascade(x,fb,fs,feedback)
% This function takes the input signal (x) with a specified sampling 
% frequency (fs) and passes it through a cascade of four first order 
% virtual analog allpass filters with a specified break frequency (fb, in Hz)
% for all of them. If the feedback parameter is set to 1, half of the
% processed signal is passed through three allpass filters again and summed
% with the signal processed once.

    % if feedback is engaged:
    if feedback==1
        % set the feedback gain
        fbGain =0.5;
        % process the signal through a chain of four allpass filters
        allpassOutput1 = virtualAnalogAllpass(x,fb,fs);
        allpassOutput2 = virtualAnalogAllpass(allpassOutput1,fb,fs);
        allpassOutput3 = virtualAnalogAllpass(allpassOutput2,fb,fs);
        allpassOutput4 = virtualAnalogAllpass(allpassOutput3,fb,fs);
        % take half of the processed signal and run it through three
        % allpass filters again
        feedback1 = virtualAnalogAllpass(fbGain*allpassOutput4,fb,fs);
        feedback2 = virtualAnalogAllpass(feedback1,fb,fs);
        feedback3 = virtualAnalogAllpass(feedback2,fb,fs);
        % sum the signals to create the output
        y = allpassOutput4 + feedback3;

    % if feedback is disengaged:   
    else
        % process the signal through a chain of four allpass filters
        allpassOutput1 = virtualAnalogAllpass(x,fb,fs);
        allpassOutput2 = virtualAnalogAllpass(allpassOutput1,fb,fs);
        allpassOutput3 = virtualAnalogAllpass(allpassOutput2,fb,fs);
        % output signal is the output of the last allpass filter
        y = virtualAnalogAllpass(allpassOutput3,fb,fs);
    end
end