function [keyPressTimes] = textBlock(textString)

keyPressTimes = struct;
timesKeyPressed = []; % empty holder

% Block instructions
textInst = {'Now you will read a paragraph about this object.';...
            'See if you can learn anything new from this description.';...
            'Press the arrow to advance through the paragraph.'};


promptText = text(1,1,textInst(1:2),'FontSize',50,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress]; % press 1
delete(promptText)

promptText = text(1,1,textInst(3),'FontSize',50,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress]; % press 2 - this is the start of reading
delete(promptText)


% Provide the descriptive blurb for each object in small chunks, and let
% people advance through at their own pace

% display object name on top
objHeader = text(1,1.75,objectName,'FontSize',120,'Color','white','HorizontalAlignment','center','VerticalAlignment','top') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;


chunkLength = 8;
textString = split(textString,' '); % separate paragraph string at word spaces 
for chunkStartIndex = 1:chunkLength:length(textString)
    if chunkStartIndex+chunkLength-1 < length(textString)
        thisChunkWordInds = chunkStartIndex:chunkStartIndex+chunkLength-1;
    else 
        thisChunkWordInds = chunkStartIndex:length(textString);
    end
    thisChunk = join(textString(thisChunkWordInds),' ');


    promptText = text(1,1,thisChunk,'FontSize',50,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

    timesKeyPressed = [timesKeyPressed; waitForPress];
    delete(promptText)

end

delete(objHeader)

keyPressTimes.Start = timesKeyPressed(2,:);
keyPressTimes.Stop = timesKeyPressed(end,:);