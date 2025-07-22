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
newSubsetTable = table('Size',[0 7], 'VariableTypes', {'string','string','double',...
    'double','double','double','double'},'VariableNames',{'SubjectID','ObjectID','TalkBlock',...
    'HumanAcc1','HumanAcc2','AutoAcc','Tokens'});

for thisDescription = 1:height(ratingsFile)
    thisDescRowInAutomated = find(...
        contains(automatedFile.subject_name, ratingsFile.SubjectID(thisDescription)) & ...
        contains(automatedFile.object_name, ratingsFile.ObjectID(thisDescription)) & ...
        ratingsFile.TalkBlock(thisDescription) == automatedFile.block_number);

    if isempty(thisDescRowInAutomated)
        continue
    else

        SubjectID = ratingsFile.SubjectID(thisDescription);
        ObjectID = ratingsFile.ObjectID(thisDescription);
        TalkBlock = ratingsFile.TalkBlock(thisDescription);
        HumanAcc1 = ratingsFile.accuracy_Nicole(thisDescription);
        HumanAcc2 = ratingsFile.accuracy_Tarun(thisDescription);
        AutoAcc = automatedFile.cosine_similarity_to_gt(thisDescRowInAutomated);
        Tokens = automatedFile.total_tokens(thisDescRowInAutomated);
        newSubsetTable = [newSubsetTable; table(SubjectID,ObjectID,TalkBlock,HumanAcc1,HumanAcc2,AutoAcc,Tokens)];
    end
end


humanAccAvg = mean([newSubsetTable.HumanAcc1(newSubsetTable.TalkBlock == 1) newSubsetTable.HumanAcc2(newSubsetTable.TalkBlock == 1)],2);
a = corrcoef(humanAccAvg,newSubsetTable.AutoAcc(newSubsetTable.TalkBlock == 1));
% inter-rater
b = corrcoef(newSubsetTable.HumanAcc1(newSubsetTable.TalkBlock == 1),newSubsetTable.HumanAcc2(newSubsetTable.TalkBlock == 1));


close all;
figure;
    tokens = newSubsetTable.Tokens(newSubsetTable.TalkBlock == 1);
    markerSizes = rescale(tokens, 30, 1000);
    scatter(humanAccAvg,newSubsetTable.AutoAcc(newSubsetTable.TalkBlock == 1),tokens,'filled','MarkerFaceAlpha',.5)
    title(['Talk Block 1 human-human correlation: ' num2str(a(2,1))])
    xlabel('Mean Human Rating')
    ylabel('Auto accuracy score')
    xlim([.5 4.5])




% Make a variable in the automated file that logs human raters where I
% have them

mean_human_acc = nan([height(automatedFile),1]);
automatedFile = addvars(automatedFile,mean_human_acc);

for thisDescription = 1:height(ratingsFile)
    thisDescRowInAutomated = find(...
        contains(automatedFile.subject_name, ratingsFile.SubjectID(thisDescription)) & ...
        contains(automatedFile.object_name, ratingsFile.ObjectID(thisDescription)) & ...
        ratingsFile.TalkBlock(thisDescription) == automatedFile.block_number);

    if isempty(thisDescRowInAutomated)
        continue
    else
        meanHumanAccuracyThisDescription = ...
            mean([ratingsFile.accuracy_Nicole(thisDescription) ...
            ratingsFile.accuracy_Tarun(thisDescription)]);
        automatedFile.mean_human_acc(thisDescRowInAutomated) = meanHumanAccuracyThisDescription;
    end
end

writetable(automatedFile,[projectDir ...
    'data_public/participantDescriptionAccuracy_072225.csv'],'Delimiter',',');