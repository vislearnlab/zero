function [keyPressTimes] = textBlock(objectName,textString)

keyPressTimes = struct;
timesKeyPressed = []; % empty holder

% Block instructions
textInst = {'Now you will read a paragraph about this object.';...
            'See if you can learn anything new from this description.';...
            'Press the arrow to advance through the paragraph.'};

promptText = text(1,1,textInst(1:2),'FontSize',32,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress]; % press 1
delete(promptText)

promptText = text(1,1,textInst(3),'FontSize',32,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress]; % press 2 - this is the start of reading
delete(promptText)


% Provide the descriptive blurb for each object in small chunks, and let
% people advance through at their own pace

chunkLength = 6;
textString = split(textString,' '); % separate paragraph string at word spaces 
lineStarts = 1:chunkLength:length(textString);

% display 3 lines of text at a time for easier reading
for topLineStart = 1:5:length(lineStarts)
    if topLineStart+4 > length(lineStarts)
        linesThisSet = topLineStart:length(lineStarts);
    else
        linesThisSet = topLineStart:topLineStart+4;
    end
    thisChunk = string;

    for line = linesThisSet
        if lineStarts(line)+chunkLength-1 < length(textString)
            thisChunkWordInds = lineStarts(line):lineStarts(line)+chunkLength-1;
        else 
            thisChunkWordInds = lineStarts(line):length(textString);
        end
        lineText = join(textString(thisChunkWordInds),' ');
        thisChunk = [thisChunk; lineText];
    end


    % display object name on top
    objHeader = text(1,1.75,objectName,'FontSize',100,'Color','white','HorizontalAlignment','center','VerticalAlignment','top') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

    promptText = text(1,1,thisChunk,'FontSize',32,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
    
    timesKeyPressed = [timesKeyPressed; waitForPress];
    delete(promptText)
    delete(objHeader)

end



keyPressTimes.Start = timesKeyPressed(2,:);
keyPressTimes.Stop = timesKeyPressed(end,:);