%% Calculate the similarity in fixated content using gaze tile embeddings
%  AJH 

clear all; close all; clc;

% Load the file with gaze tile embeddings
embTable = readtable('/Volumes/vislearnlab/experiments/zero/data/pilot/processed/croppedImgEmb_zscore_labeled.csv','Delimiter',',','ReadVariableNames',true);
embeddingCols = find(startsWith(embTable.Properties.VariableNames,'x'));


T = table('Size',[0 8],'VariableTypes',{'categorical','categorical','double','double','double','double','double','double'},...
    'VariableNames',{'SubjectID','ObjectID','PresOrder','GazeBlock','FixSimVal','FixVarVal','FixCountThisBlock','FixNum'});


% Use the subjectID column to get a list of subjects
subjectList = unique(embTable.subjectID);
for subIndex = 1:length(subjectList)
    subName = subjectList{subIndex};

    % get the rows for this subject
    embTableThisSubject = embTable(find(contains(embTable.subjectID,subName)),:); 
    objectsThisSubject = unique(embTableThisSubject.objectID,'stable');

    % figure out which objects they saw
    for objIndex = 1:length(objectsThisSubject)
        objectName = objectsThisSubject{objIndex};
        
        % go through each gaze block
        for blockNum = 1:2 % 2 gaze blocks
            thisBlockRows = find(contains(embTableThisSubject.objectID,objectName) & embTableThisSubject.block == blockNum);
            embTableThisSubThisBlock = embTableThisSubject(thisBlockRows,:);
            embTableThisSubThisBlock = sortrows(embTableThisSubThisBlock,'fixNum');

            if height(embTableThisSubThisBlock) < 2 % if 1 or 0 fixations this block (can't calc sim)
                if height(embTableThisSubThisBlock) == 1
                    disp('skip this block: too few fixations to compute similarity') % there was 1
                else
                    continue
                end
            else
                % grab the pairwise similarities (correlation) between fixations in this block
                %a = corrcoef(table2array(embTableThisSubThisBlock(:,embeddingCols))');
                %a = corrcoef(table2array(embTableThisSubThisBlock(1:min([5 height(embTableThisSubThisBlock)]),embeddingCols))'); % check the first 5 fixations 4/8/25
                
                %% Here is what I used to iteratively calculate a fixation's similarity to preceding fixations
                %for fixIndex = 2:height(embTableThisSubThisBlock) % Starting at fix #2, iteratively compare the fixation embedding to preceding embeddings
                a = corrcoef(table2array(embTableThisSubThisBlock(:,embeddingCols))'); % 
                a = corrcoef(table2array(embTableThisSubThisBlock(1:min([5 height(embTableThisSubThisBlock)]),embeddingCols))'); % check the first 5 fixations 4/8/25

                a(a == 1) = nan; % diag 
                meanFixSimVals = nanmean(a); % a fixation level average of its similarity 
                stdFixSimVals = nanstd(a);
                if length(meanFixSimVals)<3
                    continue
                else
                    coeffVarVals = meanFixSimVals./stdFixSimVals;
                end
                % if length(meanFixSimVals) ~= fixIndex
                %     disp('Something funny here')
                % end
                % thisMeanFixSimVal = meanFixSimVals(fixIndex); % just the current fixation, relative to preceding fixations

                %% Here is where I try to calculate a fixation's similarity to a fixed window preceding it
                % for absoluteFixIndex = 2:max(embTableThisSubThisBlock.fixNum) % these are absolute indices, not relative positions in the table
                %     if isempty(find(embTableThisSubThisBlock.fixNum == absoluteFixIndex)) % we don't have data at this particular index
                %         continue
                %     else
                %         thisWindowRows = find(embTableThisSubThisBlock.fixNum >= absoluteFixIndex-2 & embTableThisSubThisBlock.fixNum <= absoluteFixIndex);
                %         if length(thisWindowRows) <2
                %             continue
                %         else
                %             a = corrcoef(table2array(embTableThisSubThisBlock(thisWindowRows,embeddingCols))'); % take the 4 fixations ahead of it 
                %             a(a == 1) = nan; % diag 
                %             meanFixSimVals = nanmean(a); % a fixation level average of its similarity 
                %             thisMeanFixSimVal = meanFixSimVals(end);
                %         end
                %     end
                
                % % get the mean similarity for each fixation
                % meanFixSimVals = nanmean(a);
                % 
                 for fixIndex = 1:length(meanFixSimVals)

                    rowT = table('Size',[1 8],'VariableTypes',{'categorical','categorical','double','double','double','double','double','double'},...
                    'VariableNames',{'SubjectID','ObjectID','PresOrder','GazeBlock','FixSimVal','FixVarVal','FixCountThisBlock','FixNum'});
    
                    rowT.SubjectID = categorical(cellstr(subName));
                    rowT.ObjectID = categorical(cellstr(objectName));
                    rowT.PresOrder = objIndex;
                    rowT.GazeBlock = blockNum;
                    rowT.FixSimVal = meanFixSimVals(fixIndex);%thisMeanFixSimVal;
                    rowT.FixVarVal = coeffVarVals(fixIndex); 
                    rowT.FixCountThisBlock = nan;
                    %rowT.FixNum = absoluteFixIndex;
                    rowT.FixNum = embTableThisSubThisBlock.fixNum(fixIndex);
    
                    T = [T; rowT]; % add this row to the omni table
                end
            end
        end
    end
end

filename = '/Volumes/vislearnlab/experiments/zero/data/pilot/processed/fixEmbedSimilarityValuesFirst5051325.csv';
writetable(T,filename,'Delimiter',',');              