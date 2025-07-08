% Compare gaze tile embeddings across participants

clear all; close all; clc;

% Load the file with gaze tile embeddings
embTable = readtable('/Volumes/vislearnlab/experiments/zero/data/pilot/processed/croppedImgEmb_zscore_labeled.csv','Delimiter',',','ReadVariableNames',true);
embeddingCols = find(startsWith(embTable.Properties.VariableNames,'x'));


T = table('Size',[0 6],'VariableTypes',{'categorical','categorical','double','double','double','double'},...
    'VariableNames',{'SubjectID','ObjectID','GazeBlock','FixSimVal','FixVarVal','FixNum'});


objectList = unique(embTable.objectID);

for objectIndex = 1:length(objectList)
    objectName = objectList{objectIndex};
        
        % go through each gaze block
        for blockNum = 1:2 % 2 gaze blocks
            thisBlockRows = find(contains(embTable.objectID,objectName) & embTable.block == blockNum);
            embTableThisObjThisBlock = embTable(thisBlockRows,:);
            
            for fixIndex = 1:100
                embTableThisObjThisBlockThisFix = ...
                    sortrows(embTableThisObjThisBlock(embTableThisObjThisBlock.fixNum == fixIndex,:),'subjectID'); % e.g., just 1st fixations
                
                thisFixEmbHolder = table2array(embTableThisObjThisBlockThisFix(:,embeddingCols)); 
                a = corrcoef(thisFixEmbHolder');
                % figure; imagesc(a)
                % colormap('jet')
                % set(gcf,'Color','white')
                % xticks([]); yticks([]);
                % nanmean(nanmean(a))
              
                a(a == 1) = nan; % diag
                
                meanFixSimVals = nanmean(a); % a fixation level average of its similarity 
                stdFixSimVals = nanstd(a);
                if length(meanFixSimVals)<2 % if only one person was still looking at this fixation index
                    continue
                else
                    coeffVarVals = meanFixSimVals./stdFixSimVals;
                end

                for subjectIndex = 1:height(embTableThisObjThisBlockThisFix)
                    subName = embTableThisObjThisBlockThisFix.subjectID(subjectIndex);
                    
                    rowT = table('Size',[1 6],'VariableTypes',{'categorical','categorical','double','double','double','double'},...
                    'VariableNames',{'SubjectID','ObjectID','GazeBlock','FixSimVal','FixVarVal','FixNum'});
    
                    rowT.SubjectID = categorical(cellstr(subName));
                    rowT.ObjectID = categorical(cellstr(objectName));
                    rowT.GazeBlock = blockNum;
                    rowT.FixSimVal = meanFixSimVals(subjectIndex);
                    rowT.FixVarVal = coeffVarVals(subjectIndex); 
                    rowT.FixNum = fixIndex;
                
                    T = [T; rowT]; % add this row to the omni table
                end
            end
        end
end

filename = '/Volumes/vislearnlab/experiments/zero/data/pilot/processed/fixEmbedSimilarityValuesAcrossSubs051325.csv';
writetable(T,filename,'Delimiter',',');              