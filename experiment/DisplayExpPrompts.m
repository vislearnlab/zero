%% Randomize object presentation order & display on computer screen 
%  AJH 1.8.25

function DisplayExpPrompts(subID)

% Generate and save trial order

dateStrings = char(datetime);
fileID = ['/Users/visuallearninglab/Library/CloudStorage/GoogleDrive-amhaskins@ucsd.edu/My Drive/Projects/zero/stim-orders/'...
    'zeroLog-' subID '-' extractBefore(dateStrings,' ')];

objectNameSet = {'stethoscope', 'french press', 'shoe horn', 'fishing reel', ...
    'crank flashlight', 'rolodex', 'floppy disk', 'bulb planter', ...
    'three-hole punch','pocket radio', 'hand mixer','blood pressure cuff'};

thisOrder = randperm(length(objectNameSet));

printList = [extractBefore(dateStrings, ' '); extractAfter(dateStrings, ' '); ' '; objectNameSet(thisOrder)'];
T = table(printList,'VariableNames',string(subID));
writetable(T,fileID,'Delimiter',',')


% Display to participant

close all;
f = figure('WindowState','maximized','NumberTitle','off');
set(f,'MenuBar','none')
set(f,'ToolBar','none')
set(f,'Color','white')

for trialNum = 1:length(objectNameSet)
    th = text(1,1,'+','FontSize',100,'HorizontalAlignment','center','VerticalAlignment','middle') ;
    set(gca,'visible','off','xlim',[0 2],'ylim',[0 2],'Position',[0 0 1 1]) ;

    currkey=0; % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey'); 
        if strcmp(currkey, 'rightarrow') % 
            currkey=1;  
        else
            currkey=0;
        end
    end
    
    delete(th) % delete placeholder text
    th = text(1,1,objectNameSet(thisOrder(trialNum)),'FontSize',100,'HorizontalAlignment','center','VerticalAlignment','middle'); % OBJECT NAME

    currkey=0; % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey'); 
        if strcmp(currkey, 'rightarrow') % 
            currkey=1; 
        else
            currkey=0;
        end
    end
    
    delete(th) % delete object name
end