function a = shaping(devicesFolder)

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
phaseChoice = 2;
phaseName = 'shaping';

%records of the number of each responses, respectively conditional hit,
%hit, early, and miss
condHitCount = 0;
hitCount = 0;
earlyCount = 0;
missCount = 0;

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
nbins = 75;

% Compiles all the separate lick histograms into one big data set
totalData = [];

%sets the x axis based on the nbins variable for plotting histograms later
%in data analysis
xaxis = linspace(0,4,nbins);

% records the first lick for all trials
lickResponse = zeros(1,nbins);

% saves target tone selections from ToneBoxGui to this function
target = targetChoice;

%records which tone played during that trial
toneVec = [];

%records whether the response was a hit 'H', early 'E', a miss 'M', or a
%conditional hit 'C'
responseVec = [];

% saves all these variables to a performance file to be saved at the end of
% each loop. this file is used for data analysis in the DataGraph GUI
save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount','condHitCount',...
    'xaxis','totalTrials','lickResponse','totalData','target','phaseChoice','cageID','timeStamp','blockInterval','toneVec','responseVec')

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
    
    %if the trial results in the corresponding response, the variable will
    %equal 1
    condHit = 0;
    hit = 0;
    early = 0;
    
    % in this phase, mice are rewarded 20% of misses
    randomNumber = randi(100);
    percent = 20;
    
    %records the licks of the current trial, then resets each loop
    lickTrial = [];
    
    % variable used later for controlling solenoid, makes sure the solenoid
    % is only triggered once
    cond = 0;
    
    % sound files are stored as Tone_XkHz_0dB, and the different values of
    % X are the different tone frequencies. The sound variable selects a
    % random value from the specific tones that were selected in the
    % ToneBoxGui
    sound = num2str(target(randi(length(target))));
    
    %records which tone is played each trial
    toneVec = [toneVec,{num2str(sound)}];
    
    % saves all these variables to a performance file to be saved at the end of
    % each loop. this file is used for data analysis in the DataGraph GUI
    save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount','condHitCount',...
    'xaxis','totalTrials','lickResponse','totalData','target','phaseChoice','cageID','timeStamp','blockInterval','toneVec','responseVec')
    
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
    
    % this delay ensures that a new trial doesn't start until that the
    % animal hasn't licked for 5 consecutive seconds
    C = tic;
    lickPin = 0;
    while toc(C) < 5 && intervalStop == 0
        
        % tells the raspberry pi to read the capacitive touch sensor
        try
            lickPin = readDigitalPin(rpi, 5);
        catch
            disp('connection error 2')
            datestr(now,'mm/dd/yyyy HH:MM:SS')
            clear rpi
            load([devicesFolder, cageID '/PiParams.mat'],'rpi')
            pause(5)
            error = 1;
        end
        if lickPin == 1
            C = tic;
        end
        w = toc(C);
    end
    
    %starts a timer to help align the sound file with the trial time
    V = tic;
    
    % command to raspberry pi to play random sound selection
    system(rpi,['sudo mplayer /home/tonebox/Tone_' sound 'kHz_0dB.wav </dev/null >/dev/null 2>&1 &']);
    % ensures that the sound begins at 1 second in the trial, there is a
    % delay between calling the command and executing the command
    while toc(V) < .66
        A = 0;
    end
    
    % timer for the beginning of each trial
    A = tic;
    
    % time of a trial is 4 seconds, the response window is between 1 and 3
    % seconds
    while toc(A) < 4
        
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
        % stipulates that after the first lick, the solenoid will get
        % triggered
        if toc(A) >= 1 && toc(A) <=1.5 && lickPin == 1 && early == 0 && length(lickTrial) == 1
            hit = 1;
            
            % the reward is 2 seconds of water so the second timer keeps
            % track to turn the solenoid on for 2 seconds
            B = tic;
            while toc(B) <= 2
                
                % tells the raspberry pi to turn on the solenoid to 
                % deliver water
                try
                    writeDigitalPin(rpi, 13, 1)
                    disp('solenoid on');
                catch
                    disp('connection error 4')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
                
                % tells the raspberry pi to read the capacitive touch
                % sensor so the licks during this period are still recorded
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
            end
            
            %tells the raspberry pi to turn off the solenoid after 2 sec
            try
                writeDigitalPin(rpi,13,0)
            catch
                disp('connection error 6')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
                writeDigitalPin(rpi,13,0)
            end
        end
        
        % 20% of trials will get conditional water at 1.5 seconds if there
        % has not already been a correct hit response recorded, if there is
        % a response within this conditional water delivery window then the
        % response is recorded as a conditional hit
        if randomNumber < percent && toc(A) > 1.5 && toc(A) <= 3 && lickPin == 1 && early == 0 && length(lickTrial) == 1
            condHit = 1;
        end
        
        % if the trial is selected to be a conditional water trial but the
        % mouse responsds before the conditional water is delivered at 1.5
        % then the response is considered a correct hit. The typical 2
        % seconds of water reward is delivered for a correct hit and the
        % conditioning water is not deliviered
        if randomNumber > percent && toc(A) >= 1 && toc(A) <=3 && lickPin == 1 && early == 0 && length(lickTrial) == 1
            hit = 1;
            B = tic;
            while toc(B) <= 2

                try
                    writeDigitalPin(rpi, 13, 1)
                    disp('solenoid on');
                catch
                    disp('connection error 7')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
               
                try
                    lickPin = readDigitalPin(rpi, 5);
                catch
                    disp('connection error 8')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
                
                if lickPin == 1
                    lickTrial = [lickTrial; toc(A)];
                end
            end

            try
                writeDigitalPin(rpi,13,0)
            catch
                disp('connection error 9')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
                writeDigitalPin(rpi,13,0)
            end
        end
        
        %if the trial is selected to be a conditional water trial and no
        %hit is recorded, then water will be delivered for 0.5 seconds at
        %1.5 seconds into the trial
        if toc(A) > 1.5 && randomNumber < percent && hit == 0 && early == 0 && cond == 0
            
            % the reward is 0.5 seconds of water so this timer keeps
            % track to turn the solenoid on for 0.5 seconds
            C = tic;
            while toc(C) <= .5
                
                try
                    writeDigitalPin(rpi, 13, 1)
                catch
                    disp('connection error 10')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
                
                try
                    lickPin = readDigitalPin(rpi, 5);
                catch
                    disp('connection error 11')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
                
                if lickPin == 1
                    lickTrial = [lickTrial; toc(A)];
                end
            end
            
            % the solenoid is turned off after 0.5 seconds
            try
                writeDigitalPin(rpi,13,0)
            catch
                disp('connection error 12')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
                writeDigitalPin(rpi,13,0)
            end
            
            % cond variable is increased so the if-statement isn't
            % true anymore and the solenoid only gets triggered once
            cond = 1;
        end
            
        % if a lick is detected before the response window (<1s) then the
        % response is considered "early"
        if toc(A) < 1 && lickPin == 1
            early = 1;
        end

    end
    
    if error == 0
        % these count variables are used for a histogram to show
        % quantitatively how the mouse responded. the responseVec vector
        % also saves the type of response with a corresponding letter
        if hit == 0 && early == 0 && condHit == 0
            disp('miss')
            missCount = missCount + 1;
            responseVec = [responseVec,'M'];
        end
        if hit == 1
            disp('hit')
            hitCount = hitCount + 1;
            responseVec = [responseVec,'H'];
        end
        if condHit == 1
            disp('conditional hit')
            condHitCount = condHitCount + 1;
            responseVec = [responseVec,'C'];
        end
        if early == 1
            disp('early')
            earlyCount = earlyCount + 1;
            responseVec = [responseVec,'E'];
        end
        
        % delay between each trial 5 to 9 seconds
        delay = randi([5,9]);
        pause(delay)
        
        % Compiles the licks from each trial into a matrix, each row is 
        % another trial of recorded licks
        lickTotal = [lickTotal; {lickTrial}];
        
        % The next three lines find where the first lick occurred in the 
        % most recent trial
        lickData = cell2mat(lickTotal(totalTrials));
        % This line specifically separates the recorded licks into a histogram
        [lickHistogram,edges] = histcounts(lickData,nbins,'BinLimit',[0 4]);
        firstLick = find(lickHistogram>0,1);
        
        % This logs the first lick into a histogram of all the first licks for
        % all trials
        lickResponse(1,firstLick) = lickResponse(1,firstLick) + 1;
        
        % Compiles all the separate lick histograms into one big data set
        totalData = [totalData; lickHistogram];
        
        save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount','condHitCount',...
            'xaxis','totalTrials','lickResponse','totalData','target','phaseChoice','cageID','timeStamp','blockInterval','toneVec','responseVec')
     
    end
    
    %voids data if an error occurred during the trial
    if error == 1
        if length(responseVec) == totalTrials
            responseVec(length(responseVec)) = [];
        end
        totalTrials = totalTrials - 1;
        toneVec(length(toneVec)) = [];
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
save([devicesFolder, cageID '/performance' datestr(now,'dd-mm-yyyy_HH.MM') '.mat'],'phaseName','hitCount','missCount','earlyCount','condHitCount',...
    'xaxis','totalTrials','lickResponse','totalData','target','phaseChoice','cageID','timeStamp','blockInterval','toneVec','responseVec')


% deletes the generic performance file
delete([devicesFolder, cageID '/performance.mat'])