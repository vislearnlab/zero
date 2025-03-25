% Use gaze coordinates from HMET to crop video frames 
% ROUGH SKETCH, needs cleaned up
% ajh 2.18.25

clear all; clc;
% Fixations file (timing in ns)
fixData = readtable('/Users/visuallearninglab/Desktop/Timeseries Data + Scene Video (3)/2025-01-17_11-33-01-dc097c0a/fixations.csv','Delimiter',',');

% Video timestamps file (timing in ns)
worldTimestamps = readtable('/Users/visuallearninglab/Desktop/Timeseries Data + Scene Video (3)/2025-01-17_11-33-01-dc097c0a/world_timestamps.csv','Delimiter',',');
worldTimestamps.timestamp_sec_ = worldTimestamps.timestamp_ns_/1000000000;
worldTimestamps.time_elapsed_ = worldTimestamps.timestamp_sec_(:) - worldTimestamps.timestamp_sec_(1);

% Video file
v = VideoReader('/Users/visuallearninglab/Desktop/Timeseries Data + Scene Video (3)/2025-01-17_11-33-01-dc097c0a/7757d56a_0.0-1153.477.mp4');

% Time window in seconds
thisObjectTimes = 283:307.5;
theseTimestamps = worldTimestamps.timestamp_ns_(find(worldTimestamps.time_elapsed_ >= thisObjectTimes(1) & worldTimestamps.time_elapsed_ <= thisObjectTimes(end)));

% Fixation table for this time window
fixDataSubset = fixData(fixData.startTimestamp_ns_ >= theseTimestamps(1) & fixData.startTimestamp_ns_ <= theseTimestamps(end),:);

% Relevant video frame indices
frameInds = [];
for fixNum = 1:height(fixDataSubset) 
    thisFrameInd = find(worldTimestamps.timestamp_ns_> fixDataSubset.startTimestamp_ns_(fixNum) & worldTimestamps.timestamp_ns_ < fixDataSubset.endTimestamp_ns_(fixNum));
    frameInds = [frameInds; thisFrameInd(1) ];
end

% Plot fixation on frames, uncropped
 
% for fixNum = 1:height(fixDataSubset) 
%     imshow(read(v,frameInds(fixNum)))
%     hold on
%     scatter(fixDataSubset.fixationX_px_(fixNum),fixDataSubset.fixationY_px_(fixNum),'red','filled')
%     pause()
%     close all;
% end

% save the tiles to a folder
saveFolder = 'zero/data/gaze-tiles/';

t = tiledlayout;
t.TileSpacing = 'compact';
t.Padding = 'compact';
set(gcf,'Color','white')

for fixNum = 1:height(fixDataSubset)
    rows = round(fixDataSubset.fixationY_px_(fixNum)-99):round(fixDataSubset.fixationY_px_(fixNum)+100);
    cols = round(fixDataSubset.fixationX_px_(fixNum)-99):round(fixDataSubset.fixationX_px_(fixNum)+100);
    frame = read(v,frameInds(fixNum));
    %subplot(7,8,fixNum)
    nexttile
    imshow(frame(rows,cols,:));
    imwrite(frame(rows,cols,:),[saveFolder 'test-obj1-tile' num2str(fixNum) '.jpeg'])
    hold on
    scatter(100,100,500,'red','LineWidth',4,'MarkerEdgeAlpha',.4)
end

