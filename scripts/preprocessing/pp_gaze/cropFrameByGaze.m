% Use gaze coordinates from HMET to crop video frames 
% last updated 3.26.25
% ajh 

function gazeTileArray = cropFrameByGaze(fixData, worldTimestamps, v, startStopMatrix)

% Subset the fixation data to include only the relevant windows

for thisWindow = 1:height(startStopMatrix) % the n of the n-by-2 matrix
    if thisWindow == 1
        fixDataSubset = fixData(fixData.startTimestamp_ns_ >= startStopMatrix(thisWindow,1) & fixData.startTimestamp_ns_ <= startStopMatrix(thisWindow,2),:);
    elseif thisWindow >1
        fixDataSubset = [fixDataSubset;...
            fixData(fixData.startTimestamp_ns_ >= startStopMatrix(thisWindow,1) & fixData.startTimestamp_ns_ <= startStopMatrix(thisWindow,2),:)];
    end
end

% Relevant video frame indices
frameInds = [];
for fixNum = 1:height(fixDataSubset) % for each fixation (row)
    thisFrameInd = find(worldTimestamps.timestamp_ns_> fixDataSubset.startTimestamp_ns_(fixNum) & worldTimestamps.timestamp_ns_ < fixDataSubset.endTimestamp_ns_(fixNum));
    if isempty(thisFrameInd) % this may happen for very short fixations in lower frame rate vids 
        frameInds = [frameInds; nan ];
    else
        frameInds = [frameInds; thisFrameInd(1) ]; % video frames
    end
end

% Make the array for gaze tiles
gazeTileArray = cell([]); %nan(200,200,3,height(frameInds));

for thisFrameInd = 1:height(frameInds)
    if isnan(frameInds(thisFrameInd))
        gazeTileArray(1,thisFrameInd) = {nan(200,200,3)};
    else
        rows = round(fixDataSubset.fixationY_px_(thisFrameInd)-99):round(fixDataSubset.fixationY_px_(thisFrameInd)+100);
        cols = round(fixDataSubset.fixationX_px_(thisFrameInd)-99):round(fixDataSubset.fixationX_px_(thisFrameInd)+100);
        if max(rows) > 1200 || max(cols) > 1600 % fixation was very eccentric & we can't crop an adequate tile
            gazeTileArray(1,thisFrameInd) = {nan(200,200,3)};
        else
            frame = read(v,frameInds(thisFrameInd));
            frameInds(thisFrameInd)
            frame = (frame(rows,cols,:)); %imshow(frame)

            gazeTileArray{1,thisFrameInd} = frame;
        end
    end
end


% SANITY CHECKING
% Plot fixation on frames, uncropped
 
% for fixNum = 1:height(fixDataSubset) 
%     imshow(read(v,frameInds(fixNum)))
%     hold on
%     scatter(fixDataSubset.fixationX_px_(fixNum),fixDataSubset.fixationY_px_(fixNum),'red','filled')
%     pause()
%     close all;
% end

% save the tiles to a folder
% saveFolder = 'zero/data/gaze-tiles/';
% 
% t = tiledlayout;
% t.TileSpacing = 'compact';
% t.Padding = 'compact';
% set(gcf,'Color','white')
% 
% for fixNum = 1:height(fixDataSubset)
%     rows = round(fixDataSubset.fixationY_px_(fixNum)-99):round(fixDataSubset.fixationY_px_(fixNum)+100);
%     cols = round(fixDataSubset.fixationX_px_(fixNum)-99):round(fixDataSubset.fixationX_px_(fixNum)+100);
%     frame = read(v,frameInds(fixNum));
%     %subplot(7,8,fixNum)
%     nexttile
%     imshow(frame(rows,cols,:));
%     %imwrite(frame(rows,cols,:),[saveFolder 'test-obj1-tile' num2str(fixNum) '.jpeg'])
%     hold on
%     scatter(100,100,500,'red','LineWidth',4,'MarkerEdgeAlpha',.4)
% end
% 
