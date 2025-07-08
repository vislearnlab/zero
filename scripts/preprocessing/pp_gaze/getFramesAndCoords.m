function outTable = getFramesAndCoords(fixData, worldTimestamps, startStopMatrix)

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
        frameInds = [frameInds; thisFrameInd(1) ]; % video frames; take the first if there are multiple 
    end
end

% Store frame info & gaze coordinates for cropping

Xcoord = [];
Ycoord = [];

for thisFrameInd = 1:height(frameInds)
    if isnan(frameInds(thisFrameInd))
        Xcoord = [Xcoord; nan];
        Ycoord = [Ycoord; nan];
    else
        rows = round(fixDataSubset.fixationY_px_(thisFrameInd)-99):round(fixDataSubset.fixationY_px_(thisFrameInd)+100); %  
        cols = round(fixDataSubset.fixationX_px_(thisFrameInd)-99):round(fixDataSubset.fixationX_px_(thisFrameInd)+100);
        if max(rows) > 1200 || max(cols) > 1600 % fixation was very eccentric & we can't crop an adequate tile
            Xcoord = [Xcoord; nan];
            Ycoord = [Ycoord; nan];        
        else
            Xcoord = [Xcoord; round(fixDataSubset.fixationX_px_(thisFrameInd))]; % round these 
            Ycoord = [Ycoord; round(fixDataSubset.fixationY_px_(thisFrameInd))];
        end
    end
end

inds = 1:height(frameInds); fixInd = inds';
outTable = table(fixInd,frameInds,Xcoord,Ycoord);