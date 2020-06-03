function vectorTime = combineFrames(framesMatrix, hop)
% This function recreates signal vector (vectorTime) from the "framesMatrix"
% matrix storing all frames. The "hop" parameter defines the distance
% between two consecutive overlapping frames.
%
% This function is based on a design by Grondin (2009), available at:
% http://www.guitarpitchshifter.com/index.html

% extract the size matrix storing frames
sizeMatrix = size(framesMatrix);
% calculate the number of frames
numberFrames = sizeMatrix(1);
% calculate the size of each frame
sizeFrames = sizeMatrix(2);
% preallocate a vector to receive the result
vectorTime = zeros(numberFrames*hop-hop+sizeFrames,1);
% preassign the time index for the first frame
timeIndex = 1;
% loop for each frame and overlap-add the frames
for i=1:numberFrames
    vectorTime(timeIndex:timeIndex+sizeFrames-1) = vectorTime(timeIndex:timeIndex+sizeFrames-1) + framesMatrix(i,:)';
    % update the time index for the next frame
    timeIndex = timeIndex + hop; 
end
return