function a = habituation(devicesFolder)

% loads parameters that were set in the ToneBoxGui
load([devicesFolder 'PiParams.mat'])
 
% makes sure that a folder exists for the device that is running, if a
% folder doesn't exist then one is created
checkFolder = exist([devicesFolder,cageID]);
if checkFolder == 0
    mkdir(devicesFolder,cageID)
end
 
%removes parameters file from the Devices folder into the folder
%corresponding to the device that is running, this prevents the ToneBoxGui from
%overwriting the parameters before a device is done downloading the file.
%Once this file is moved, another device can be selected and set up back in
%the ToneBoxGui
movefile([devicesFolder 'PiParams.mat'],[devicesFolder, cageID '/PiParams.mat'])

%sets variables for certain loop stoppages to zero, quit changes to 1 when 
%the Stop buton on the ToneBoxGui is pressed and it stops the entire phase, 
%intervalStop does the same as quit except it can be accessed during an 
%inter-block interval, pauseProgram becomes 1 when all the devices are
%paused through the ToneBoxGui.
quit = 0;
intervalStop = 0;
pauseProgram = 0;

%the variables are saved to a file to be accessed later, the program will
%check the status of these variables throughout the loop to see if the Stop
%button or Pause button has been pressed on the ToneBoxGui
save([devicesFolder,cageID,'\stopButton.mat'],'quit','intervalStop','pauseProgram')
    
% checks to see if a general performance (data) file already exists in the
% folder that is associated with the device. If the file already exists, then
% that file is renamed with a message that indicates there was an error. 
% This is a failsafe, the only way this file would exist at the beginning 
% of the function is if the function had stopped unexpectedly or 
% erroneously. Otherwise, this file is deleted at the end of the function 
% and the data is saved to a separate file that is time stamped.
checkFile = exist([devicesFolder, cageID '/performance.mat']);
if checkFile == 2
    try
        load([devicesFolder, cageID '/performance.mat'])
        movefile ([devicesFolder, cageID '/performance.mat'], [devicesFolder, cageID '/performance' datestr(now,'dd-mm-yyyy_HH.MM') '_stop_error.mat'])
    
        %if the performance file exists but matlab can't load it, i.e. it is
    %corrupted, the backup file will be renamed and saved with an error
    %message
    catch
        load([devicesFolder,cageID '/performance_backup.mat'])
        movefile([devicesFolder,cageID '/performance_backup.mat'],[devicesFolder, cageID '/performance' datestr(now,'dd-mm-yyyy_HH.MM') '_stop_error.mat'])
    end
end

%variable to determine whether the phase is running trials or on an
%inter-block interval
blockInterval = 0;

%these variables indicate which phase is running, used for data analysis
phaseChoice = 1;
phaseName = 'habituation';

%records of the number of correct responses
hitCount = 0;

%records of the number of trials
totalTrials = 0;

%records of the time each trial starts
timeStamp = {};

%Compiles the licks from each trial into a matrix, each row is another 
%trial of recorded licks
lickTotal = {};

%variable used to find when the first lick occurred
lickData = [];
 
% nbins can be adjusted based depending on if the sampling rate of
% the sensor is too fast or too slow, this value was picked based on
% observing how fast a mouse can lick and react to the stimulus, the bins
% are used to break up the lick response data
nbins = 188;

% Compiles all the separate lick histograms into one big data set 
totalData = [];

%sets the x axis based on the nbins variable for plotting histograms later
%in data analysis
xaxis = linspace(0,10,nbins);

% records the first lick for all trials
lickResponse = zeros(1,nbins);

%records whether the response was a hit 'H' or a miss 'M'
responseVec = [];
 
% saves all these variables to a performance file to be saved at the end of
% each loop. this file is used for data analysis in the DataGraph GUI
save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount',...
    'xaxis','totalTrials','lickResponse','totalData','phaseChoice','cageID','timeStamp','blockInterval','responseVec')

%starts a timer that, once it reaches 60 minutes, will indicate the end of
%a block and the beginning of an inter-block interval
ibi = tic;

%quit becomes 1 when the Stop button is pressed on the ToneBoxGui
while quit == 0
    
    %creates a backup file for the data
    copyfile([devicesFolder, cageID '/performance.mat'],[devicesFolder, cageID '/performance_backup.mat'])
    
    %if an error occurs, then the value will become 1 and the data for that
    %trial will be voided. The raspberry pi sometimes will drop connection
    %and the few commands that get sent to the pi will cause the program to
    %pause and error. There are try-catch loops for each command sent to
    %the raspberry pi. If an error occurs, the raspberry pi connection will
    %be deleted and reloaded from the parameters file.
    error = 0;
    
    % checks the quit variable at the beginning of each loop, if quit is 1
    % then the loop will run once more and then stop
    load([devicesFolder, cageID '/stopButton.mat']);
    
    %records the number of trials
    totalTrials = totalTrials + 1;
     
    %records the time of each trial
    timeStamp = [timeStamp; {totalTrials datestr(now,'mm/dd/yyyy HH:MM:SS')}];
    
    save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount',...
    'xaxis','totalTrials','lickResponse','totalData','phaseChoice','cageID','timeStamp','blockInterval','responseVec')

    %if the trial results in a correct response, hit will equal 1
    hit = 0;
    
    %records the licks of the current trial, then resets each loop
    lickTrial = [];
     
    %tests to make sure the raspberry pi is connected, if not, the
    %connection variable rpi is deleted and reloaded from the parameters
    %file, error is changed to 1 so that data will be voided at the end
    try
        system(rpi,'hostname');
    catch
        disp('connection error 1')
        datestr(now,'mm/dd/yyyy HH:MM:SS')
        clear rpi
        load([devicesFolder, cageID '/PiParams.mat'],'rpi')
        error = 1;
    end
     
    % timer for the beginning of each trial
    A = tic;
    
    % tells the raspberry pi to turn on the solenoid to deliver water
    try
        writeDigitalPin(rpi, 13, 1)
        disp('solenoid on')
    catch
        disp('connection error 2')
        datestr(now,'mm/dd/yyyy HH:MM:SS')
        clear rpi
        load([devicesFolder, cageID '/PiParams.mat'],'rpi')
        pause(5)
        error = 1;
    end
    
    % time of a trial is 10 seconds, the resposne-window is the length of
    % the trial, so any lick response during the 10s is considered a hit.
    % if no response occurs, the the trial is a miss
    while toc(A) <= 10
        
        %this 5s loop designates how long the water is on, once 5s is up,
        %the water gets turned off
        while toc(A) <= 5
            
            % tells the raspberry pi to read the capacitive touch sensor
            try
                lickPin = readDigitalPin(rpi, 5);
            catch
                disp('connection error 3')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
            end
            
            % lickTrial will be timestamped every time the capacitive touch
            % sensor is triggered, this is how licks are recorded each trial
            if lickPin == 1
                lickTrial = [lickTrial; toc(A)]; %logs when in time the capacitive sensor is triggered (aka licks)
            end
            
            % these conditions indicate a "hit" and the last condition
            % ensures that this happens only once during the trial
            if lickPin == 1 && length(lickTrial) == 1
                hit = 1;
            end
            
        end
        
        %tells the raspberry pi to turn off the solenoid
        try
            writeDigitalPin(rpi,13,0)
            disp('Solenoid off')
        catch
            disp('connection error 4')
            datestr(now,'mm/dd/yyyy HH:MM:SS')
            clear rpi
            load([devicesFolder, cageID '/PiParams.mat'],'rpi')
            pause(5)
            error = 1;
            writeDigitalPin(rpi,13,0)
        end
        
        %second half of the trial with the water off
        while toc(A) >5 && toc(A) <= 10

            %tells the raspberry pi to keep reading the capacitive touch
            %sensor
            try
                lickPin = readDigitalPin(rpi, 5);
            catch
                disp('connection error 5')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
            end

            if lickPin == 1
                lickTrial = [lickTrial; toc(A)];
            end

            if lickPin == 1 && length(lickTrial) == 1
                hit = 1;
            end
        end
        
    end

    if error == 0
        % these count variables are used for a histogram to show
        % quantitatively how the mouse responded. the responseVec vector
        % also saves the type of response with a corresponding letter
        if hit == 1
            disp('hit')
            hitCount = hitCount + 1;
            responseVec = [responseVec,'H'];
        else
            disp('miss')
            responseVec = [responseVec,'M'];
        end
        
        % inter-trial interval is a random value from 30 to 300 seconds in
        % 30 second increments
        delay = randsample(30:30:300,1)
        
        %This is an important loop because the intervalStop variable is
        %checked each loop so that if the Stop button is pressed on the
        %ToneBoxGui this loop will end immediately and will continue
        %through the rest of the code and end the program. Otherwise, iti
        %variable will increase each loop, which lasts one second, until it
        %equals the delay value and the inter-trial interval will be over
        iti = 0;
        while iti < delay && intervalStop == 0
            iti = iti + 1;
            load([devicesFolder, cageID '/stopButton.mat']);
            pause(1)
        end
        
        % Compiles the licks from each trial into a matrix, each row is 
        % another trial of recorded licks
        lickTotal = [lickTotal; {lickTrial}];
        
        % The next three lines find where the first lick occurred in the 
        % most recent trial
        lickData = cell2mat(lickTotal(totalTrials));
        % This line specifically separates the recorded licks into a histogram
        [lickHistogram,edges] = histcounts(lickData,nbins,'BinLimit',[0 10]);
        %isolates the first lick from that histogram
        firstLick = find(lickHistogram>0,1);
        
        % This logs the first lick into a histogram of all the first licks for
        % all trials
        lickResponse(1,firstLick) = lickResponse(1,firstLick) + 1;
        
        % Compiles all the separate lick histograms into one big data set
        totalData = [totalData; lickHistogram];

        save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount',...
            'xaxis','totalTrials','lickResponse','totalData','phaseChoice','cageID','timeStamp','blockInterval','responseVec')
        
    end
    
    %voids data if an error occurred during the trial
    if error == 1
        if length(responseVec) == totalTrials
            responseVec(length(responseVec)) = [];
        end
        totalTrials = totalTrials - 1;
    end
    
    % inter-block interval, after 60 minutes of trials there is a 60 minute
    % break
    if toc(ibi) > 3600
        %keeps track of loops/time
        trialTime = 0;
        %saves a variable so that the DataGraph GUI knows that the device
        %is on a break
        blockInterval = 1;
        save([devicesFolder, cageID  '/performance.mat'],'blockInterval','-append')
        % loop runs 3600 times unless stop button on ToneBoxGui is pressed, if
        % stop button is pressed, interval loop stops and main loop also
        % stops as the varialbes intervalStop and quit are both changed to
        % equal 1
        while trialTime < 3600 && intervalStop == 0
            trialTime = trialTime + 1;
            load([devicesFolder, cageID '/stopButton.mat']);
            pause(1)
        end
        %restarts the inter-block interval timer
        ibi = tic;
        %resets this variable so the status of the device is no longer on a
        %break
        blockInterval = 0;
        save([devicesFolder, cageID  '/performance.mat'],'blockInterval','-append')
    end
     
    % pauses program when Pause All button is pressed on ToneBoxGui, stops
    % the loop when the Resume All button is pressed
    while pauseProgram == 1
        pause(10)
        load([devicesFolder, cageID '/stopButton.mat']);
    end
        
end
 
% the final data will be saved to a time stamped performance file
save([devicesFolder, cageID '/performance' datestr(now,'dd-mm-yyyy_HH.MM') '.mat'],'phaseName','hitCount',...
    'xaxis','totalTrials','lickResponse','totalData','phaseChoice','cageID','timeStamp','blockInterval','responseVec')

% deletes the generic performance file
delete([devicesFolder, cageID '/performance.mat'])