% Align Datavyu annotations and Pupil fixation data 
% AJH 3.26.25

clear all; clc;

% Set switches
makeGazeMetricTable = 1;
makeGazeTileTable = 1;
gazeBlockMaxTime = 60000; % MILLISECONDS set to inf for no limit 

% Set up directories and paths
rawDataDir = '/Volumes/vislearnlab/experiments/zero/data/pilot/raw/';
processedDataDir = '/Volumes/vislearnlab/experiments/zero/data/pilot/processed/';
blockTimesDir = '/Volumes/vislearnlab/experiments/zero/data/pilot/datavyu/';

subjectList = dir([blockTimesDir 'tulip' '*' '.csv']);
subjectList = {subjectList.name};

T = table('Size',[0 7],'VariableTypes',{'categorical','categorical','double','double','double','double','double'},...
    'VariableNames',{'SubjectID','ObjectID','PresOrder','GazeBlock','TotalBlockDur','FixCount','MeanFixDur'});

fixFrameTable = table;

for subIndex = 1:length(subjectList)

    subName = subjectList{subIndex};
    subName = extractBefore(subName,'_');

    % Get their fixation file out of the raw data directory 
    theirPupilFolder = dir([rawDataDir subName '/2025' '*']); % all the pupil folders are labeled with dates to start; hence 2025
    
    % Fixations file (timing in ns)
    fixData = readtable([rawDataDir subName '/' theirPupilFolder.name '/fixations.csv'],'Delimiter',',');
    
    % Pupil timestamps file (timing in ns, convert to ms)
    worldTimestamps = readtable([rawDataDir subName '/' theirPupilFolder.name '/world_timestamps.csv'],'Delimiter',',');
    worldTimestamps.timestamp_ms_ = worldTimestamps.timestamp_ns_/1000000;
    worldTimestamps.time_elapsed_ = worldTimestamps.timestamp_ms_(:) - worldTimestamps.timestamp_ms_(1);
    
    % Video file
    vidfilename = dir([rawDataDir subName '/' theirPupilFolder.name '/' '*.mp4']);
    vidfilename = vidfilename.name;
    vidfilename = vidfilename(3:end); % remove '._' resource fork 
    %v = VideoReader([rawDataDir subName '/' theirPupilFolder.name '/' vidfilename]);
    
    % Get their annotated gaze block data
    theirBlockTimes = readtable([blockTimesDir subName '_blocks.csv'],'Delimiter',','); % these onset/offset times are in ms, relative to video start
    
    % Get this subject's object list
    theirObjectList = unique(theirBlockTimes.event_objectName,'stable'); % the 'stable' flag keeps unique function from sorting alphabetically
    
    for objectIndex = 1:length(theirObjectList)

        for blockNum = 1:2

            objRows = find(contains(theirBlockTimes.event_objectName, theirObjectList{objectIndex}) & ...
                theirBlockTimes.event_blocknum == blockNum);

            if isempty(objRows) % e.g., they didn't look during gaze block 2
                continue
            else 
                % MAKE OMNI TABLE
                
                thisObjectTimes = [];
                for thisRow = 1:length(objRows) 
                    thisEventTimes = ...
                        worldTimestamps.timestamp_ns_(find(worldTimestamps.time_elapsed_ >= theirBlockTimes.event_onset(objRows(thisRow)) ...
                        & worldTimestamps.time_elapsed_ <= theirBlockTimes.event_offset(objRows(thisRow))));
                    thisObjectTimes = [thisObjectTimes; thisEventTimes(1) thisEventTimes(end);];

                end
                
                % Truncate based on gazeBlockMaxTime (e.g., cut off at 60 seconds max)
                if (sum(thisObjectTimes(:,2)-thisObjectTimes(:,1)))/1000000 > gazeBlockMaxTime % if this person's times exceeded the max time
                    %(sum(thisObjectTimes(:,2)-thisObjectTimes(:,1)))/1000000 % print the total 
                    
                    timesClipped = thisObjectTimes; % duplicated the start stop matrix
                    
                    while (sum(timesClipped(:,2)-timesClipped(:,1)))/1000000 > gazeBlockMaxTime % 1 minute
                        timesClipped = timesClipped(1:end-1,:); % clip a row of the matrix until the sum is less than the max time
                    end
                    
                    rowToTrim = height(timesClipped) + 1; % the last row that caused sum to exceed the max, currently removed from timesClipped
                    sumTimePrecedingRows = (sum(timesClipped(:,2)-timesClipped(:,1)))/1000000; % sum time of the preceding rows
                    remainingTimeToFill = gazeBlockMaxTime - sumTimePrecedingRows; % how much time before max time is reached
                    thisObjectTimes = [timesClipped; ... % the rows that don't exceed max
                        thisObjectTimes(rowToTrim,1) thisObjectTimes(rowToTrim,1) + (remainingTimeToFill*1000000)]; % plus the final row, but shortened
                    %(sum(thisObjectTimes(:,2)-thisObjectTimes(:,1)))/1000000
                end
                
                
                [totalDur, fixNum, meanFixDur] = getGazeMetrics(fixData,thisObjectTimes);
                
                rowT = table('Size',[1 7],'VariableTypes',{'categorical','categorical','double','double','double','double','double'},...
                'VariableNames',{'SubjectID','ObjectID','PresOrder','GazeBlock','TotalBlockDur','FixCount','MeanFixDur'});

                rowT.SubjectID = categorical(cellstr(subName));
                rowT.ObjectID = categorical(cellstr(theirObjectList{objectIndex}));
                rowT.PresOrder = objectIndex;
                rowT.GazeBlock = blockNum;
                rowT.TotalBlockDur = totalDur;
                rowT.FixCount = fixNum;
                rowT.MeanFixDur = meanFixDur;

                T = [T; rowT]; % add this row to the omni table

                
                % MAKE GAZE TILE TABLE
                if makeGazeTileTable == 1
                    fixFrameTableThisBlock = getFramesAndCoords(fixData,worldTimestamps,thisObjectTimes);
                        fixFrameTableThisBlock = addvars(fixFrameTableThisBlock,repmat(categorical(cellstr(subName)),[height(fixFrameTableThisBlock) 1]),'Before','fixInd'); % add sub info
                        fixFrameTableThisBlock = addvars(fixFrameTableThisBlock,repmat(categorical(cellstr(theirObjectList{objectIndex})),[height(fixFrameTableThisBlock) 1]),'Before','fixInd'); % add obj info
                        fixFrameTableThisBlock = addvars(fixFrameTableThisBlock,repmat(blockNum,[height(fixFrameTableThisBlock) 1]),'Before','fixInd'); % add block info
                        fixFrameTableThisBlock = addvars(fixFrameTableThisBlock,repmat(cellstr([rawDataDir subName '/' theirPupilFolder.name '/' vidfilename]),[height(fixFrameTableThisBlock) 1]),'Before','Var1');
                    fixFrameTable = [fixFrameTable; fixFrameTableThisBlock];
                end
            end
        end
    end
end

if makeGazeMetricTable == 1    
    writetable(T,[processedDataDir 'gazeMetrics.csv'],'Delimiter',',');
end

if makeGazeTileTable == 1   
    fixFrameTable = renamevars(fixFrameTable,"Var1","SubjectID");
    fixFrameTable = renamevars(fixFrameTable,"Var2","ObjectID");
    fixFrameTable = renamevars(fixFrameTable,"Var3","GazeBlock");
    
    % add an image output name and path for each frame
    savename = string;
    for i = 1:height(fixFrameTable)
        thisSavename = [char(processedDataDir) 'tiles/' char(fixFrameTable.SubjectID(i)) '_' erase(char(fixFrameTable.ObjectID(i)),' ')...
            '_block' char(num2str(fixFrameTable.GazeBlock(i))) '_fix' char(num2str(fixFrameTable.fixInd(i))) '.jpeg'];
        savename = [savename; thisSavename];
    end
    fixFrameTable = addvars(fixFrameTable,savename(2:end));
    writetable(fixFrameTable,[processedDataDir 'gazeTileFramesCoords.csv'],'Delimiter',',');
end







    % 
    % 
    % 
    %     gazeTileArray = cropFrameByGaze(fixData, worldTimestamps, v, thisObjectTimes);
    %     % save
    %     savenameprefix = ['tiles/' subName '_' erase(theirObjectList{objectIndex},' ') '_block' num2str(blockNum) '_fix'];
    % 
    %     for thisTile = 1:length(gazeTileArray)
    %         if sum(sum(sum(isnan(gazeTileArray{1,thisTile})))) == 120000 
    %             continue
    %         else
    %             imwrite(gazeTileArray{1,thisTile},[processedDataDir savenameprefix num2str(thisTile) '.jpg'])
    %         end
    %     end
    % end