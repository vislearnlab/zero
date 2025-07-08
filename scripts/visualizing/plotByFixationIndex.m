% Plot fixation embedding similarity 
close all;

objectList = unique(T.ObjectID);
subjectList = unique(T.SubjectID);
colors = {'red','blue'};
offset = [-.1 .1];

figure
tiledlayout
for objectID = [2 5 6 9]%1:length(objectList)
    nexttile
    thisObjectTable = T(T.ObjectID == objectList(objectID),:);   
        for block = 1:2
            for fixNum = 1:50
                rowsThisFixInd = find(thisObjectTable.GazeBlock == block & ...
                    thisObjectTable.FixNum == fixNum);
                allValsThisFixInd =  thisObjectTable.FixSimVal(rowsThisFixInd); % can also use FixVarVal
                thisFixSimValMean = nanmean(allValsThisFixInd);
                thisFixSimValSTD = nanstd(allValsThisFixInd);
                
               % plot
               scatter(repmat(fixNum+2*offset(block),[length(allValsThisFixInd),1]),allValsThisFixInd,colors{block},...
                   'filled','SizeData',30,'MarkerFaceAlpha',.2)
               hold on
               scatter(fixNum+offset(block),thisFixSimValMean,colors{block},'filled','SizeData',100)
               hold on
               xlabel('Fixation Index')
               ylabel('coeff var')
               %title(objectList(objectID))
               set(gcf,'Color','white')
              
               
            end
        end
end
                    
