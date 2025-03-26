% Output gaze metrics: total duration, fixation number, and mean fix dur 
% for a time window

function [totalDur, fixNum, meanFixDur] = getGazeMetrics(fixData,startStopMatrix)
% fixData is a .csv from Pupil & startStopMatrix is an n-by-2 matrix of
% start and stop times for the windows you want to subset



% Subset the fixation data to include only the relevant windows

for thisWindow = 1:height(startStopMatrix) % the n of the n-by-2 matrix
    if thisWindow == 1
        fixDataSubset = fixData(fixData.startTimestamp_ns_ >= startStopMatrix(thisWindow,1) & fixData.startTimestamp_ns_ <= startStopMatrix(thisWindow,2),:);
    elseif thisWindow >1
        fixDataSubset = [fixDataSubset;...
            fixData(fixData.startTimestamp_ns_ >= startStopMatrix(thisWindow,1) & fixData.startTimestamp_ns_ <= startStopMatrix(thisWindow,2),:)];
    end
end


% Block duration is the end point(s) minus the start point(s)
totalDur = (sum(startStopMatrix(:,2)-startStopMatrix(:,1)))/1000000; % milliseconds

fixNum = height(fixDataSubset); % how many fixations occurred in these windows

meanFixDur = mean(fixDataSubset.duration_ms_); % average fixation duration in milliseconds

% 
% % Sanity check the subsetting
% frameInds = [];
% for fixNum = 1:height(fixDataSubset) 
%     thisFrameInd = find(worldTimestamps.timestamp_ns_> fixDataSubset.startTimestamp_ns_(fixNum) & worldTimestamps.timestamp_ns_ < fixDataSubset.endTimestamp_ns_(fixNum));
%     frameInds = [frameInds; thisFrameInd(:) ];
% end
% 
% % Video file
% v = VideoReader('/Volumes/vislearnlab/experiments/zero/data/pilot/gaze-overlay-vids/tulip003/4b4b1699_0.0-2039.205.mp4');
% clip = read(v,[frameInds(1) frameInds(end)]);
% 
% clipV = VideoWriter("newfile",'MPEG-4');
% open(clipV)
% writeVideo(clipV,clip)