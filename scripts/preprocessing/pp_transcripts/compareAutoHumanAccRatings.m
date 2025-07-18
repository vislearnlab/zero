%% Compare accuracy for ZERO participant descriptions:
%  How does automated compare to human judgment? 
%  AJH 7.18.25

clear all; close all; clc;
projectDir = '/Users/visuallearninglab/Library/CloudStorage/GoogleDrive-amhaskins@ucsd.edu/My Drive/Projects/zero/';

% Load the CSV that contains human ratings for a subset of descriptions.
ratingsFile = readtable([projectDir ...
    'data_public/zeroDescriptionsSubsetCertaintyAccuracy.csv'],'Delimiter',',');

% Load the CSV that contains the automated descriptions
automatedFile = readtable([projectDir ...
    'data_public/participantDescriptionsByBlockEmbeddings_CosSim.csv'],'Delimiter',',');

% Create a table/CSV combining automated vs. human-rated accuracy on subset

% Loop through each of the human-rated descriptions
newSubsetTable = table('Size',[0 6], 'VariableTypes', {'string','string','double',...
    'double','double','double'},'VariableNames',{'SubjectID','ObjectID','TalkBlock',...
    'HumanAcc1','HumanAcc2','AutoAcc'});

for thisDescription = 1:height(ratingsFile)
    thisDescRowInAutomated = find(...
        contains(automatedFile.subject_name, ratingsFile.SubjectID(thisDescription)) & ...
        contains(automatedFile.object_name, ratingsFile.ObjectID(thisDescription)) & ...
        ratingsFile.TalkBlock(thisDescription) == automatedFile.talk_block);

    if isempty(thisDescRowInAutomated)
        continue
    else

        SubjectID = ratingsFile.SubjectID(thisDescription);
        ObjectID = ratingsFile.ObjectID(thisDescription);
        TalkBlock = ratingsFile.TalkBlock(thisDescription);
        HumanAcc1 = ratingsFile.accuracy_Nicole(thisDescription);
        HumanAcc2 = ratingsFile.accuracy_Tarun(thisDescription);
        AutoAcc = automatedFile.cosine_similarity_to_gt(thisDescRowInAutomated);
        newSubsetTable = [newSubsetTable; table(SubjectID,ObjectID,TalkBlock,HumanAcc1,HumanAcc2,AutoAcc)];
    end
end


humanAccAvg = mean([newSubsetTable.HumanAcc1(newSubsetTable.TalkBlock == 1) newSubsetTable.HumanAcc2(newSubsetTable.TalkBlock == 1)],2);
a = corrcoef(humanAccAvg,newSubsetTable.AutoAcc(newSubsetTable.TalkBlock == 1));

figure;
scatter(humanAccAvg,newSubsetTable.AutoAcc(newSubsetTable.TalkBlock == 1),'filled')
title(['Talk Block 1 human-auto correlation: ' num2str(a(2,1))])
xlabel('Mean Human Rating')
ylabel('Auto accuracy score')