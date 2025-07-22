function [keyPressTimes] = exploreBlock(blockNum)

keyPressTimes = struct;
timesKeyPressed = []; % empty holder

exploreInst = {'Now you will see an example of this object on the table next to you.';...
            'See if you can learn anything new from this example.';...
            'Press the arrow key when you have finished exploring the object.'};

promptText = text(1,1,exploreInst(1:2),'FontSize',32,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress];
delete(promptText)

promptText = text(1,1,exploreInst(3),'FontSize',32,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress];
delete(promptText)

if blockNum == 2 % second explore block

    promptText = text(1,1,{'You are finished with this object trial.'; ...
        'Get ready for a new object.'},'FontSize',40,'Color','white',...
        'HorizontalAlignment','center','VerticalAlignment','middle') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
    
    timesKeyPressed = [timesKeyPressed; waitForPress];
    delete(promptText)
end

keyPressTimes.Start = timesKeyPressed(1,:);
keyPressTimes.Stop = timesKeyPressed(2,:);
