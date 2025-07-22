% assess object knowledge via structured prompting
% participant advances by keypress

function [keyPressTimes] = knowledgeBlock(objectName,blockNum)

keyPressTimes = struct;
timesKeyPressed = []; % empty holder

textToDisplay = ...
    {' ';... 
    'Press the arrow to advance';...
    'Describe how this object typically looks and what it is made of';... %(#3)
    '+';... % blank screen during talking (#4)
    'Describe how this object works and what it is used for';... %(#5)
    %'+';... % blank screen during talking (#6)
    %'Describe the kind of person who might own or use this object';... %(#7)
    '+';}; % blank screen during talking (#8)

% Instructions / intro
if blockNum ==1
    knowInst = 'Describe what you know about this object:';
    
elseif blockNum ==2
    knowInst = {'Describe what you know about this object.';...
        'Be as thorough as you can.';...
        'It is OK to repeat the things you said previously.'};
end

promptText = text(1,1,knowInst,'FontSize',40,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;
waitForPress;
delete(promptText)

% Display each of the knowledge prompts below the object name
for promptNum = 1:length(textToDisplay)

    % display object name on top
    objHeader = text(1,1.75,objectName,'FontSize',100,'Color','white','HorizontalAlignment','center','VerticalAlignment','top') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

    % with additional text at center
    promptText = text(1,1,textToDisplay(promptNum),'FontSize',30,'Color','white','HorizontalAlignment','center','VerticalAlignment','middle') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

    timesKeyPressed = [timesKeyPressed; waitForPress];
    
    delete(objHeader)
    delete(promptText)
end


keyPressTimes.Appearance.Start = timesKeyPressed(3,:);
keyPressTimes.Appearance.Stop = timesKeyPressed(4,:);
keyPressTimes.Function.Start = timesKeyPressed(5,:);
keyPressTimes.Function.Stop = timesKeyPressed(6,:);
%keyPressTimes.Social.Start = timesKeyPressed(7,:);
%keyPressTimes.Social.Stop = timesKeyPressed(8,:);

