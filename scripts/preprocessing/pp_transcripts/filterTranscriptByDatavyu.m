%% Create a CSV file with all ZERO participant utterances 


% Relevant folders
projectDir = '/Volumes/vislearnlab/experiments/zero/';
transcriptDir = [projectDir 'data/pilot/processed/transcripts/'];
datavyuDir = [projectDir 'data/pilot/datavyu/']; 

% Make a subject list
subList = dir([datavyuDir '*.csv']);
subList = subList(startsWith({subList.name},'t')); % ignore the ._ files
subList = {subList.name}; % just get their names, this is a cell array

% Start the empty table
T = table('Size',[0 4],'VariableTypes',{'categorical','categorical','double','string'},...
                    'VariableNames',{'SubjectID','ObjectID','TalkBlock','Transcription'});

% Loop through subjects
for subIndex = 1:length(subList)
    thisSubName = extractBefore(subList{subIndex},'_');
   
    thisSubTranscript = readtable([transcriptDir thisSubName '_corrected.csv'],'Delimiter',',');
    if ismember(thisSubTranscript.Properties.VariableNames(1),{'utterance_correct','utterance_before','utterance_correcter'})
        thisSubTranscript = renamevars(thisSubTranscript,thisSubTranscript.Properties.VariableNames(1),'utterance_corrected');
    end


    %%      ajh needs to check in with nicole about conventions 
    thisSubTranscript(contains(thisSubTranscript.utterance_corrected,'None'),:) = []; % delete rows where nothing was said
    utterance_use = string; % create a new variable using either the raw (correct) or corrected transcript, while preserving these 2 variables
    for thisRow = 1:height(thisSubTranscript)
        if isempty(thisSubTranscript.utterance_corrected{thisRow}) % no correction made
            utterance_use = [utterance_use; thisSubTranscript.utterance_raw{thisRow}];
        else
            utterance_use = [utterance_use; thisSubTranscript.utterance_corrected{thisRow}];
        end
    end
    thisSubTranscript = addvars(thisSubTranscript,utterance_use(2:end),'NewVariableNames','utterance_use','Before','utterance_corrected');
    

    thisSubBlocks = readtable([datavyuDir thisSubName '_blocks.csv'],'Delimiter',',');
    thisSubBlocks.event_objectName = cellfun(@(x) strrep(x,' ',''),thisSubBlocks.event_objectName,'UniformOutput',false);
    thisSubBlocks(contains(thisSubBlocks.event_blocktype,'gaze'),:) = []; % remove the gaze blocks

    thisSubObjectList = unique(thisSubBlocks.event_objectName,'Stable');


    for objIndex = 1:length(thisSubObjectList)
        objName = thisSubObjectList{objIndex};
        for block = 1:2 % 2 talk blocks
            transcriptRowsToConcatenate = []; 
            windowsThisBlock = find(contains(thisSubBlocks.event_objectName, objName) ...
                & thisSubBlocks.event_blocknum == block);
            
            for thisWindow = 1:length(windowsThisBlock) % get the times this block happened
                timestampsThisBlock = ... % also add 2 sec of padding on either side
                    [(thisSubBlocks.event_onset(windowsThisBlock(thisWindow))/1000)-2 ...
                    (thisSubBlocks.event_offset(windowsThisBlock(thisWindow))/1000)+2]; % convert onset and offset from ms to sec
                % get the relevant transcript rows that fall within these times

                transcriptRowsToConcatenate = [transcriptRowsToConcatenate; ...
                    find(thisSubTranscript.segment_start_time >= timestampsThisBlock(1) &...
                    thisSubTranscript.segment_end_time <= timestampsThisBlock(2))];
            end
          
            talkingThisBlock = strjoin(thisSubTranscript.utterance_use(transcriptRowsToConcatenate));

            rowT = table('Size',[1 4],'VariableTypes',{'categorical','categorical','double','string'},...
                'VariableNames',{'SubjectID','ObjectID','TalkBlock','Transcription'});

                rowT.SubjectID = categorical(cellstr(thisSubName));
                rowT.ObjectID = categorical(cellstr(objName));
                rowT.TalkBlock = block;
                rowT.Transcription = talkingThisBlock;

                T = [T; rowT]; % add this row to the omni table

            
        end
    end
end

allUtterancesFilename = [transcriptDir 'zeroDescriptionsByBlock.csv'];
writetable(T,allUtterancesFilename,'Delimiter',',');

%% Get a subset for human rating
numTalkBlocks = height(T);
numForValidation = round(numTalkBlocks/5); %20 percent?

rowsToValidate = randsample(numTalkBlocks,numForValidation);
validationFilename = [transcriptDir 'zeroDescriptionSubsetHumanRated.csv'];
writetable(T(rowsToValidate,:),validationFilename,'Delimiter',',');