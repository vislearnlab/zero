%% Randomize object presentation order & display on computer screen 
%  AJH 1.8.25

function timingStruct = DisplayExpPrompts(subID)

% Generate and save trial order
startDateTime = datetime;
dateStrings = char(startDateTime);
fileID = ['/Users/visuallearninglab/Library/CloudStorage/GoogleDrive-amhaskins@ucsd.edu/My Drive/Projects/zero/stim-orders/'...
    'zeroLog-' subID '-' extractBefore(dateStrings,' ')];

objectTable = readtable('zero/experiment/run-experiment/object_descriptions.csv','Delimiter',',');
objectTable.object_name_spaced = cellfun(@(x) strrep(x,'_',' '),objectTable.object_name,'UniformOutput',false);
objectNameSet = objectTable.object_name_spaced;

thisOrder = [1 randperm(length(objectNameSet)-1)+1]; % make SCISSORS appear first across all participants

printList = [extractBefore(dateStrings, ' '); 'experiment start ' ; ' '; objectNameSet(thisOrder)];
%timeList = {' '; extractAfter(dateStrings, ' '); ' '};
timingStruct = struct;

% Display to participant

close all;
f = figure('WindowState','maximized','NumberTitle','off');
set(f,'MenuBar','none')
set(f,'ToolBar','none')
set(f,'Color','black')
set(f,'DefaultTextFontSize', 14)

for trialNum = 1:length(objectNameSet)

    % KNOWLEDGE BLOCK 1
    timingStruct.(['trial' num2str(trialNum)]).KnowledgeBlock1 = ...
        knowledgeBlock(objectNameSet(thisOrder(trialNum)),1); % Ask them about object, log times

    % EXPLORATION BLOCK 1
    timingStruct.(['trial' num2str(trialNum)]).ExploreBlock1 = ...
        exploreBlock();

    % KNOWLEDGE BLOCK 2
    timingStruct.(['trial' num2str(trialNum)]).KnowledgeBlock2 = ...
        knowledgeBlock(objectNameSet(thisOrder(trialNum)),2); % Ask them about object 2nd time, log times

    % TEXT ("LEARN FROM SOMEONE") BLOCK
    textString = objectTable.description(thisOrder(trialNum));
    timingStruct.(['trial' num2str(trialNum)]).textBlock = ...
        textBlock(objectNameSet(thisOrder(trialNum)),textString);
    
    % EXPLORATION BLOCK 2
    timingStruct.(['trial' num2str(trialNum)]).ExploreBlock2 = ...
        exploreBlock();
    

end
close all;

% T = table(printList,timeList,'VariableNames',{subID,'timestamp'});
% writetable(T,fileID,'Delimiter',',')