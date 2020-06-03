function [matFrames,numFrames] = createFrames(x,hop,windowSize)
% This function takes input signal (x) and divides it into overlaping
% frames. The length of the frame (in samples) is defined by "windowSize"
% parameter. The distance between two overlapping frames (in samples) is 
% defined by the "hop" parameter. The frames are stored in "matFrames"
% matrix with following dimensions: windowSize x numFrames.
%
% This function is based on a design by Grondin (2009), available at:
% http://www.guitarpitchshifter.com/index.html

% calculate the maximum number of frames that can be obtained from the signal
numFrames = floor((length(x)-windowSize)/hop);
% truncate the signal if needed to get an integer number of "hops"
x = x(1:(numFrames*hop+windowSize));
% preallocate a matrix with time frames
matFrames = zeros(floor(length(x)/hop),windowSize);
% populate the matrix
for i = 1:numFrames
    % create a time index for the start of each frame
    indexTimeStart = (i-1)*hop + 1;
    % create a time index for the end of each frame
    indexTimeEnd = (i-1)*hop + windowSize;
    % populate the matrix
    matFrames(i,:) = x(indexTimeStart: indexTimeEnd);
end
return