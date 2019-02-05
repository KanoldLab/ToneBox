function varargout = dataGraph(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @dataGraph_OpeningFcn, ...
    'gui_OutputFcn',  @dataGraph_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before dataGraph is made visible.
function dataGraph_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

%sets file path to the current file that Matlab has open
fileLocation = pwd;
set(handles.fileLocation,'String',fileLocation);

%sets the defaults for all the buttons and text boxes
set(handles.checkDevices,'Enable','off')
set(handles.graphButton,'Enable','off')
set(handles.deviceChoice,'String','Device name','Enable','off')
set(handles.fileSelection,'Enable','off','String','Select File')
set(handles.waitStatus,'visible','off')
set(handles.runStatus,'visible','off')
set(handles.blockStatus,'visible','off')
set(handles.failStatus,'visible','off')

%creates large vector of all the buttons that correspond to the different
%devices
handles.checkPiButtons = [handles.check1;handles.check2;handles.check3;...
    handles.check4;handles.check5;handles.check6;handles.check7;...
    handles.check8;handles.check9;handles.check10;handles.check11;...
    handles.check12;handles.check13;handles.check14;handles.check15;...
    handles.check16];

%setting variable to be used in the email notification function
handles.statusLoop = 0;
guidata(hObject, handles);

function varargout = dataGraph_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function deviceChoice_Callback(hObject, eventdata, handles)
handles.fileChoice = [];

% data location is given a variable
handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];

% checks to see if the entered string is a valid device name by searching
% for the device folder
checkLocation = exist(handles.dataLocation);
if checkLocation == 0
    % pop up message box if the device name is invalid
    popup = msgbox('Invalid device name');
    
else
    %lists all the performance files in chronological order
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    
    %enables file selection and graph button
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    
end
guidata(hObject, handles);

function deviceChoice_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function graphButton_Callback(hObject, eventdata, handles)
%if no file is selected, the most recent file is selected for graphing
if isempty(handles.fileChoice)
    
    handles.fileChoice = 1;
end

% loads the file, catch loop is in case the selected file is being saved
% simultaneously, the loop catch will pause and try to load again
try
    load([handles.dataLocation,handles.fileSelection.String{handles.fileChoice}])
catch
    pause(1)
    load([handles.dataLocation,handles.fileSelection.String{handles.fileChoice}])
    
end

set(handles.fileSelection,'Value',handles.fileChoice)

% displays the trial that just finished for the associated
% device in the correct tab
set(handles.trialDisplay,'String',['Total Trials = ', num2str(totalTrials)]);

%displays the time at which the last trial was recorded
try
    set(handles.trialRecordText,'String',['Last Trial Recorded: ',timeStamp{length(timeStamp),2}])
catch
    set(handles.trialRecordText,'String','Last Trial Recorded: waiting for more data')
    
end

% if the phase selected was discrimination, targets vs
% nontargets are graphed
if phaseChoice == 4
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay,'String',['Target Tones:',{target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.nontargetDisplay,'String',['Nontarget Tones:', {nontarget}]);
    
    % displays the phase selected
    set(handles.phaseDisplay,'String',['Phase:',{'Discrimination'}]);
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,1,'Parent',handles.graphPanel);
    
    % plots response latency, aka first lick, blue line is for
    % licks on target trials, red line is for licks on
    % nontarget trials, axes are set for x axis to be from 0 to
    % 4 seconds, and y axis set from 0 to 1 for relative
    % response over total trials
    plot(xaxis,(lickResponseTarget/totalTrials),'b',xaxis,...
        (lickResponseNonTarget/totalTrials),'r')
    xlabel('Time(s)')
    ylabel('Percentage')
    xlim([0 4])
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,2,'Parent',handles.graphPanel);
    
    % histogram of response types
    histogram('Categories',{'hit','false alarm','early'},'BinCounts',...
        [(hitCount/totalTrials); (falseAlarmCount/totalTrials); (earlyCount/totalTrials)])
    ylim([0 1])
    ylabel('Response Rate')
    xlabel('Response')
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,[3,4],'Parent',handles.graphPanel);
    
    % plots average lick response, blue line is
    % for target trials, red line is for nontarget trials
    plot(xaxis,mean(totalDataTarget),'b',xaxis,mean(totalDataNonTarget),'r')
    xlabel('Time(s)')
    ylabel('Lick Rate')
    xlim([0 4])
    
    % red box around target response zone
    aa=axis;
    x1 = [1 1];
    y1 = [0 aa(4)]*.5;
    x2 = [1 3];
    y2 = [aa(4) aa(4)]*.5;
    x3 = [3 3];
    line(x1,y1,'Color','r','LineStyle','--')
    line(x2,y2,'Color','r','LineStyle','--')
    line(x3,y1,'Color','r','LineStyle','--')
    
end

% if habituation is selected
if phaseChoice == 1
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay,'String',['Target Tones:',{'none'}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.nontargetDisplay,'String',['Nontarget Tones:',{'none'}]);
    
    % displays the phase selected
    set(handles.phaseDisplay,'String',['Phase:',{'Habituation'}]);
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,1,'Parent',handles.graphPanel);
    
    % plots response latency, aka first lick, axes are set
    % for x axis to be from 0 to 10 seconds, and y axis set
    % from 0 to 1 for relative response over total trials
    plot(xaxis,(lickResponse/totalTrials));
    xlabel('Time(s)')
    ylabel('Percentage')
    xlim([0 10]);
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,2,'Parent',handles.graphPanel);
    
    % percentage of hits
    plot((hitCount/totalTrials),'bs')
    xlim([0 2])
    ylim([0 1])
    set(gca,'XTick',[])
    ylabel('Response Rate')
    xlabel('Hit Response')
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,2,[3,4],'Parent',handles.graphPanel);
    
    % plots average lick response
    plot(xaxis,mean(totalData));
    xlabel('Time(s)')
    ylabel('Lick Rate')
    xlim([0 10])
    
end

% if shaping is selected
if phaseChoice == 2
    set(handles.phaseDisplay,'String',['Phase',{'Shaping'}]);
    
    %clear plots
    delete(handles.graphPanel.Children(2:end))
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay,'String',['Target Tones:', {target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.nontargetDisplay,'String',['Nontarget Tones:',{'none'}]);
    
    %%%%%  Trialwise Data  %%%%%
    subplot(2,3,1:2,'Parent',handles.graphPanel);
    cla
    %Hits
    H=zeros(length(responseVec),1);
    %Conditioned Hits
    C=zeros(length(responseVec),1);
    %Early
    E=zeros(length(responseVec),1);
    for i = 1:length(responseVec)
        if strcmpi(responseVec(i),'H')
            H(i)=1;
        elseif strcmpi(responseVec(i),'C')
            C(i)=1;
        elseif strcmpi(responseVec(i),'E')
            E(i)=1;
        end
    end
    plot(100*movmean(cumsum(H)./[1:length(H)]',100),'b','linewidth',2);
    hold on
    plot(100*movmean(cumsum(C)./[1:length(C)]',100),'color',[0 .5 .5],'linewidth',2);
    plot(100*movmean(cumsum(E)./[1:length(E)]',100),'k','linewidth',2);
    xlim([1 length(responseVec)])
    aa=axis;
    ylim([aa(3) aa(4)+5])
    h=legend('H_R','H_C','E','autoupdate','off');
    legend boxoff
    xlabel('Trials')
    ylabel('Response Rate (%)')
    set(gca,'fontsize',8)
    title('Trialwise Responses')
    
    %Select trials
    if ~isempty(handles.AnalysisTrials.String)
        T = str2num(handles.AnalysisTrials.String);
        if length(T) == 1
            T = [1 T];
        end
        T=sort(T);
        if max(T) > length(H)
            T(end) = length(H);
        end
        if T(1) < 1
            T(1) = 1;
        end
        handles.AnalysisTrials.String = num2str(T);
        aa=axis;
        area(T,repmat(aa(4)*.5,[1 length(T)]),'edgecolor','none','facecolor','k','facealpha',.2)
        text(mean(T),(aa(4)*.5)+.75,'Analysis trials','fontsize',7,'HorizontalAlignment','center')
        toneVec = toneVec(T(1):T(2));
        responseVec = responseVec(T(1):T(2));
        
        %Recalculate lickResponse, H, C, and E for selected trials
        nbins = size(totalData,2);
        lickResponse = zeros(1,nbins);
        firstLick=[];
        for i = T(1):T(2)
            firstLick=find(totalData(i,:)>0,1);
            lickResponse(1,firstLick) = lickResponse(1,firstLick) + 1;
            firstLick=[];
        end
        
        %Hits
        hitCount=zeros(length(responseVec),1);
        %Conditioned Hits
        condHitCount=zeros(length(responseVec),1);
        %Early
        earlyCount=zeros(length(responseVec),1);
        for i = 1:length(responseVec)
            if strcmpi(responseVec(i),'H')
                hitCount(i)=1;
            elseif strcmpi(responseVec(i),'C')
                condHitCount(i)=1;
            elseif strcmpi(responseVec(i),'E')
                earlyCount(i)=1;
            end
        end
        hitCount=sum(hitCount);
        condHitCount=sum(condHitCount);
        earlyCount=sum(earlyCount);
        totalTrials = length(responseVec);
        
    end
    
    %Spectrum
    try
        subplot(2,3,3,'Parent',handles.graphPanel);
        cla
        F = unique(toneVec)';
        Hf=[];
        for i = 1:length(F)
            f = find(toneVec==F(i));
            Hf(i)=sum(responseVec(f)=='H')./length(f);
            
        end
        plot(1:length(F),100*Hf,'k');
        hold on
        plot(1:length(F),100*Hf,'ks','markerface','k')
        set(gca,'xtick',1:length(F),'xticklabel',F)
        xlabel('Frequency (kHz)')
        set(gca,'fontsize',8)
        title([{'Tone Responses'}])
        aa=axis;
        ylim([0 aa(4)])
        
    end
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,4,'Parent',handles.graphPanel);
    cla
    
    % plots response latency, aka first lick, axes are set
    % for x axis to be from 0 to 4 seconds, and y axis set
    % from 0 to 1 for relative response over total trials
    L = lickResponse/sum(lickResponse);
    LL = smooth(L,10);
    area(xaxis,100*LL,'facecolor','b','facealpha',.5,'edgecolor','none');
    aa=axis;
    ylim([aa(3) aa(4)+5])
    h=legend('T','AutoUpdate','off');
    legend boxoff
    xlabel('Time(s)')
    ylabel('Likelihood (%)')
    xlim([0 4]);
    hold on
    title('Response Latency')
    set(gca,'fontsize',8)
    % box around target
    aa=axis;
    x1 = [1 1];
    y1 = [0 aa(4)]*.5;
    x2 = [1 2];
    y2 = [aa(4) aa(4)]*.5;
    x3 = [2 2];
    line(x1,y1,'Color','k','LineStyle','-','linewidth',2)
    line(x2,y2,'Color','k','LineStyle','-','linewidth',2)
    line(x3,y1,'Color','k','LineStyle','-','linewidth',2)
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,6,'Parent',handles.graphPanel);
    cla
    
    % histogram of response types from animal
    bar(1,100*hitCount/totalTrials,'facecolor','b','edgecolor','none');
    hold on
    bar(2,100*condHitCount/totalTrials,'facecolor',[0 .5 .5],'edgecolor','none');
    bar(3,100*earlyCount/totalTrials,'facecolor','none','edgecolor','k');
    set(gca,'xtick',1:3,'xticklabel',{'H_R','H_C','E'})
    title('Response Rates')
    set(gca,'fontsize',8)
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,5,'Parent',handles.graphPanel);
    cla
    
    % plots average lick response
    L = mean(totalData);
    LL = smooth(L,10);
    area(xaxis,100*LL,'facecolor','b','facealpha',.5,'edgecolor','none');
    xlabel('Time(s)')
    xlim([0 4]);
    hold on
    title('Lick-o-gram')
    set(gca,'fontsize',8)
    aa=axis;
    ylim([aa(3) aa(4)])
    
    
    % box around target
    aa=axis;
    x1 = [1 1];
    y1 = [0 aa(4)]*.5;
    x2 = [1 2];
    y2 = [aa(4) aa(4)]*.5;
    x3 = [2 2];
    line(x1,y1,'Color','k','LineStyle','-','linewidth',2)
    line(x2,y2,'Color','k','LineStyle','-','linewidth',2)
    line(x3,y1,'Color','k','LineStyle','-','linewidth',2)
    
end

if phaseChoice == 3
    
    set(handles.phaseDisplay,'String',['Phase:',{'Detection'}]);
    
    %clear plots
    delete(handles.graphPanel.Children(2:end))
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay,'String',['Target Tones:', {target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.nontargetDisplay,'String',['Nontarget Tones:',{'none'}]);
    
    %%%%%  Trialwise Data  %%%%%
    subplot(2,3,1:2,'Parent',handles.graphPanel);
    cla
    %Hits
    H=zeros(length(responseVec),1);
    %Early
    E=zeros(length(responseVec),1);
    for i = 1:length(responseVec)
        if strcmpi(responseVec(i),'H')
            H(i)=1;
        elseif strcmpi(responseVec(i),'E')
            E(i)=1;
        end
    end
    plot(100*movmean(H,100),'b','linewidth',2);
    hold on
    plot(100*movmean(E,100),'k','linewidth',2);
    xlim([1 length(responseVec)])
    aa=axis;
    ylim([aa(3) aa(4)+5])
    h=legend('H_R','E','autoupdate','off');
    legend boxoff
    xlabel('Trials')
    ylabel('Response Rate (%)')
    set(gca,'fontsize',8)
    title('Trialwise Responses')
    
    %Select trials
    if ~isempty(handles.AnalysisTrials.String)
        T = str2num(handles.AnalysisTrials.String);
        if length(T) == 1
            T = [1 T];
        end
        T=sort(T);
        if max(T) > length(H)
            T(end) = length(H);
        end
        if T(1) < 1
            T(1) = 1;
        end
        handles.AnalysisTrials.String = num2str(T);
        aa=axis;
        area(T,repmat(aa(4)*.5,[1 length(T)]),'edgecolor','none','facecolor','k','facealpha',.2)
        text(mean(T),(aa(4)*.5)+.75,'Analysis trials','fontsize',7,'HorizontalAlignment','center')
        toneVec = toneVec(T(1):T(2));
        responseVec = responseVec(T(1):T(2));
        totalData = totalData(T(1):T(2),:);
        
        %Recalculate lickResponse, H, and E for selected trials
        nbins = size(totalData,2);
        lickResponse = zeros(1,nbins);
        firstLick=[];
        for i = 1:size(totalData,1);
            firstLick=find(totalData(i,:)>0,1);
            lickResponse(1,firstLick) = lickResponse(1,firstLick) + 1;
            firstLick=[];
        end
        
        %Hits
        hitCount=zeros(length(responseVec),1);
        %Eary=ly
        earlyCount=zeros(length(responseVec),1);
        for i = 1:length(responseVec)
            if strcmpi(responseVec(i),'H')
                hitCount(i)=1;
            elseif strcmpi(responseVec(i),'E')
                earlyCount(i)=1;
            end
        end
        hitCount=sum(hitCount);
        earlyCount=sum(earlyCount);
        totalTrials = length(responseVec);
        
    end
    
    %Spectrum
    try
        subplot(2,3,3,'Parent',handles.graphPanel);
        cla
        F = unique(toneVec)';
        Hf=[];
        for i = 1:length(F)
            f = find(toneVec==F(i));
            Hf(i)=sum(responseVec(f)=='H')./length(f);
            
        end
        plot(1:length(F),100*Hf,'k');
        hold on
        plot(1:length(F),100*Hf,'ks','markerface','k')
        set(gca,'xtick',1:length(F),'xticklabel',F)
        xlabel('Frequency (kHz)')
        set(gca,'fontsize',8)
        title([{'Tone Responses'}])
        aa=axis;
        ylim([0 aa(4)])
        
    end
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,4,'Parent',handles.graphPanel);
    cla
    
    % plots response latency, aka first lick, axes are set
    % for x axis to be from 0 to 4 seconds, and y axis set
    % from 0 to 1 for relative response over total trials
    L = lickResponse/sum(lickResponse);
    LL = smooth(L,10);
    area(xaxis,100*LL,'facecolor','b','facealpha',.5,'edgecolor','none');
    aa=axis;
    ylim([aa(3) aa(4)+5])
    h=legend('T','AutoUpdate','off');
    legend boxoff
    xlabel('Time(s)')
    ylabel('Likelihood (%)')
    xlim([0 4]);
    hold on
    title('Response Latency')
    set(gca,'fontsize',8)
    
    % box around target
    aa=axis;
    x1 = [1 1];
    y1 = [0 aa(4)]*.5;
    x2 = [1 2];
    y2 = [aa(4) aa(4)]*.5;
    x3 = [2 2];
    line(x1,y1,'Color','k','LineStyle','-','linewidth',2)
    line(x2,y2,'Color','k','LineStyle','-','linewidth',2)
    line(x3,y1,'Color','k','LineStyle','-','linewidth',2)
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,6,'Parent',handles.graphPanel);
    cla
    
    % histogram of response types from animal
    bar(1,100*hitCount/totalTrials,'facecolor','b','edgecolor','none');
    hold on
    bar(2,100*earlyCount/totalTrials,'facecolor','none','edgecolor','k');
    set(gca,'xtick',1:3,'xticklabel',{'H_R','E'})
    title('Response Rates')
    set(gca,'fontsize',8)
    
    % sets the graph's parent to be in the correct panel/tab
    subplot(2,3,5,'Parent',handles.graphPanel);
    cla
    
    % plots average lick response
    L = mean(totalData);
    LL = smooth(L,10);
    area(xaxis,100*LL,'facecolor','b','facealpha',.5,'edgecolor','none');
    xlabel('Time(s)')
    xlim([0 4]);
    hold on
    title('Lick-o-gram')
    set(gca,'fontsize',8)
    aa=axis;
    ylim([aa(3) aa(4)])
    
    
    % box around target
    aa=axis;
    x1 = [1 1];
    y1 = [0 aa(4)]*.5;
    x2 = [1 2];
    y2 = [aa(4) aa(4)]*.5;
    x3 = [2 2];
    line(x1,y1,'Color','k','LineStyle','-','linewidth',2)
    line(x2,y2,'Color','k','LineStyle','-','linewidth',2)
    line(x3,y1,'Color','k','LineStyle','-','linewidth',2)
    
end

% immediately plots data
drawnow;

guidata(hObject, handles);

function fileSelection_Callback(hObject, eventdata, handles)
handles.fileChoice = get(hObject,'Value');
guidata(hObject, handles);

function fileSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%checks status of the devices that are currently running on button press
function checkDevices_Callback(hObject, eventdata, handles)

handles.failCheck = 0;
%loads file that has a list of all the running devices
load([handles.devicesFolder 'currentDevices.mat'])

if numel(onDevices) > 0
    set(handles.emailNotif,'Enable','on')
end
%for each device it first checks that the parameters have been moved into
%the associated folder and then looks at when the most recent trial was
%saved and then color codes the device based on the status
for z = 1:numel(onDevices)
    set(handles.checkPiButtons(z),'Enable','on')
    loaded = 0;
    while ~loaded
        try
            load([handles.devicesFolder onDevices{z} '/performance.mat'])
            load([handles.devicesFolder onDevices{z} '/stopButton.mat'])
            loaded = 1;
        end
    end
    set(handles.checkPiButtons(z),'String',onDevices{z})
    try
        t1 = clock;
        t2 = datevec(timeStamp{length(timeStamp),2});
        timeCheck = (etime(t1,t2))/60;
        
        %if the device is not on an inter block interval and has recorded a
        %trial within the last 10 minutes then the status is green
        if timeCheck < 10 && blockInterval == 0 && pauseProgram == 0
            set(handles.checkPiButtons(z),'BackgroundColor','g','ForegroundColor','k')
        
        %if the device is not on an inter block interval and hasn't recorded a
        %trial within the last 10 minutes then the status is red
        elseif timeCheck > 2 && blockInterval == 0 && pauseProgram == 0
            set(handles.checkPiButtons(z),'BackgroundColor','r','ForegroundColor','k')
        
        %if the device is on an inter block interval and has recorded a
        %trial within the last 70 minutes then the status is yellow
        elseif timeCheck < 70 && blockInterval == 1 && pauseProgram == 0
            set(handles.checkPiButtons(z),'BackgroundColor','y','ForegroundColor','k')
        
        %if the device is on an inter block interval and hasn't recorded a
        %trial within the last 70 minutes then the status is red
        elseif timeCheck > 70 && blockInterval == 1 && pauseProgram == 0
            set(handles.checkPiButtons(z),'BackgroundColor','r','ForegroundColor','k')
        
        %if the device has been paused then the status is magenta
        elseif pauseProgram == 1
            set(handles.checkPiButtons(z),'BackgroundColor','m','ForegroundColor','w')
        end
        
    catch
        
        %if the parameters file has not been moved to the associated
        %device folder then the status is blue
        set(handles.checkPiButtons(z),'BackgroundColor','b','ForegroundColor','w')
    end

end

%names the buttons to the corresponding device name
for z = numel(onDevices) + 1:16
    set(handles.checkPiButtons(z),'BackgroundColor','default','ForegroundColor','k')
    set(handles.checkPiButtons(z),'String',['Pi',num2str(z)])
end

%legend
set(handles.waitStatus,'visible','on')
set(handles.runStatus,'visible','on')
set(handles.blockStatus,'visible','on')
set(handles.failStatus,'visible','on')
set(handles.pauseStatus,'visible','on')
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check1_Callback(hObject, eventdata, handles)
if length(handles.check1.String) > 4
    delete(handles.graphPanel.Children(2:end))
    set(handles.deviceChoice,'String',handles.check1.String)
    handles.fileChoice = [];
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check2_Callback(hObject, eventdata, handles)
if length(handles.check2.String) > 4
    set(handles.deviceChoice,'String',handles.check2.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check3_Callback(hObject, eventdata, handles)
if length(handles.check3.String) > 4
    set(handles.deviceChoice,'String',handles.check3.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check4_Callback(hObject, eventdata, handles)
if length(handles.check4.String) > 4
    set(handles.deviceChoice,'String',handles.check4.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check5_Callback(hObject, eventdata, handles)
if length(handles.check5.String) > 4
    set(handles.deviceChoice,'String',handles.check5.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check6_Callback(hObject, eventdata, handles)
if length(handles.check6.String) > 4
    set(handles.deviceChoice,'String',handles.check6.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check7_Callback(hObject, eventdata, handles)
if length(handles.check7.String) > 4
    set(handles.deviceChoice,'String',handles.check7.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check8_Callback(hObject, eventdata, handles)
if length(handles.check8.String) > 4
    set(handles.deviceChoice,'String',handles.check8.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check9_Callback(hObject, eventdata, handles)
if length(handles.check9.String) > 4
    set(handles.deviceChoice,'String',handles.check9.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check10_Callback(hObject, eventdata, handles)
if length(handles.check10.String) > 4
    set(handles.deviceChoice,'String',handles.check10.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check11_Callback(hObject, eventdata, handles)
if length(handles.check11.String) > 4
    set(handles.deviceChoice,'String',handles.check11.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check12_Callback(hObject, eventdata, handles)
if length(handles.check12.String) > 4
    set(handles.deviceChoice,'String',handles.check12.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check13_Callback(hObject, eventdata, handles)
if length(handles.check13.String) > 4
    set(handles.deviceChoice,'String',handles.check13.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check14_Callback(hObject, eventdata, handles)
if length(handles.check14.String) > 4
    set(handles.deviceChoice,'String',handles.check14.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check15_Callback(hObject, eventdata, handles)
if length(handles.check15.String) > 4
    set(handles.deviceChoice,'String',handles.check15.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

%graphs data from most recent/current file for the device by populating the
%information into the file selection drop down menus and running the graph
%function
function check16_Callback(hObject, eventdata, handles)
if length(handles.check16.String) > 4
    set(handles.deviceChoice,'String',handles.check16.String)
    handles.fileChoice = [];
    delete(handles.graphPanel.Children(2:end))
    set(handles.trialDisplay,'String','');
    set(handles.trialRecordText,'String','')
    set(handles.AnalysisTrials,'String','')
    
    % data location is given a variable
    handles.dataLocation = [handles.devicesFolder,handles.deviceChoice.String,'/'];
    
    handles.listFolder = dir(handles.dataLocation);
    validFiles = find(~[handles.listFolder.isdir]);
    fileDates = [handles.listFolder.datenum];
    [~,sortedFiles] = sort(fileDates,'descend');
    sortedFiles = sortedFiles(ismember(sortedFiles,validFiles));
    textDisplay = {};
    for z = 1:numel(sortedFiles)
        if handles.listFolder(sortedFiles(z)).name(2) == 'e'
            textDisplay = [textDisplay;{handles.listFolder(sortedFiles(z)).name}];
        end
    end
    handles.fileSelection.String = textDisplay;
    set(handles.fileSelection,'Enable','on')
    set(handles.graphButton,'Enable','on')
    graphButton_Callback(hObject, eventdata, handles)
    
end
guidata(hObject, handles);

function fileLocation_Callback(hObject, eventdata, handles)
function fileLocation_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filePath_Callback(hObject, eventdata, handles)
% checks to see if file path is valid, if not then a warning message pops up
checkPath1 = exist(handles.fileLocation.String);
if checkPath1 == 0
    popup = msgbox('Invalid file path');
else
    
    % checks to see if a Devices folder already exists in this location
    checkPath2 = exist([handles.fileLocation.String '\Devices']);
    checkPath3 = exist([handles.fileLocation.String 'Devices']);
    
    % if the folder doesn't exist then a dialogue box opens and asks user if
    % this is the correct file path
    if checkPath2 == 0 && checkPath3 == 0
        fp = msgbox('No data can be found in this location to graph. Change file path.');
    else
        handles.devicesFolder = [handles.fileLocation.String '\Devices\'];
        set(handles.checkDevices,'Enable','on')
        set(handles.deviceChoice,'Enable','on')
    end
end
guidata(hObject, handles);

function AnalysisTrials_Callback(hObject, eventdata, handles)
function AnalysisTrials_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Continuously checks the status of the devices. If a device has a red
% status then an email will be sent as a notifcation
function emailNotif_Callback(hObject, eventdata, handles)

if handles.emailNotif.Value == 1
    set(handles.emailNotif,'BackgroundColor','k','ForegroundColor','w')
elseif handles.emailNotif.Value == 0
    set(handles.emailNotif,'BackgroundColor','w','ForegroundColor','k')
end

%if this is the first time this button has been pressed since the GUI has
%been opened then the user inputs information
if handles.statusLoop == 0 && handles.emailNotif.Value == 1
    %opens dialogue box for user email input, must use gmail
    prompt = {'Gmail Username','Password','Email Recipient','Email Message'};
    title = 'Failure Email Notification';
    dims = [1 60];
    answer = inputdlg(prompt,title,dims);
    handles.defaultInputs = answer;
    
    %if the user input the email information earlier then a question box
    %pops up and asks if the user would like to input new information or
    %keep the old information
elseif handles.statusLoop > 0 && handles.emailNotif.Value == 1
    inputChoice = questdlg(['Would you like to change your previous email '...
        'settings? Send From: ' handles.defaultInputs{1} '@gmail.com; Recipient: '...
        handles.defaultInputs{3}], 'Email Notification Settings','Yes','No','No');
    switch inputChoice
        case 'Yes'
            prompt = {'Gmail Username','Password','Email Recipient','Email Message'};
            title = 'Failure Email Notification';
            dims = [1 60];
            answer = inputdlg(prompt,title,dims);
            handles.defaultInputs = answer;
        case 'No'
            answer = handles.defaultInputs;
    end
end

%a value greater than 1 indicates the Error Notification button has been
%pressed more than once
handles.statusLoop = handles.statusLoop + 1;

%every 30 minutes, checks how recently each device saved a file
while handles.emailNotif.Value == 1
    pause(1800)
    load([handles.devicesFolder 'currentDevices.mat'])
    failedDevices = {};
    %for each device it first checks that the parameters have been moved into
    %the associated folder and then looks at when the most recent trial was
    %saved and then color codes the device based on the status
    for z = 1:numel(onDevices)
        set(handles.checkPiButtons(z),'Enable','on')
        loaded = 0;
        while ~loaded
            try
                load([handles.devicesFolder onDevices{z} '/performance.mat'])
                load([handles.devicesFolder onDevices{z} '/stopButton.mat'])
                loaded = 1;
            end
        end
        set(handles.checkPiButtons(z),'String',onDevices{z})
        try
            t1 = clock;
            t2 = datevec(timeStamp{length(timeStamp),2});
            timeCheck = (etime(t1,t2))/60;
            
            %if the device is not on an inter block interval and has recorded a
            %trial within the last 10 minutes then the status is green
            if timeCheck < 10 && blockInterval == 0
                set(handles.checkPiButtons(z),'BackgroundColor','g','ForegroundColor','k')
                
                %if the device is not on an inter block interval and hasn't recorded a
                %trial within the last 30 minutes then the status is red
            elseif timeCheck > 30 && blockInterval == 0 && pauseProgram == 0
                set(handles.checkPiButtons(z),'BackgroundColor','r','ForegroundColor','k')
                failedDevices = [failedDevices; onDevices{z}]
                
                %if the device is on an inter block interval and has recorded a
                %trial within the last 70 minutes then the status is yellow
            elseif timeCheck < 70 && blockInterval == 1 && pauseProgram == 0
                set(handles.checkPiButtons(z),'BackgroundColor','y','ForegroundColor','k')
                
                %if the device is on an inter block interval and hasn't recorded a
                %trial within the last 90 minutes then the status is red
            elseif timeCheck > 90 && blockInterval == 1 && pauseProgram == 0
                set(handles.checkPiButtons(z),'BackgroundColor','r','ForegroundColor','k')
                failedDevices = [failedDevices; onDevices{z}]
                
                %if the device has been paused then the status is magenta
            elseif pauseProgram == 1
                set(handles.checkPiButtons(z),'BackgroundColor','m','ForegroundColor','w')
            end
            
        catch
            
            %if the parameters file has not been moved to the associated
            %device folder then the status is blue
            set(handles.checkPiButtons(z),'BackgroundColor','b','ForegroundColor','w')
        end
        
    end
    
    %names the buttons to the corresponding device name
    for z = numel(onDevices) + 1:16
        set(handles.checkPiButtons(z),'BackgroundColor','default','ForegroundColor','k')
        set(handles.checkPiButtons(z),'String',['Pi',num2str(z)])
    end
    
    if ~isempty(failedDevices)
        disp('sending email')
        setpref('Internet','SMTP_Server','smtp.gmail.com');
        setpref('Internet','E_mail',[answer{1},'@gmail.com']);
        setpref('Internet','SMTP_Username',answer{1});
        setpref('Internet','SMTP_Password',answer{2});
        props = java.lang.System.getProperties;
        props.setProperty('mail.smtp.auth','true');
        props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
        props.setProperty('mail.smtp.socketFactory.port','465');
        sendmail(answer{3},answer{4},failedDevices); 
    end
end
guidata(hObject, handles);

