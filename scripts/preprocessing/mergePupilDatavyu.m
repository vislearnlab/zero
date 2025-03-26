% Align Datavyu annotations and Pupil fixation data 
% AJH 3.26.25

clear all; clc;

% Set up directories and paths
rawDataDir = '/Volumes/vislearnlab/experiments/zero/data/pilot/raw/';
blockTimesDir = '/Volumes/vislearnlab/experiments/zero/data/pilot/datavyu/';

subjectList = dir([blockTimesDir 'tulip' '*' '.csv']);
subjectList = {subjectList.name};

T = table('Size',[0 7],'VariableTypes',{'categorical','categorical','double','double','double','double','double'},...
    'VariableNames',{'SubjectID','ObjectID','PresOrder','GazeBlock','TotalBlockDur','FixCount','MeanFixDur'});

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
                
                thisObjectTimes = [];
                for thisRow = 1:length(objRows) 
                    thisEventTimes = ...
                        worldTimestamps.timestamp_ns_(find(worldTimestamps.time_elapsed_ >= theirBlockTimes.event_onset(objRows(thisRow)) ...
                        & worldTimestamps.time_elapsed_ <= theirBlockTimes.event_offset(objRows(thisRow))));
                    thisObjectTimes = [thisObjectTimes; thisEventTimes(1) thisEventTimes(end);];

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

            end
        end
    end
end

    
%writetable(T,'/Volumes/vislearnlab/experiments/zero/data/pilot/processed/gazeMetrics.csv','Delimiter',',');