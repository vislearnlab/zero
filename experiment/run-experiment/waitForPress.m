% Wait for key press 
function logTime = waitForPress()

currkey=0; % do not move on until enter key is pressed
    while currkey~=1
        pause; % wait for a keypress
        currkey=get(gcf,'CurrentKey'); 
        if strcmp(currkey, 'rightarrow') % 
            currkey=1;
            logTime = extractAfter(char(datetime),' ');
        else
            currkey=0;
        end
    end