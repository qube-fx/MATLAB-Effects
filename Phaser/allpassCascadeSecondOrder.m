function y = allpassCascadeSecondOrder(x,fn1,fn2,fs,feedback,r)
% This function takes the input signal (x) with a specified sampling 
% frequency (fs) and passes it through a cascade of two second order 
% virtual analog allpass filters with a specified notch frequenccies 
% (fn1, fn2; in Hz) for both of them. If the feedback parameter is set 
% to 1, 0.1 portion of the processed signal is passed through both
% filters again and summed with the signal processed once.

    % if feedback is engaged:
    if feedback==1
        % set the feedback gain
        fbGain = 0.1;
        % process the signal through a chain of two allpass filters
        allpassOutput1 = allpassSecondOrder(x,fn1,fs,r);
        allpassOutput2 = allpassSecondOrder(allpassOutput1,fn2,fs,r);
        % take 0.1 of the processed signal and run it through both
        % allpass filters again
        feedback1 = allpassSecondOrder(fbGain*allpassOutput2,fn1,fs,r);
        feedback2 = allpassSecondOrder(feedback1,fn2,fs,r);
        % sum the signals to create the output
        y = allpassOutput2 + feedback2;
        
    % if feedback is disengaged: 
    else
        % process the signal through a chain of two allpass filters
        allpassOutput1 = allpassSecondOrder(x,fn1,fs,r);
        % output signal is the output of the second allpass filter
        y = allpassSecondOrder(allpassOutput1,fn1,fs,r);
    end
end