function a = discrimination(devicesFolder)

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
checkFile = exist([devicesFolder, cageID '/performance.mat'])
if checkFile == 2;
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
phaseChoice = 4;
phaseName = 'discrimination';

% saves target and nontarget tone selections from ToneBoxGui,
% then concatenates those choices into one vector to be used for randomly
% selecting a sound to play each trial
target = targetChoice;
nontarget = nontargetChoice;
soundOption = [target; nontarget];

% saves tone level selections from ToneBoxGui
toneLevel = toneLevelChoice;

%records of the number of each responses, respectively hit, early, miss,
%correct rejection, and false alarm
hitCount = 0;
earlyCount = 0;
missCount = 0;
correctRejectionCount = 0;
falseAlarmCount = 0;

%records of the number of trials
totalTrials = 0;

%records of the time each trial starts
timeStamp = {};

%records of the number of trials that play target/nontarget tones 
%respsecitvely
totalTrialsTarget = 0;
totalTrialsNonTarget = 0;

%Compiles the licks from each target/nontarget tone trial into a matrix, 
%each row is another trial of recorded licks
lickTotalTarget = {};
lickTotalNonTarget = {};

%variable used to find when the first lick occurred for target/nontarget
%trials respectively
lickDataTarget = [];
lickDataNonTarget = [];

% nbins can be adjusted based depending on if the sampling rate of
% the sensor is too fast or too slow, this value was picked based on
% observing how fast a mouse can lick and react to the stimulus, the bins
% are used to break up the lick response data
nbins = 75;

% Compiles all the separate target/nontarget lick histograms into one
% matrix respectively
totalData = [];


%sets the x axis based on the nbins variable for plotting histograms later
%in data analysis
xaxis = linspace(0,4,nbins);

% records the first lick for all target/nontarget trials
lickResponseTarget = zeros(1,nbins);
lickResponseNonTarget = zeros(1,nbins);

%records which tone played during that trial
toneVec = [];

%records whether the response was a hit 'H', early 'E', a miss 'M', a false
%alarm 'F', or a correct rejection 'R'
responseVec = [];

%records which level the tone was played at
levelVec = [];

% saves all these variables to a performance file to be saved at the end of
% each loop. this file gets loaded in the gui when it graphs the data
save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount',...
    'correctRejectionCount','falseAlarmCount','xaxis','totalTrials','totalTrialsTarget','totalTrialsNonTarget',...
    'lickResponseTarget','lickResponseNonTarget','totalData','target','nontarget','phaseChoice','cageID','timeStamp','blockInterval','toneVec','levelVec','responseVec')

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
    
    % this records the time of each trial
    timeStamp = [timeStamp; {totalTrials datestr(now,'mm/dd/yyyy HH:MM:SS')}];
    
    save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount',...
    'correctRejectionCount','falseAlarmCount','xaxis','totalTrials','totalTrialsTarget','totalTrialsNonTarget',...
    'lickResponseTarget','lickResponseNonTarget','totalData','target','nontarget','phaseChoice','cageID','timeStamp','blockInterval','toneVec','levelVec','responseVec')

    %resets delay value
    delay = 0;

    %if the trial results in the corresponding response, the variable will
    %equal 1
    hit = 0;
    early = 0;
    falseAlarm = 0;
    
    %records the licks of the current target/nontarget trial, then resets 
    %each loop
    lickTrialTarget = [];
    lickTrialNonTarget = [];
    
    %if the silent trials option is selected in the ToneBoxGui, then sielnt
    %trials will occur in 30 percent of the trials
    percent = 30;
    if silentTrials == 1
        randomNumber = randi(100);
    else
        randomNumber = 100;
    end
    
    
    % this tests to make sure the raspberry pi is connected
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
    % animal hasn't licked for 2 consecutive seconds
    C = tic;
    lickPin = 0;
    noresp = randsample(5:5:25,1);
    while toc(C) < noresp && intervalStop == 0
        try
            lickPin = readDigitalPin(rpi, 5);
        catch
            disp('connection error 6')
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
    
    V = tic;
    
    %30 percent of trials randomNumber will be smaller than percent so if
    %silent trials were selected then on 30 percent of trials there will be
    %no sound
    if randomNumber > percent
        % sound files are stored as Tone_XkHz_YdB.wav, and the different values
        % of X are the different tone frequencies. The sound variable selects a
        % random value from the specific tones that were selected in the
        % ToneBoxGui. The different values of Y are different tone levels and
        % the randLevel variable selects a random value from the specific tone
        % levels what were selected in the ToneBoxGui
        sound = num2str(soundOption(randi(length(soundOption))))
        randLevel = num2str(toneLevel(randi(length(toneLevel))));
        
        
        % determines if the sound selected was a target or a nontarget, if a 1
        % is returned, the sound is a target, if a 0 is returned then the sound
        % is a nontarget
        checkTarget = ismember(str2num(sound),target);
        
        % command to raspberry pi to play random sound selection
        system(rpi,['sudo mplayer /home/tonebox/Tone_' sound 'kHz_' randLevel 'dB.wav </dev/null >/dev/null 2>&1 &']);
    else
        %this trial will be silent
        disp('silent trial')
        sound = '0';
        randLevel = 'X';
        checkTarget = 0;
    end
    
    %records which sound and which tone level were played, sound = 0 and
    %randLevel = X for silent trials
    toneVec = [toneVec,{num2str(sound)}];
    levelVec = [levelVec,{num2str(randLevel)}];
    
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
            disp('connection error 2')
            datestr(now,'mm/dd/yyyy HH:MM:SS')
            clear rpi
            load([devicesFolder, cageID '/PiParams.mat'],'rpi')
            pause(5)
            error = 1;
        end
        
        % lickTrialTarget will be timestamped every time the capacitive touch
        % sensor is triggered, this is how licks are recorded each trial
        if checkTarget == 1 && lickPin == 1
            lickTrialTarget = [lickTrialTarget; toc(A)];
        end
        
        % lickTrialNontarget will be timestamped every time the capacitive touch
        % sensor is triggered, this is how licks are recorded each trial
        if checkTarget == 0 && lickPin == 1
            lickTrialNonTarget = [lickTrialNonTarget; toc(A)];
            
        end
        
        % these conditions indicate a "hit" and the last condition
        % stipulates that after the first lick, the solenoid will get
        % triggered
        if toc(A) >= 1 && toc(A) <=3 && lickPin == 1 && early == 0 && checkTarget == 1 && length(lickTrialTarget) == 1
            hit = 1;
            
            % the reward is 2 seconds of water so the second timer keeps
            % track to turn the solenoid on for 2 seconds
            B = tic;
            while toc(B) <= 2
                
                % tells the raspberry pi to turn on the solenoid to 
                % deliver water
                try
                    writeDigitalPin(rpi, 13, 1)
                    disp('solenoid on')
                catch
                    disp('connection error 3')
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
                    disp('connection error 4')
                    datestr(now,'mm/dd/yyyy HH:MM:SS')
                    clear rpi
                    load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                    pause(5)
                    error = 1;
                end
                if lickPin == 1
                    lickTrialTarget = [lickTrialTarget; toc(A)];
                end
            end
            
            %tells the raspberry pi to turn off the solenoid after 2 sec
            try
                writeDigitalPin(rpi,13,0)
            catch
                disp('connection error 5')
                datestr(now,'mm/dd/yyyy HH:MM:SS')
                clear rpi
                load([devicesFolder, cageID '/PiParams.mat'],'rpi')
                pause(5)
                error = 1;
                writeDigitalPin(rpi,13,0)
            end
        end
        
        % if a lick is detected during the response window (1-3s) on a 
        % nontarget trial then the response is considered a "false "alarm",
        % punishment for this response is a longer delay time in between 
        % trials, delay isset to 20 seconds
        if toc(A) >= 1 && toc(A) <=3 && lickPin == 1 && early == 0 && checkTarget == 0
            falseAlarm = 1;
        end
        
        % if a lick is detected before the response window (<1s) then the
        % response is considered "early", punishment for this response is 
        % a longer delay time in between trials, delay is set to 20 seconds
        if toc(A) < 1 && lickPin == 1
            early = 1;
        end
    end
    
    if error == 0
        % these count variables are used for a histogram to show
        % quantitatively how the mouse responded. the responseVec vector
        % also saves the type of response with a corresponding letter
        % delays in between trials after hit and miss responses are between
        % 5 and 9 seconds, early  and false alarm trials result in 20 
        % second delays.
        if hit == 0 && early == 0 && checkTarget == 1
            disp('miss')
            delay = randi([5,9])
            pause(delay)
            missCount = missCount + 1;
            responseVec = [responseVec,'M'];
            
            % this adds a row of zeros to lickTrialNonTarget so that the number
            % of rows corresponds to the total number of trials since total
            % lick responses are averaged over total trials
            lickTrialNonTarget = [lickTrialNonTarget; zeros(1,nbins)];
        end
        
        if hit == 0 && early == 0 && falseAlarm == 0 && checkTarget == 0
            disp('correct rejection')
            delay = randi([5,9])
            pause(delay)
            correctRejectionCount = correctRejectionCount + 1;
            responseVec = [responseVec,'R'];
            
            % this adds a row of zeros to lickTrialTarget so that the number
            % of rows corresponds to the total number of trials since total
            % lick responses are averaged over total trials
            lickTrialTarget = [lickTrialTarget; zeros(1,nbins)];
            
        end
        if hit == 1
            disp('hit')
            delay = randi([5,9])
            pause(delay)
            hitCount = hitCount + 1;
            responseVec = [responseVec,'H'];
            
            lickTrialNonTarget = [lickTrialNonTarget; zeros(1,nbins)];
        end
        if falseAlarm == 1
            disp('false alarm')
            delay = 20 + randi([5,9])
            pause(delay)
            falseAlarmCount = falseAlarmCount + 1;
            responseVec = [responseVec,'F'];
            
            lickTrialTarget = [lickTrialTarget; zeros(1,nbins)];
        end
        if early == 1
            if checkTarget == 1
                
                lickTrialNonTarget = [lickTrialNonTarget; zeros(1,nbins)];
            end
            if checkTarget == 0
                
                lickTrialTarget = [lickTrialTarget; zeros(1,nbins)];
            end
            disp('early')
            delay = 20 + randi([5,9])
            pause(delay)
            earlyCount = earlyCount + 1;
            responseVec = [responseVec,'E'];
        end
        
        % for target trials
        if checkTarget == 1
            
            %records of the number of trials that play target tones
            totalTrialsTarget = totalTrialsTarget + 1;
            
            % Compiles the licks from each target tone trial into a matrix, 
            % each row is another trial of recorded licks
            lickTotalTarget = [lickTotalTarget; {lickTrialTarget}];
            
            % The next three lines find where the first lick occurred in the 
            % most recent target trial
            lickDataTarget = cell2mat(lickTotalTarget(totalTrialsTarget));
            % This line specifically separates the recorded licks into a histogram
            [lickHistogramTarget,edges] = histcounts(lickDataTarget,nbins,'BinLimit',[0 3]);
            firstLickTarget = find(lickHistogramTarget>0,1);
            
            % This logs the first lick into a histogram of all the first 
            % licks for all target trials
            lickResponseTarget(1,firstLickTarget) = lickResponseTarget(1,firstLickTarget) + 1;
            
            % Compiles all the separate target target tone lick histograms 
            % into one big data set
            totalData = [totalData; lickHistogramTarget];
        end
        
        % for nontarget trials
        if checkTarget == 0
            
            %records of the number of trials that play target tones
            totalTrialsNonTarget = totalTrialsNonTarget + 1;
            
            % Compiles the licks from each nontarget tone trial into a matrix, 
            % each row is another trial of recorded licks
            lickTotalNonTarget = [lickTotalNonTarget; {lickTrialNonTarget}];
            
            % The next three lines find where the first lick occurred in the 
            % most recent nontarget trial
            lickDataNonTarget = cell2mat(lickTotalNonTarget(totalTrialsNonTarget));
            % This line specifically separates the recorded licks into a histogram
            [lickHistogramNonTarget,edges] = histcounts(lickDataNonTarget,nbins,'BinLimit',[0 4]);
            firstLickNonTarget = find(lickHistogramNonTarget>0,1);
            
            % This logs the first lick into a histogram of all the first 
            % licks for all nontarget trials
            lickResponseNonTarget(1,firstLickNonTarget) = lickResponseNonTarget(1,firstLickNonTarget) + 1;
            
            % Compiles all the separate nontarget target tone lick 
            % histograms into one big data set
            totalData = [totalData; lickHistogramNonTarget];
        end
        
        save([devicesFolder, cageID '/performance.mat'],'phaseName','hitCount','missCount','earlyCount',...
            'correctRejectionCount','falseAlarmCount','xaxis','totalTrials','totalTrialsTarget','totalTrialsNonTarget',...
            'lickResponseTarget','lickResponseNonTarget','totalData','target','nontarget','phaseChoice','cageID','timeStamp','blockInterval','toneVec','levelVec','responseVec')
        
    end
    
    %voids data if an error occurred during the trial
    if error == 1
        if length(responseVec) == totalTrials
            responseVec(length(responseVec)) = [];
        end
        totalTrials = totalTrials - 1;
        toneVec(length(toneVec)) = [];
        levelVec(length(levelVec)) = [];
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
save([devicesFolder, cageID '/performance' datestr(now,'dd-mm-yyyy_HH.MM') '.mat'],'phaseName','hitCount','missCount','earlyCount',...
    'correctRejectionCount','falseAlarmCount','xaxis','totalTrials','totalTrialsTarget','totalTrialsNonTarget',...
    'lickResponseTarget','lickResponseNonTarget','totalData','target','nontarget','phaseChoice','cageID','timeStamp','blockInterval','toneVec','levelVec','responseVec');

% deletes the generic performance file
delete([devicesFolder, cageID '/performance.mat'])
