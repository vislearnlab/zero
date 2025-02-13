function [keyPressTimes] = exploreBlock()

keyPressTimes = struct;
timesKeyPressed = []; % empty holder

exploreInst = {'Now you will see an example of this object.';...
            'See if you can learn anything new from this example.';...
            'Press the arrow key when you have finished exploring the object.'};

% display object name on top
objHeader = text(1,1.75,objectName,'FontSize',120,'Color','white','HorizontalAlignment','center','VerticalAlignment','top') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

promptText = text(1,1,exploreInst(1:2),'FontSize',50,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress];
delete(promptText)

promptText = text(1,1,exploreInst(3),'FontSize',50,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

timesKeyPressed = [timesKeyPressed; waitForPress];
delete(promptText)
delete(objHeader)


keyPressTimes.Start = timesKeyPressed(1,:);
keyPressTimes.Stop = timesKeyPressed(2,:);