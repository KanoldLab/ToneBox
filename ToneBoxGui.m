function varargout = ToneBoxGui(varargin)

% TONEBOXGUI MATLAB code for ToneBoxGui.fig
%      TONEBOXGUI, by itself, creates a new TONEBOXGUI or raises the existing
%      singleton*.
%
%      H = TONEBOXGUI returns the handle to a new TONEBOXGUI or the handle to
%      the existing singleton*.
%
%      TONEBOXGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TONEBOXGUI.M with the given input arguments.
%
%      TONEBOXGUI('Property','Value',...) creates a new TONEBOXGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ToneBoxGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ToneBoxGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ToneBoxGui

% Last Modified by GUIDE v2.5 08-Nov-2018 12:25:05


% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ToneBoxGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ToneBoxGui_OutputFcn, ...
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

% --- Executes just before ToneBoxGui is made visible.
function ToneBoxGui_OpeningFcn(hObject, eventdata, handles, varargin)

% makes sure that 16 batch jobs can run at once
myCluster = parcluster('local');
myCluster.NumWorkers = 16;

%deletes all previous batch jobs that might have been left in the job
%manager, if a batch job does not get stopped properly from the ToneBoxGui 
%then the failed job might stay in the job monitor and they need to be
%deleted
x = myCluster.findJob;
delete(x);

% sets a variable to be used in graphing and stopping devices
handles.Stop = 0;

%sets file path to the current file that Matlab has open
fileLocation = pwd;
set(handles.fileLocation,'String',fileLocation);

%sets the target and nontarget tone selections to be empty
handles.target = [];
handles.nontarget = [];

%logs selected and running devices
handles.onDevices = {};

% disables the actions involving IP address
set(handles.scanIP,'Enable','off')
set(handles.lowerLimit,'Enable','off')
set(handles.upperLimit,'Enable','off')
set(handles.piSelection,'Enable','off')

% disables calibration, water test, sound test, and previous parameters 
% buttons because no devices are yet available
set(handles.speakerCalibration,'Enable','off');
set(handles.waterTest,'Enable','off');
set(handles.testSound,'Enable','off');
set(handles.previousParams,'Enable','off');

%disables the "Set Params", "Start", "Stop", and "Set Params" buttons
set(handles.startButton,'Enable','off')
set(handles.setParams,'Enable','off')
set(handles.stopButton,'Enable','off')

%disables the "Pause All". The "Resume All" button is also disabled as well
%as hidden
set(handles.pauseButton,'Enable','off')
set(handles.resumeButton,'Enable','off','Visible','off')

% hides and disables terminate button
set(handles.terminateButton,'visible','off','Enable','off')

%disables the phase selection drop down menu
set(handles.phaseSelection,'Enable','off');

%disables all the checkboxes for the target tones
set(handles.tone1,'Enable','off')
set(handles.tone2,'Enable','off')
set(handles.tone3,'Enable','off')
set(handles.tone4,'Enable','off')
set(handles.tone5,'Enable','off')
set(handles.tone6,'Enable','off')
set(handles.tone7,'Enable','off')
set(handles.tone8,'Enable','off')
set(handles.tone9,'Enable','off')
set(handles.tone10,'Enable','off')
set(handles.tone11,'Enable','off')
set(handles.tone12,'Enable','off')

%disables all the checkboxes for the nontarget tones
set(handles.toneNT1,'Enable','off')
set(handles.toneNT2,'Enable','off')
set(handles.toneNT3,'Enable','off')
set(handles.toneNT4,'Enable','off')
set(handles.toneNT5,'Enable','off')
set(handles.toneNT6,'Enable','off')
set(handles.toneNT7,'Enable','off')
set(handles.toneNT8,'Enable','off')
set(handles.toneNT9,'Enable','off')
set(handles.toneNT10,'Enable','off')
set(handles.toneNT11,'Enable','off')
set(handles.toneNT12,'Enable','off')

%disables option for silent trials
set(handles.silentTrials,'Enable','off')

%disables all checkboxes for level selection
set(handles.level1,'Enable','off')
set(handles.level2,'Enable','off')
set(handles.level3,'Enable','off')
set(handles.level4,'Enable','off')
set(handles.level5,'Enable','off')
set(handles.level6,'Enable','off')
set(handles.level7,'Enable','off')

% Choose default command line output for ToneBoxGui (provided by gui code)
handles.output = hObject;

% Update handles structure (provided by gui code)
guidata(hObject, handles);

% UIWAIT makes ToneBoxGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create tab group for graphing data from different devices, in this
% instance there are 16 tabs
% Names for tabs will be changed later once devices are running, the tab 
% names while align with the IDs of the devices
handles.tgroup=uitabgroup('Parent',handles.GraphPanel,'TabLocation','left');
handles.tab1 = uitab('Parent', handles.tgroup, 'Title', 'Pi1');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', 'Pi2');
handles.tab3 = uitab('Parent', handles.tgroup, 'Title', 'Pi3');
handles.tab4 = uitab('Parent', handles.tgroup, 'Title', 'Pi4');
handles.tab5 = uitab('Parent', handles.tgroup, 'Title', 'Pi5');
handles.tab6 = uitab('Parent', handles.tgroup, 'Title', 'Pi6');
handles.tab7 = uitab('Parent', handles.tgroup, 'Title', 'Pi7');
handles.tab8 = uitab('Parent', handles.tgroup, 'Title', 'Pi8');
handles.tab9 = uitab('Parent', handles.tgroup, 'Title', 'Pi9');
handles.tab10 = uitab('Parent', handles.tgroup, 'Title', 'Pi10');
handles.tab11 = uitab('Parent', handles.tgroup, 'Title', 'Pi11');
handles.tab12 = uitab('Parent', handles.tgroup, 'Title', 'Pi12');
handles.tab13 = uitab('Parent', handles.tgroup, 'Title', 'Pi13');
handles.tab14 = uitab('Parent', handles.tgroup, 'Title', 'Pi14');
handles.tab15 = uitab('Parent', handles.tgroup, 'Title', 'Pi15');
handles.tab16 = uitab('Parent', handles.tgroup, 'Title', 'Pi16');

% this vector is used later to rename the tabs based on the devices that
% are currently running and logging data
handles.AllTabs = [handles.tab1;handles.tab2;handles.tab3;handles.tab4;...
    handles.tab5;handles.tab6;handles.tab7;handles.tab8;handles.tab9;...
    handles.tab10;handles.tab11;handles.tab12;handles.tab13;handles.tab14;...
    handles.tab15;handles.tab16];

% Panels were added to the gui using the guide application provided by
% matlab. Then the tabs made previously using uicontrol commands were
% designated as the parents for the panels, so each tab has a panel inside
% so that parameters for each device can be displayed in the different tabs
set(handles.Pi1,'Parent',handles.tab1);
set(handles.Pi2,'Parent',handles.tab2);
set(handles.Pi3,'Parent',handles.tab3);
set(handles.Pi4,'Parent',handles.tab4);
set(handles.Pi5,'Parent',handles.tab5);
set(handles.Pi6,'Parent',handles.tab6);
set(handles.Pi7,'Parent',handles.tab7);
set(handles.Pi8,'Parent',handles.tab8);
set(handles.Pi9,'Parent',handles.tab9);
set(handles.Pi10,'Parent',handles.tab10);
set(handles.Pi11,'Parent',handles.tab11);
set(handles.Pi12,'Parent',handles.tab12);
set(handles.Pi13,'Parent',handles.tab13);
set(handles.Pi14,'Parent',handles.tab14);
set(handles.Pi15,'Parent',handles.tab15);
set(handles.Pi16,'Parent',handles.tab16);

% Text boxes that show which target tones were selected were
% placed inside the panels
set(handles.targetText1,'Parent',handles.Pi1,'visible','off');
set(handles.targetText2,'Parent',handles.Pi2,'visible','off');
set(handles.targetText3,'Parent',handles.Pi3,'visible','off');
set(handles.targetText4,'Parent',handles.Pi4,'visible','off');
set(handles.targetText5,'Parent',handles.Pi5,'visible','off');
set(handles.targetText6,'Parent',handles.Pi6,'visible','off');
set(handles.targetText7,'Parent',handles.Pi7,'visible','off');
set(handles.targetText8,'Parent',handles.Pi8,'visible','off');
set(handles.targetText9,'Parent',handles.Pi9,'visible','off');
set(handles.targetText10,'Parent',handles.Pi10,'visible','off');
set(handles.targetText11,'Parent',handles.Pi11,'visible','off');
set(handles.targetText12,'Parent',handles.Pi12,'visible','off');
set(handles.targetText13,'Parent',handles.Pi13,'visible','off');
set(handles.targetText14,'Parent',handles.Pi14,'visible','off');
set(handles.targetText15,'Parent',handles.Pi15,'visible','off');
set(handles.targetText16,'Parent',handles.Pi16,'visible','off');

% Text boxes that show which nontarget tones were selected were
% placed inside the panels
set(handles.nontargetText1,'Parent',handles.Pi1,'visible','off');
set(handles.nontargetText2,'Parent',handles.Pi2,'visible','off');
set(handles.nontargetText3,'Parent',handles.Pi3,'visible','off');
set(handles.nontargetText4,'Parent',handles.Pi4,'visible','off');
set(handles.nontargetText5,'Parent',handles.Pi5,'visible','off');
set(handles.nontargetText6,'Parent',handles.Pi6,'visible','off');
set(handles.nontargetText7,'Parent',handles.Pi7,'visible','off');
set(handles.nontargetText8,'Parent',handles.Pi8,'visible','off');
set(handles.nontargetText9,'Parent',handles.Pi9,'visible','off');
set(handles.nontargetText10,'Parent',handles.Pi10,'visible','off');
set(handles.nontargetText11,'Parent',handles.Pi11,'visible','off');
set(handles.nontargetText12,'Parent',handles.Pi12,'visible','off');
set(handles.nontargetText13,'Parent',handles.Pi13,'visible','off');
set(handles.nontargetText14,'Parent',handles.Pi14,'visible','off');
set(handles.nontargetText15,'Parent',handles.Pi15,'visible','off');
set(handles.nontargetText16,'Parent',handles.Pi16,'visible','off');

% Text boxes that show which phase were
% placed inside the panels
set(handles.phaseText1,'Parent',handles.Pi1,'visible','off');
set(handles.phaseText2,'Parent',handles.Pi2,'visible','off');
set(handles.phaseText3,'Parent',handles.Pi3,'visible','off');
set(handles.phaseText4,'Parent',handles.Pi4,'visible','off');
set(handles.phaseText5,'Parent',handles.Pi5,'visible','off');
set(handles.phaseText6,'Parent',handles.Pi6,'visible','off');
set(handles.phaseText7,'Parent',handles.Pi7,'visible','off');
set(handles.phaseText8,'Parent',handles.Pi8,'visible','off');
set(handles.phaseText9,'Parent',handles.Pi9,'visible','off');
set(handles.phaseText10,'Parent',handles.Pi10,'visible','off');
set(handles.phaseText11,'Parent',handles.Pi11,'visible','off');
set(handles.phaseText12,'Parent',handles.Pi12,'visible','off');
set(handles.phaseText13,'Parent',handles.Pi13,'visible','off');
set(handles.phaseText14,'Parent',handles.Pi14,'visible','off');
set(handles.phaseText15,'Parent',handles.Pi15,'visible','off');
set(handles.phaseText16,'Parent',handles.Pi16,'visible','off');


% Repositions each panel to same location as panel 1 so that they all align
set(handles.Pi2,'position',get(handles.Pi1,'position'));
set(handles.Pi3,'position',get(handles.Pi1,'position'));
set(handles.Pi4,'position',get(handles.Pi1,'position'));
set(handles.Pi5,'position',get(handles.Pi1,'position'));
set(handles.Pi6,'position',get(handles.Pi1,'position'));
set(handles.Pi7,'position',get(handles.Pi1,'position'));
set(handles.Pi8,'position',get(handles.Pi1,'position'));
set(handles.Pi9,'position',get(handles.Pi1,'position'));
set(handles.Pi10,'position',get(handles.Pi1,'position'));
set(handles.Pi11,'position',get(handles.Pi1,'position'));
set(handles.Pi12,'position',get(handles.Pi1,'position'));
set(handles.Pi13,'position',get(handles.Pi1,'position'));
set(handles.Pi14,'position',get(handles.Pi1,'position'));
set(handles.Pi15,'position',get(handles.Pi1,'position'));
set(handles.Pi16,'position',get(handles.Pi1,'position'));

% Repositions each target tones text box to same location so that they all align
set(handles.targetText2,'position',get(handles.targetText1,'position'));
set(handles.targetText3,'position',get(handles.targetText1,'position'));
set(handles.targetText4,'position',get(handles.targetText1,'position'));
set(handles.targetText5,'position',get(handles.targetText1,'position'));
set(handles.targetText6,'position',get(handles.targetText1,'position'));
set(handles.targetText7,'position',get(handles.targetText1,'position'));
set(handles.targetText8,'position',get(handles.targetText1,'position'));
set(handles.targetText9,'position',get(handles.targetText1,'position'));
set(handles.targetText10,'position',get(handles.targetText1,'position'));
set(handles.targetText11,'position',get(handles.targetText1,'position'));
set(handles.targetText12,'position',get(handles.targetText1,'position'));
set(handles.targetText13,'position',get(handles.targetText1,'position'));
set(handles.targetText14,'position',get(handles.targetText1,'position'));
set(handles.targetText15,'position',get(handles.targetText1,'position'));
set(handles.targetText16,'position',get(handles.targetText1,'position'));

% Repositions each nontarget tones text box to same location so that they all align
set(handles.nontargetText2,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText3,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText4,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText5,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText6,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText7,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText8,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText9,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText10,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText11,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText12,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText13,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText14,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText15,'position',get(handles.nontargetText1,'position'));
set(handles.nontargetText16,'position',get(handles.nontargetText1,'position'));

% Repositions each phase text box to same location so that they all align
set(handles.phaseText2,'position',get(handles.phaseText1,'position'));
set(handles.phaseText3,'position',get(handles.phaseText1,'position'));
set(handles.phaseText4,'position',get(handles.phaseText1,'position'));
set(handles.phaseText5,'position',get(handles.phaseText1,'position'));
set(handles.phaseText6,'position',get(handles.phaseText1,'position'));
set(handles.phaseText7,'position',get(handles.phaseText1,'position'));
set(handles.phaseText8,'position',get(handles.phaseText1,'position'));
set(handles.phaseText9,'position',get(handles.phaseText1,'position'));
set(handles.phaseText10,'position',get(handles.phaseText1,'position'));
set(handles.phaseText11,'position',get(handles.phaseText1,'position'));
set(handles.phaseText12,'position',get(handles.phaseText1,'position'));
set(handles.phaseText13,'position',get(handles.phaseText1,'position'));
set(handles.phaseText14,'position',get(handles.phaseText1,'position'));
set(handles.phaseText15,'position',get(handles.phaseText1,'position'));
set(handles.phaseText16,'position',get(handles.phaseText1,'position'));

% this vector is used later to display the target tones that were selected
% in the correct tab
handles.targetDisplay = [handles.targetText1;handles.targetText2;...
    handles.targetText3;handles.targetText4;handles.targetText5;...
    handles.targetText6;handles.targetText7;handles.targetText8;...
    handles.targetText9;handles.targetText10;handles.targetText11;...
    handles.targetText12;handles.targetText13;handles.targetText14;...
    handles.targetText15;handles.targetText16];

% this vector is used later to display the nontarget tones that were selected
% in the correct tab
handles.nontargetDisplay = [handles.nontargetText1;handles.nontargetText2;...
    handles.nontargetText3;handles.nontargetText4;handles.nontargetText5;...
    handles.nontargetText6;handles.nontargetText7;handles.nontargetText8;...
    handles.nontargetText9;handles.nontargetText10;handles.nontargetText11;...
    handles.nontargetText12;handles.nontargetText13;handles.nontargetText14;...
    handles.nontargetText15;handles.nontargetText16];

% this vector is used later to display the phase selected for each device
handles.phaseDisplay = [handles.phaseText1;handles.phaseText2;...
    handles.phaseText3;handles.phaseText4;handles.phaseText5;...
    handles.phaseText6;handles.phaseText7;handles.phaseText8;...
    handles.phaseText9;handles.phaseText10;handles.phaseText11;...
    handles.phaseText12;handles.phaseText13;handles.phaseText14;...
    handles.phaseText15;handles.phaseText16];

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles)

% --- Outputs from this function are returned to the command line.
function varargout = ToneBoxGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%file location is the textbox that you type the file path into
function fileLocation_Callback(hObject, eventdata, handles)

function fileLocation_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filePath. Saves file path entered into the file location text box
function filePath_Callback(hObject, eventdata, handles)

% checks to see if file path is valid, if not then a warning message pops
% up
checkPath1 = exist(handles.fileLocation.String);
if checkPath1 == 0
    popup = msgbox('Invalid file path');
else
    
    % checks to see if a Devices folder already exists in this location
    checkPath2 = exist([handles.fileLocation.String '\Devices']);
    checkPath3 = exist([handles.fileLocation.String 'Devices']);
    
    % if the folder doesn't exist then a dialogue box opens and asks user if
    % this is the correct file path, if so then a new Devices folder will
    % be made at that locaiton, if not then the user will input a new
    % filepath
    if checkPath2 == 0 && checkPath3 == 0
        answer = questdlg('A Devices folder does not yet exist in this location. Is this the correct file path?',...
            'File Path','Yes, make new Devices folder','No, change file path','Yes, make new Devices folder');
        switch answer
            case 'Yes, make new Devices folder'
                mkdir([handles.fileLocation.String '\Devices\'])
            case 'No, change file path'
                
        end
    end
end

%saves the devices folder
handles.devicesFolder = [handles.fileLocation.String '\Devices\'];

% changes variable name so it can be saved and passed to the batch job as
% an argument
devicesFolder = handles.devicesFolder;

% enables the actions involving IP address scanning and selection
set(handles.scanIP,'Enable','on')
set(handles.lowerLimit,'Enable','on')
set(handles.upperLimit,'Enable','on')
set(handles.piSelection,'Enable','on')

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);

% these lower and upper limits set the range for scanning IP addresses, the
% default is set from 0 to 255 which is the maximum range
function lowerLimit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lowerLimit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function upperLimit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function upperLimit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scanIP. Scans IP addresses on the same
% wireless router, finds IP addresses associated with Raspberry Pi devices,
% finds the hostnames of each Raspberry Pi, then lists the hostnames with
% the associated IP addresses in a drop down menu
function scanIP_Callback(hObject, eventdata, handles)

% sets home directory to look for IP scanning program
homedir = handles.fileLocation.String;
if exist([homedir '\tempIP.csv']) == 1
    delete([homedir '\tempIP.csv'])
end
% finds the IP address of the network so that an appropriate IP range can
% be selected
[status,cmdout] = system('ipconfig | findstr /i "ipv4"');
Sepcmdout=strsep(cmdout,':');
IPs=strsep(Sepcmdout{2},'.');
IP1 = num2str(IPs{1});
IP2 = num2str(IPs{2});
IP3 = num2str(IPs{3});


%IPrange is set from gui, lowest value is 0 and highest value is 255
IPrange{1}= [IP1,'.',IP2,'.',IP3,'.',handles.lowerLimit.String];
IPrange{2}= [IP1,'.',IP2,'.',IP3,'.',handles.upperLimit.String];

%tells the IPScan program to scan in the specified range and saves the
%information into a temporary file
system(['ipscan -s -q -f:range ' IPrange{1} ' ' IPrange{2} ' -o ' homedir '\tempIP.csv']);

%goes through each IP address to find ones that had a connection to a
%raspberry pi, this loop is searching for MACVendor names that include the
%word "Raspberry" to indentify the pi devices
IP=0;
while ~IP
    IP=exist([homedir '\tempIP.csv']);
end
M = readtable([homedir '\tempIP.csv']);
delete([homedir '\tempIP.csv'])
IP = M.IP;
MACVendor = M.MACVendor;
handles.Devices={};
for i = 1:length(IP)
    if ~isempty(strfind(MACVendor{i},'Raspberry'))
        handles.Devices = [handles.Devices; {num2str(IP{i})}];
    end
end

% creates cell of hostnames to list available raspberry pi devices
handles.cageID = {};
for k = 1:size(handles.Devices)
    rpi = raspi(char(handles.Devices(k,:)),'tonebox','thirstymouse');
    handles.cageID = [handles.cageID; char(strip({system(rpi,'hostname')}))];
end

% concatenates hostnames with IP addresses to be listed in a drop down menu
handles.piSelection.String = {char(strcat(string(handles.cageID),'_',string(handles.Devices)))};

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);


% --- Executes on selection change in piSelection, when a device is
% selected that pi will be connected to matlab so the variable rpi can be
% saved to the parameters file
function piSelection_Callback(hObject, eventdata, handles)
% sets initial variables to be empty
rpi = [];
handles.rpi = [];

% finds selected string from drop down menu
handles.piChoice = get(hObject, 'Value');

% saves choice for parameters file
piChoice = handles.piChoice;

% gets the IP address for the device selection and turns it into a
% character string to be used in the raspi connection function
pibox = char(handles.Devices(handles.piChoice));

% gets the hostname for the selected device and turns it into a character
% string to be saved in the parameters file
cageID = char(handles.cageID(handles.piChoice));

% sets file path for where parameters will be saved
handles.filename = [handles.devicesFolder 'PiParams.mat'];

% connects selected raspberry pi to matlab
rpi = raspi(pibox);

% saves variables to parameters file
save(handles.filename,'pibox','cageID','piChoice','rpi');

% reassigns variable so that the connection information can be transferred
% between gui operations
handles.rpi = rpi;

% deletes local variable which was saved to the parameters file
clear rpi;

% once the pi is successfully connected, "Phase Selection" drop down menu,
% "Test Water" button, "Test Sound" button, "Previous Params" button, 
% and "Speaker Calibration" button become available. this will only occur
% if the device is not already running
checkPi = find(strcmp(char(handles.onDevices),cageID));
if checkPi > 0
    set(handles.speakerCalibration,'Enable','off');
    set(handles.waterTest,'Enable','off');
    set(handles.testSound,'Enable','off');
    set(handles.previousParams,'Enable','off');
    set(handles.phaseSelection,'Enable','off');
    delete(handles.rpi)
else
    set(handles.speakerCalibration,'Enable','on');
    set(handles.waterTest,'Enable','on');
    set(handles.testSound,'Enable','on')
    set(handles.previousParams,'Enable','on');
    set(handles.phaseSelection,'Enable','on');
    set(handles.scanIP,'Enable','off');
    set(handles.upperLimit,'Enable','off');
    set(handles.lowerLimit,'Enable','off');
end

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function piSelection_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in phaseSelection, selects the phase
% that will be run
function phaseSelection_Callback(hObject, eventdata, handles)

%checks the string of the hObject's current value
str = get(hObject, 'String');
val = get(hObject, 'Value');
switch str{val};

case 'Training Phase:'
    % No phase has been selected so all the buttons and boxes remain
    % disabled
    handles.phaseChoice = 0;
    set(handles.startButton,'Enable','off');
    set(handles.setParams,'Enable','off');
    set(handles.tone1,'Enable','off');
    set(handles.tone2,'Enable','off');
    set(handles.tone3,'Enable','off');
    set(handles.tone4,'Enable','off');
    set(handles.tone5,'Enable','off');
    set(handles.tone6,'Enable','off');
    set(handles.tone7,'Enable','off');
    set(handles.tone8,'Enable','off');
    set(handles.tone9,'Enable','off');
    set(handles.tone10,'Enable','off');
    set(handles.tone11,'Enable','off');
    set(handles.tone12,'Enable','off');
    set(handles.toneNT1,'Enable','off');
    set(handles.toneNT2,'Enable','off');
    set(handles.toneNT3,'Enable','off');
    set(handles.toneNT4,'Enable','off');
    set(handles.toneNT5,'Enable','off');
    set(handles.toneNT6,'Enable','off');
    set(handles.toneNT7,'Enable','off');
    set(handles.toneNT8,'Enable','off');
    set(handles.toneNT9,'Enable','off');
    set(handles.toneNT10,'Enable','off');
    set(handles.toneNT11,'Enable','off');
    set(handles.toneNT12,'Enable','off');
    set(handles.tone1, 'Value', 0);
    set(handles.tone2, 'Value', 0);
    set(handles.tone3, 'Value', 0);
    set(handles.tone4, 'Value', 0);
    set(handles.tone5, 'Value', 0);
    set(handles.tone6, 'Value', 0);
    set(handles.tone7, 'Value', 0);
    set(handles.tone8, 'Value', 0);
    set(handles.tone9, 'Value', 0);
    set(handles.tone10, 'Value', 0);
    set(handles.tone11, 'Value', 0);
    set(handles.tone12, 'Value', 0);
    set(handles.toneNT1, 'Value', 0);
    set(handles.toneNT2, 'Value', 0);
    set(handles.toneNT3, 'Value', 0);
    set(handles.toneNT4, 'Value', 0);
    set(handles.toneNT5, 'Value', 0);
    set(handles.toneNT6, 'Value', 0);
    set(handles.toneNT7, 'Value', 0);
    set(handles.toneNT8, 'Value', 0);
    set(handles.toneNT9, 'Value', 0);
    set(handles.toneNT10, 'Value', 0);
    set(handles.toneNT11, 'Value', 0);
    set(handles.toneNT12, 'Value', 0);
    
    %disables options to select tone levels
    set(handles.level1,'Enable','off')
    set(handles.level2,'Enable','off')
    set(handles.level3,'Enable','off')
    set(handles.level4,'Enable','off')
    set(handles.level5,'Enable','off')
    set(handles.level6,'Enable','off')
    set(handles.level7,'Enable','off')
    set(handles.level1,'Value',0)
    set(handles.level2,'Value',0)
    set(handles.level3,'Value',0)
    set(handles.level4,'Value',0)
    set(handles.level5,'Value',0)
    set(handles.level6,'Value',0)
    set(handles.level7,'Value',0)
    
    %disables silent trials option
    set(handles.silentTrials,'Enable','off')
    set(handles.silentTrials,'Value',0)
    
case 'Habituation'
    handles.phaseChoice = 1;
    
    % "Set Params" button is enabled
    set(handles.setParams,'Enable','on');
    
    % This phase does not require sound so all the sound options remain
    % disabled
    set(handles.startButton,'Enable','off');
    set(handles.tone1,'Enable','off');
    set(handles.tone2,'Enable','off');
    set(handles.tone3,'Enable','off');
    set(handles.tone4,'Enable','off');
    set(handles.tone5,'Enable','off');
    set(handles.tone6,'Enable','off');
    set(handles.tone7,'Enable','off');
    set(handles.tone8,'Enable','off');
    set(handles.tone9,'Enable','off');
    set(handles.tone10,'Enable','off');
    set(handles.tone11,'Enable','off');
    set(handles.tone12,'Enable','off');
    set(handles.toneNT1,'Enable','off');
    set(handles.toneNT2,'Enable','off');
    set(handles.toneNT3,'Enable','off');
    set(handles.toneNT4,'Enable','off');
    set(handles.toneNT5,'Enable','off');
    set(handles.toneNT6,'Enable','off');
    set(handles.toneNT7,'Enable','off');
    set(handles.toneNT8,'Enable','off');
    set(handles.toneNT9,'Enable','off');
    set(handles.toneNT10,'Enable','off');
    set(handles.toneNT11,'Enable','off');
    set(handles.toneNT12,'Enable','off');
    set(handles.tone1, 'Value', 0);
    set(handles.tone2, 'Value', 0);
    set(handles.tone3, 'Value', 0);
    set(handles.tone4, 'Value', 0);
    set(handles.tone5, 'Value', 0);
    set(handles.tone6, 'Value', 0);
    set(handles.tone7, 'Value', 0);
    set(handles.tone8, 'Value', 0);
    set(handles.tone9, 'Value', 0);
    set(handles.tone10, 'Value', 0);
    set(handles.tone11, 'Value', 0);
    set(handles.tone12, 'Value', 0);
    set(handles.toneNT1, 'Value', 0);
    set(handles.toneNT2, 'Value', 0);
    set(handles.toneNT3, 'Value', 0);
    set(handles.toneNT4, 'Value', 0);
    set(handles.toneNT5, 'Value', 0);
    set(handles.toneNT6, 'Value', 0);
    set(handles.toneNT7, 'Value', 0);
    set(handles.toneNT8, 'Value', 0);
    set(handles.toneNT9, 'Value', 0);
    set(handles.toneNT10, 'Value', 0);
    set(handles.toneNT11, 'Value', 0);
    set(handles.toneNT12, 'Value', 0);
    
    %disables options to select tone levels
    set(handles.level1,'Enable','off')
    set(handles.level2,'Enable','off')
    set(handles.level3,'Enable','off')
    set(handles.level4,'Enable','off')
    set(handles.level5,'Enable','off')
    set(handles.level6,'Enable','off')
    set(handles.level7,'Enable','off')
    set(handles.level1,'Value',0)
    set(handles.level2,'Value',0)
    set(handles.level3,'Value',0)
    set(handles.level4,'Value',0)
    set(handles.level5,'Value',0)
    set(handles.level6,'Value',0)
    set(handles.level7,'Value',0)
    
    %disables silent trials option
    set(handles.silentTrials,'Enable','off')
    set(handles.silentTrials,'Value',0)
    
case 'Shaping'
    handles.phaseChoice = 2;
    
    % "Set Params" button is enabled
    set(handles.setParams,'Enable','on');
    
    % Target tone checkboxes are enabled
    set(handles.tone1,'Enable','on');
    set(handles.tone2,'Enable','on');
    set(handles.tone3,'Enable','on');
    set(handles.tone4,'Enable','on');
    set(handles.tone5,'Enable','on');
    set(handles.tone6,'Enable','on');
    set(handles.tone7,'Enable','on');
    set(handles.tone8,'Enable','on');
    set(handles.tone9,'Enable','on');
    set(handles.tone10,'Enable','on');
    set(handles.tone11,'Enable','on');
    set(handles.tone12,'Enable','on');
    
    % Nontarget tone checkboxes remain disabled because shaping does not
    % use them
    set(handles.toneNT1,'Enable','off');
    set(handles.toneNT2,'Enable','off');
    set(handles.toneNT3,'Enable','off');
    set(handles.toneNT4,'Enable','off');
    set(handles.toneNT5,'Enable','off');
    set(handles.toneNT6,'Enable','off');
    set(handles.toneNT7,'Enable','off');
    set(handles.toneNT8,'Enable','off');
    set(handles.toneNT9,'Enable','off');
    set(handles.toneNT10,'Enable','off');
    set(handles.toneNT11,'Enable','off');
    set(handles.toneNT12,'Enable','off');
    set(handles.toneNT1, 'Value', 0);
    set(handles.toneNT2, 'Value', 0);
    set(handles.toneNT3, 'Value', 0);
    set(handles.toneNT4, 'Value', 0);
    set(handles.toneNT5, 'Value', 0);
    set(handles.toneNT6, 'Value', 0);
    set(handles.toneNT7, 'Value', 0);
    set(handles.toneNT8, 'Value', 0);
    set(handles.toneNT9, 'Value', 0);
    set(handles.toneNT10, 'Value', 0);
    set(handles.toneNT11, 'Value', 0);
    set(handles.toneNT12, 'Value', 0);
    
    %disables options to select tone levels
    set(handles.level1,'Enable','off')
    set(handles.level2,'Enable','off')
    set(handles.level3,'Enable','off')
    set(handles.level4,'Enable','off')
    set(handles.level5,'Enable','off')
    set(handles.level6,'Enable','off')
    set(handles.level7,'Enable','off')
    set(handles.level1,'Value',0)
    set(handles.level2,'Value',0)
    set(handles.level3,'Value',0)
    set(handles.level4,'Value',0)
    set(handles.level5,'Value',0)
    set(handles.level6,'Value',0)
    set(handles.level7,'Value',0)
    
    %disables silent trials option
    set(handles.silentTrials,'Enable','off')
    set(handles.silentTrials,'Value',0)
    
case 'Detection'
    handles.phaseChoice = 3;
    
    % "Set Params" button is enabled
    set(handles.setParams,'Enable','on');
    
    % Target tone checkboxes are enabled
    set(handles.tone1,'Enable','on');
    set(handles.tone2,'Enable','on');
    set(handles.tone3,'Enable','on');
    set(handles.tone4,'Enable','on');
    set(handles.tone5,'Enable','on');
    set(handles.tone6,'Enable','on');
    set(handles.tone7,'Enable','on');
    set(handles.tone8,'Enable','on');
    set(handles.tone9,'Enable','on');
    set(handles.tone10,'Enable','on');
    set(handles.tone11,'Enable','on');
    set(handles.tone12,'Enable','on');
    
    %enables option to select tone level
    set(handles.level1,'Enable','on')
    set(handles.level2,'Enable','on')
    set(handles.level3,'Enable','on')
    set(handles.level4,'Enable','on')
    set(handles.level5,'Enable','on')
    set(handles.level6,'Enable','on')
    set(handles.level7,'Enable','on')
    
    %enables option for silent trials
    set(handles.silentTrials,'Enable','on')
    
    % Nontarget tone checkboxes remain disabled because detection does not
    % use them
    set(handles.toneNT1,'Enable','off');
    set(handles.toneNT2,'Enable','off');
    set(handles.toneNT3,'Enable','off');
    set(handles.toneNT4,'Enable','off');
    set(handles.toneNT5,'Enable','off');
    set(handles.toneNT6,'Enable','off');
    set(handles.toneNT7,'Enable','off');
    set(handles.toneNT8,'Enable','off');
    set(handles.toneNT9,'Enable','off');
    set(handles.toneNT10,'Enable','off');
    set(handles.toneNT11,'Enable','off');
    set(handles.toneNT12,'Enable','off');
    set(handles.toneNT1, 'Value', 0);
    set(handles.toneNT2, 'Value', 0);
    set(handles.toneNT3, 'Value', 0);
    set(handles.toneNT4, 'Value', 0);
    set(handles.toneNT5, 'Value', 0);
    set(handles.toneNT6, 'Value', 0);
    set(handles.toneNT7, 'Value', 0);
    set(handles.toneNT8, 'Value', 0);
    set(handles.toneNT8, 'Value', 0);
    set(handles.toneNT9, 'Value', 0);
    set(handles.toneNT10, 'Value', 0);
    set(handles.toneNT11, 'Value', 0);
    set(handles.toneNT12, 'Value', 0);
    
case 'Discrimination'
    handles.phaseChoice = 4;
    
    % "Set Params" button is enabled
    set(handles.setParams,'Enable','on');
    
    % Target tone checkboxes are enabled
    set(handles.tone1,'Enable','on')
    set(handles.tone2,'Enable','on')
    set(handles.tone3,'Enable','on')
    set(handles.tone4,'Enable','on')
    set(handles.tone5,'Enable','on')
    set(handles.tone6,'Enable','on')
    set(handles.tone7,'Enable','on')
    set(handles.tone8,'Enable','on')
    set(handles.tone9,'Enable','on');
    set(handles.tone10,'Enable','on');
    set(handles.tone11,'Enable','on');
    set(handles.tone12,'Enable','on');
    
    % Nonarget tone checkboxes are enabled
    set(handles.toneNT1,'Enable','on')
    set(handles.toneNT2,'Enable','on')
    set(handles.toneNT3,'Enable','on')
    set(handles.toneNT4,'Enable','on')
    set(handles.toneNT5,'Enable','on')
    set(handles.toneNT6,'Enable','on')
    set(handles.toneNT7,'Enable','on')
    set(handles.toneNT8,'Enable','on')
    set(handles.toneNT9,'Enable','on');
    set(handles.toneNT10,'Enable','on');
    set(handles.toneNT11,'Enable','on');
    set(handles.toneNT12,'Enable','on');
    
    %enables option to select tone level
    set(handles.level1,'Enable','on')
    set(handles.level2,'Enable','on')
    set(handles.level3,'Enable','on')
    set(handles.level4,'Enable','on')
    set(handles.level5,'Enable','on')
    set(handles.level6,'Enable','on')
    set(handles.level7,'Enable','on')
    
    %enables option for silent trials
    set(handles.silentTrials,'Enable','on')
end

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function phaseSelection_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% If one tone is selected in the targets/nontargets tone box, then the same
% tone is disabled in the nontargets/targets tone box
function toneNT1_Callback(hObject, eventdata, handles)
set(handles.tone1, 'Value', 0);

function toneNT2_Callback(hObject, eventdata, handles)
set(handles.tone2, 'Value', 0);

function toneNT3_Callback(hObject, eventdata, handles)
set(handles.tone3, 'Value', 0);

function toneNT4_Callback(hObject, eventdata, handles)
set(handles.tone4, 'Value', 0);

function toneNT6_Callback(hObject, eventdata, handles)
set(handles.tone6, 'Value', 0);

function toneNT7_Callback(hObject, eventdata, handles)
set(handles.tone7, 'Value', 0);

function toneNT8_Callback(hObject, eventdata, handles)
set(handles.tone8, 'Value', 0);

function toneNT5_Callback(hObject, eventdata, handles)
set(handles.tone5, 'Value', 0);

function toneNT10_Callback(hObject, eventdata, handles)
set(handles.tone10, 'Value', 0);

function toneNT11_Callback(hObject, eventdata, handles)
set(handles.tone11, 'Value', 0);

function toneNT9_Callback(hObject, eventdata, handles)
set(handles.tone9, 'Value', 0);

function toneNT12_Callback(hObject, eventdata, handles)
set(handles.tone12, 'Value', 0);

function tone1_Callback(hObject, eventdata, handles)
set(handles.toneNT1, 'Value', 0);

function tone2_Callback(hObject, eventdata, handles)
set(handles.toneNT2, 'Value', 0);

function tone3_Callback(hObject, eventdata, handles)
set(handles.toneNT3, 'Value', 0);

function tone4_Callback(hObject, eventdata, handles)
set(handles.toneNT4, 'Value', 0);

function tone6_Callback(hObject, eventdata, handles)
set(handles.toneNT6, 'Value', 0);

function tone7_Callback(hObject, eventdata, handles)
set(handles.toneNT7, 'Value', 0);

function tone8_Callback(hObject, eventdata, handles)
set(handles.toneNT8, 'Value', 0);

function tone5_Callback(hObject, eventdata, handles)
set(handles.toneNT5, 'Value', 0);

function tone10_Callback(hObject, eventdata, handles)
set(handles.toneNT10, 'Value', 0);

function tone11_Callback(hObject, eventdata, handles)
set(handles.toneNT11, 'Value', 0);

function tone9_Callback(hObject, eventdata, handles)
set(handles.toneNT9, 'Value', 0);

function tone12_Callback(hObject, eventdata, handles)
set(handles.toneNT12, 'Value', 0);

%select levels that the tones will be played at
function level5_Callback(hObject, eventdata, handles)

function level6_Callback(hObject, eventdata, handles)

function level2_Callback(hObject, eventdata, handles)

function level7_Callback(hObject, eventdata, handles)

function level4_Callback(hObject, eventdata, handles)

function level3_Callback(hObject, eventdata, handles)

function level1_Callback(hObject, eventdata, handles)


%select whether silent trials will be present
function silentTrials_Callback(hObject, eventdata, handles)
guidata(hObject,handles);


% --- Executes on button press in setParams, this acts mostly as a
% visual check for the user so that they are happy with their selections
% before they hit the "Start" button, saves the parameters to a file that
% will be used in whichever phase program is selected, an additional file
% is saved with the parameters so that the gui can recall the previous
% parameters
function setParams_Callback(hObject, eventdata, handles)

% sets these vectors to be empty, deleting previous selections
handles.target = [];
handles.nontarget = [];
handles.toneLevel = [];

%sets variables to be saved to parameters file
targetChoice = [];
nontargetChoice = [];
toneLevelChoice = [];
silentTrials = 0;


% adds value of selected target to associated target vector
if get(handles.tone1, 'Value') == 1
    handles.target = [handles.target; 1];
end
if get(handles.tone2, 'Value') == 1
    handles.target = [handles.target; 1.4];
end
if get(handles.tone3, 'Value') == 1
    handles.target = [handles.target; 2];
end
if get(handles.tone4, 'Value') == 1
    handles.target = [handles.target; 2.8];
end
if get(handles.tone5, 'Value') == 1
    handles.target = [handles.target; 4];
end
if get(handles.tone6, 'Value') == 1
    handles.target = [handles.target; 5.7];
end
if get(handles.tone7, 'Value') == 1
    handles.target = [handles.target; 8];
end
if get(handles.tone8, 'Value') == 1
    handles.target = [handles.target; 11.3];
end
if get(handles.tone9, 'Value') == 1
    handles.target = [handles.target; 16];
end
if get(handles.tone10, 'Value') == 1
    handles.target = [handles.target; 22.6];
end
if get(handles.tone11, 'Value') == 1
    handles.target = [handles.target; 32];
end
if get(handles.tone12, 'Value') == 1
    handles.target = [handles.target; 45.3];
end
% saves target tones vector to the parameters file
targetChoice = handles.target;
save(handles.filename,'targetChoice','-append')

% adds value of selected nontarget to associated nontarget vector
if get(handles.toneNT1, 'Value') == 1
    handles.nontarget = [handles.nontarget; 1];
end
if get(handles.toneNT2, 'Value') == 1
    handles.nontarget = [handles.nontarget; 1.4];
end
if get(handles.toneNT3, 'Value') == 1
    handles.nontarget = [handles.nontarget; 2];
end
if get(handles.toneNT4, 'Value') == 1
    handles.nontarget = [handles.nontarget; 2.8];
end
if get(handles.toneNT5, 'Value') == 1
    handles.nontarget = [handles.nontarget; 4];
end
if get(handles.toneNT6, 'Value') == 1
    handles.nontarget = [handles.nontarget; 5.7];
end
if get(handles.toneNT7, 'Value') == 1
    handles.nontarget = [handles.nontarget; 8];
end
if get(handles.toneNT8, 'Value') == 1
    handles.nontarget = [handles.nontarget; 11.3];
end
if get(handles.toneNT9, 'Value') == 1
    handles.nontarget = [handles.nontarget; 16];
end
if get(handles.toneNT10, 'Value') == 1
    handles.nontarget = [handles.nontarget; 22.6];
end
if get(handles.toneNT11, 'Value') == 1
    handles.nontarget = [handles.nontarget; 32];
end
if get(handles.toneNT12, 'Value') == 1
    handles.nontarget = [handles.nontarget; 45.3];
end
% saves nontarget tones vector to the parameters file
nontargetChoice = handles.nontarget;
save(handles.filename,'nontargetChoice','-append')

% adds value of selected tone level to associated level vector
if get(handles.level1, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; 0];
end
if get(handles.level2, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -5];
end
if get(handles.level3, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -10];
end
if get(handles.level4, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -15];
end
if get(handles.level5, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -20];
end
if get(handles.level6, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -25];
end
if get(handles.level7, 'Value') == 1
    handles.toneLevel = [handles.toneLevel; -30];
end
% saves tone level vector to the parameters file
toneLevelChoice = handles.toneLevel;
save(handles.filename,'toneLevelChoice','-append')

% silent trial option saved to parameters file
if get(handles.silentTrials,'Value') == 1
    silentTrials = 1;
end
save(handles.filename,'silentTrials','-append')

%resaves value to a variable that can be saved into the parameters file
phaseChoice = handles.phaseChoice;


% makes sure that a folder exists for the device that is running, if a
% folder doesn't exist then one is created
checkFolder = exist([handles.devicesFolder, char(handles.cageID(handles.piChoice))]);
if checkFolder == 0
    mkdir(handles.devicesFolder, char(handles.cageID(handles.piChoice)))
end

%saves information to the previous parameters file for future use
save([handles.devicesFolder, char(handles.cageID(handles.piChoice)), '\PreviousPiParams.mat'],'phaseChoice', ...
    'targetChoice', 'nontargetChoice','toneLevelChoice','silentTrials')

%for shaping and detection
if handles.phaseChoice == 2 || handles.phaseChoice == 3
    % if the button gets pressed before tones are selected for the task
    % then an eror message pops up
    if get(handles.tone8, 'Value') == 0 && get(handles.tone7, 'Value') == 0 ...
            && get(handles.tone6, 'Value') == 0 && get(handles.tone5, 'Value') == 0 ...
            && get(handles.tone4, 'Value') == 0 && get(handles.tone3, 'Value') == 0 ...
            && get(handles.tone2, 'Value') == 0 && get(handles.tone1, 'Value') == 0 ...
            && get(handles.tone9, 'Value') == 0 && get(handles.tone10, 'Value') == 0 ...
            && get(handles.tone11, 'Value') == 0 && get(handles.tone12, 'Value') == 0
        popup = msgbox('No target tones were selected');
        set(handles.startButton,'Enable','off')
    else
    % enables the "Start" button
    set(handles.startButton,'Enable','on')
    end
end

%for detection
if handles.phaseChoice == 3
    %if set params button gets pressed before levels get selected then a
    %pop up message will ask the person to select a tone level
    if get(handles.level1,'Value') == 0 && get(handles.level2,'Value') == 0 ...
            && get(handles.level3,'Value') == 0 && get(handles.level4,'Value') == 0 ...
            && get(handles.level5,'Value') == 0 && get(handles.level6,'Value') == 0 ...
            && get(handles.level7,'Value') == 0
        popup = msgbox('No tone levels were selected');
        set(handles.startButton,'Enable','off')
    else
        %enables the "Start" button
        set(handles.startButton,'Enable','on')
    end
end

%for discrimination
if handles.phaseChoice == 4
    % if the button gets pressed before tones are selected for the task
    % then an eror message pops up (for targets, nontargets, or both)
    if get(handles.toneNT8, 'Value') == 0 && get(handles.toneNT7, 'Value') == 0 ...
            && get(handles.toneNT6, 'Value') == 0 && get(handles.toneNT5, 'Value') == 0 ...
            && get(handles.toneNT4, 'Value') == 0 && get(handles.toneNT3, 'Value') == 0 ...
            && get(handles.toneNT2, 'Value') == 0 && get(handles.toneNT1, 'Value') == 0 ...
            && get(handles.toneNT9, 'Value') == 0 && get(handles.toneNT10, 'Value') == 0 ...
            && get(handles.toneNT11, 'Value') == 0 && get(handles.toneNT12, 'Value') == 0 ...    
            && get(handles.tone8, 'Value') == 0 && get(handles.tone7, 'Value') == 0 ...
            && get(handles.tone6, 'Value') == 0 && get(handles.tone5, 'Value') == 0 ...
            && get(handles.tone4, 'Value') == 0 && get(handles.tone3, 'Value') == 0 ...
            && get(handles.tone2, 'Value') == 0 && get(handles.tone1, 'Value') == 0 ...
            && get(handles.tone9, 'Value') == 0 && get(handles.tone10, 'Value') == 0 ...
            && get(handles.tone11, 'Value') == 0 && get(handles.tone12, 'Value') == 0
        popup = msgbox('No target tones or non-target tones were selected');
        set(handles.startButton,'Enable','off')
    elseif get(handles.toneNT8, 'Value') == 0 && get(handles.toneNT7, 'Value') == 0 ...
            && get(handles.toneNT6, 'Value') == 0 && get(handles.toneNT5, 'Value') == 0 ...
            && get(handles.toneNT4, 'Value') == 0 && get(handles.toneNT3, 'Value') == 0 ...
            && get(handles.toneNT2, 'Value') == 0 && get(handles.toneNT1, 'Value') == 0 ...
            && get(handles.toneNT9, 'Value') == 0 && get(handles.toneNT10, 'Value') == 0 ...
            && get(handles.toneNT11, 'Value') == 0 && get(handles.toneNT12, 'Value') == 0 ... 
        popup = msgbox('No non-target tones were selected');
        set(handles.startButton,'Enable','off')
    elseif get(handles.tone8, 'Value') == 0 && get(handles.tone7, 'Value') == 0 ...
            && get(handles.tone6, 'Value') == 0 && get(handles.tone5, 'Value') == 0 ...
            && get(handles.tone4, 'Value') == 0 && get(handles.tone3, 'Value') == 0 ...
            && get(handles.tone2, 'Value') == 0 && get(handles.tone1, 'Value') == 0 ...
            && get(handles.tone9, 'Value') == 0 && get(handles.tone10, 'Value') == 0 ...
            && get(handles.tone11, 'Value') == 0 && get(handles.tone12, 'Value') == 0
        popup = msgbox('No target tones were selected');
        set(handles.startButton,'Enable','off')
    %if set params button gets pressed before levels get selected then a
    %pop up message will ask the person to select a tone level    
    elseif get(handles.level1,'Value') == 0 && get(handles.level2,'Value') == 0 ...
            && get(handles.level3,'Value') == 0 && get(handles.level4,'Value') == 0 ...
            && get(handles.level5,'Value') == 0 && get(handles.level6,'Value') == 0 ...
            && get(handles.level7,'Value') == 0
        popup = msgbox('No tone levels were selected');
        set(handles.startButton,'Enable','off')
    else
        % enables the "Start" button
        pause(1)
        set(handles.startButton,'Enable','on')
    end
    
    
end

%for habituation
if handles.phaseChoice == 1
    % enables the "Start" button
    set(handles.startButton,'Enable','on')
end

guidata(hObject,handles);

% --- Executes on button press in startButton, starts a device with the
% associated parameters that were set
function startButton_Callback(hObject, eventdata, handles)

guidata(hObject,handles);


% deletes raspi/matlab connection so other devices can be connected later
handles.rpi = [];

% disables the drop down menu to select new devices so that new parameters
% do not get saved until after the most recent device has already started 
% runing 
set(handles.piSelection,'Enable','off')
pause(.1)

% disables the "Speaker Calibration, "Test Water","Test Sound", and
% "Previous Params" buttons because the device selected is now in use,
% these will not be reeneabled until a new device is selected
set(handles.speakerCalibration,'Enable','off');
set(handles.waterTest,'Enable','off');
set(handles.testSound,'Enable','off');
set(handles.previousParams,'Enable','off');

% disables the "Start" button so it can't be used again until all new
% parameters are set
set(handles.startButton,'Enable','off');

% disables the "Set Params" button so it can't be used again until all new
% parameters are set
set(handles.setParams,'Enable','off');

% disables the tone checkboxes so they can't be used again until all new
% parameters are set
set(handles.tone1,'Enable','off');
set(handles.tone2,'Enable','off');
set(handles.tone3,'Enable','off');
set(handles.tone4,'Enable','off');
set(handles.tone5,'Enable','off');
set(handles.tone6,'Enable','off');
set(handles.tone7,'Enable','off');
set(handles.tone8,'Enable','off');
set(handles.tone9,'Enable','off');
set(handles.tone10,'Enable','off');
set(handles.tone11,'Enable','off');
set(handles.tone12,'Enable','off');
set(handles.toneNT1,'Enable','off');
set(handles.toneNT2,'Enable','off');
set(handles.toneNT3,'Enable','off');
set(handles.toneNT4,'Enable','off');
set(handles.toneNT5,'Enable','off');
set(handles.toneNT6,'Enable','off');
set(handles.toneNT7,'Enable','off');
set(handles.toneNT8,'Enable','off');
set(handles.toneNT9,'Enable','off');
set(handles.toneNT10,'Enable','off');
set(handles.toneNT11,'Enable','off');
set(handles.toneNT12,'Enable','off');
% resets all check boxes to unchecked
set(handles.tone1, 'Value', 0);
set(handles.tone2, 'Value', 0);
set(handles.tone3, 'Value', 0);
set(handles.tone4, 'Value', 0);
set(handles.tone5, 'Value', 0);
set(handles.tone6, 'Value', 0);
set(handles.tone7, 'Value', 0);
set(handles.tone8, 'Value', 0);
set(handles.tone9, 'Value', 0);
set(handles.tone10, 'Value', 0);
set(handles.tone11, 'Value', 0);
set(handles.tone12, 'Value', 0);
set(handles.toneNT1, 'Value', 0);
set(handles.toneNT2, 'Value', 0);
set(handles.toneNT3, 'Value', 0);
set(handles.toneNT4, 'Value', 0);
set(handles.toneNT5, 'Value', 0);
set(handles.toneNT6, 'Value', 0);
set(handles.toneNT7, 'Value', 0);
set(handles.toneNT8, 'Value', 0);
set(handles.toneNT9, 'Value', 0);
set(handles.toneNT10, 'Value', 0);
set(handles.toneNT11, 'Value', 0);
set(handles.toneNT12, 'Value', 0);

%disables options to select tone levels and resets them to unchecked status
set(handles.level1,'Enable','off')
set(handles.level2,'Enable','off')
set(handles.level3,'Enable','off')
set(handles.level4,'Enable','off')
set(handles.level5,'Enable','off')
set(handles.level6,'Enable','off')
set(handles.level7,'Enable','off')
set(handles.level1,'Value',0)
set(handles.level2,'Value',0)
set(handles.level3,'Value',0)
set(handles.level4,'Value',0)
set(handles.level5,'Value',0)
set(handles.level6,'Value',0)
set(handles.level7,'Value',0)
    
%disables silent trials option
set(handles.silentTrials,'Enable','off')
set(handles.silentTrials,'Value',0)


% resets the string for the phase selection drop down menu to back to the
% first option of "Training Phase:" and then disables the menu until a new
% device is selected
set(handles.phaseSelection, 'Value', 1);
set(handles.phaseSelection,'Enable','off');

%slight pause so the gui can disable everything
pause(.1)

% adds the selected/running devices to this vector to be used in displaying
% current devices and checking their status in the DataGraph Gui
handles.onDevices = [handles.onDevices; {char(handles.cageID(handles.piChoice))}];

% changes variable name so it can be saved and passed to the batch job as
% an argument
devicesFolder = handles.devicesFolder;

% shows in drop down menu that device is being used
handles.piSelection.String(handles.piChoice) = strcat(handles.piSelection.String(handles.piChoice), ' = In Use');

% Keeps start button off if no phase has been selected
if handles.phaseChoice == 0
    set(handles.startButton,'Enable','off')
end

% Starts the habituation function as a batch process
if handles.phaseChoice == 1
    disp('start habituation function')
    %saves the batch job information to be used later to delete the job
    handles.job{handles.piChoice} = batch(@habituation,1,{devicesFolder});
    
    %displays the phase that the device is running in the correct tab
    set(handles.phaseDisplay(length(handles.onDevices)),'visible','on','String',['Phase:',{'Habituation'}]);
    
    % the text box for target tones displays which tones were
    % selected for the associated device in the correct tab, should be none
    set(handles.targetDisplay(length(handles.onDevices)),'visible','on','String',['Target Tones:',{'none'}]);
    
    % the text box for nontarget tones displays which tones were
    % selected for the associated device in the correct tab, should be none
    set(handles.nontargetDisplay(length(handles.onDevices)),'visible','on','String',['Nontarget Tones:',{'none'}]);
 
end

% Starts the shaping function as a batch process
if handles.phaseChoice == 2
    disp('start shaping function')
    %saves the batch job information to be used later to delete the job
    handles.job{handles.piChoice} = batch(@shaping,1,{devicesFolder});
    
    %displays the phase that the device is running in the correct tab
    set(handles.phaseDisplay(length(handles.onDevices)),'visible','on','String',['Phase:',{'Shaping'}]);
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay(length(handles.onDevices)),'visible','on','String',['Target Tones:', {handles.target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab, should be none
    set(handles.nontargetDisplay(length(handles.onDevices)),'visible','on','String',['Nontarget Tones:',{'none'}]);
 
end

% Starts the detection function as a batch process
if handles.phaseChoice == 3
    disp('start detection function')
    %saves the batch job information to be used later to delete the job
    handles.job{handles.piChoice} = batch(@detection,1,{devicesFolder});
    
    %displays the phase that the device is running in the correct tab
    set(handles.phaseDisplay(length(handles.onDevices)),'visible','on','String',['Phase:',{'Detection'}]);
   
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay(length(handles.onDevices)),'visible','on','String',['Target Tones:', {handles.target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab, should be none
    set(handles.nontargetDisplay(length(handles.onDevices)),'visible','on','String',['Nontarget Tones:',{'none'}]);
 
end

% Starts the discrimination function as a batch process
if handles.phaseChoice == 4
    disp('start discrimination function')
    %saves the batch job information to be used later to delete the job
    handles.job{handles.piChoice} = batch(@discrimination,1,{devicesFolder});
    
    %displays the phase that the device is running in the correct tab
    set(handles.phaseDisplay(length(handles.onDevices)),'visible','on','String',['Phase:',{'Discrimination'}]);
    
    % the text box for target tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.targetDisplay(length(handles.onDevices)),'visible','on','String',['Target Tones:', {handles.target}]);
    
    % the text box for nontarget tones displays which ones were
    % selected for the associated device in the correct tab
    set(handles.nontargetDisplay(length(handles.onDevices)),'visible','on','String',['Nontarget Tones:', {handles.nontarget}]);
end

% Changes the name of the tab to the hostname of the associated device
set(handles.AllTabs(length(handles.onDevices)),'Title',char(handles.onDevices(length(handles.onDevices))));
pause(.1)

%renames variable so the information can be saved to a file to be checked
%by the DataGraph Gui
onDevices = handles.onDevices;
save([devicesFolder,'currentDevices.mat'],'onDevices')

%enables the "Stop" and "Pause All" buttons
set(handles.stopButton,'Enable','on')
set(handles.pauseButton,'Enable','on')

%checks to see if the PiParams.mat file has been moved from the Devices
%folder into the folder that corresponds to the device that was just
%started. As soon as that file is moved, the drop down Pi Selection menu
%becomes available and the user can select a new device
checkParams = exist(handles.filename);
while checkParams == 2
    checkParams = exist(handles.filename);
end
set(handles.piSelection,'Enable','on')

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);


% --- Executes on button press in stopButton, stops the device whose tab is
% selected
function stopButton_Callback(hObject, eventdata, handles)
%variable used when deleting device/job
deleteDevice = 0;

% so the stop button can't be hit more than once while stopping a program
set(handles.stopButton,'Enable','off')
set(handles.pauseButton,'Enable','off')
pause(.1)

guidata(hObject,handles);

% renames tabgroup variable for ease in calling tab names
piTabs = handles.tgroup;

% turns cell of device names into strings for comparison
onDevices = string(handles.onDevices);

% finds which tab is currently selected when the stop button was pressed
handles.stopPi = string(piTabs.SelectedTab.Title);

% finds the position of the device name in the cageID matrix, this number
% is used find the folder that holds that device's performance and stop
% files
handles.file = find(strcmp(onDevices,handles.stopPi));


% if there is a match, quit variable becomes 1 and is then saved to a file.
% That file is loaded into the phase functions every cycle to see if the
% quit variable is still 0. Once the quit variable becomes 1, then the
% function will go through one more trial before stopping
if handles.file > 0
    intervalStop = 1;
    quit = 1;
    save([handles.devicesFolder, char(onDevices(handles.file)) '/stopButton.mat'],'quit','intervalStop','-append')
    
    %keeps track of how long the stop function has been trying to stop the
    %deivce
    g = tic;
    
    % this loop deletes the device from the list of running devices as well
    % as deletes the job from the job manager list once the data file has
    % been correctly saved

    while quit == 1 && deleteDevice == 0
        %the rest of the loop will not occur until the performance.mat
        %file no longer exists (the data is saved to a different file when
        %the phase is stopped)
        checkFile = exist([handles.devicesFolder, char(onDevices(handles.file)) '/performance.mat']);
        if checkFile == 0
            
            %deletes current device from the list of running devices
            x = find(strcmp(char(onDevices(handles.file)),handles.cageID));
            handles.onDevices(handles.file) = [];
            
            % saving new variables
            guidata(hObject,handles);
            % deleting batch job of the device that was just stopped
            delete(handles.job{x});
            
            % this resets the variable quit back to 0 so the function runs the next
            % time it is called
            quit = 0;
            intervalStop = 0;
            save([handles.devicesFolder, char(onDevices(handles.file)) '/stopButton.mat'],'quit','intervalStop','-append');
            
            % takes off the " = In Use" portion next to the device name and IP address
            % in the drop down menu to indicate that the device is now available
            device = find(strcmp(handles.cageID,handles.stopPi));
            changeName = char(handles.piSelection.String(device));
            changeName((length(changeName)-8):length(changeName)) = [];
            handles.piSelection.String(device) = cellstr(changeName);
            
            %resets the tabs to only show devices that are running, 
            %essentially deletes the display of the device that is being 
            %stopped
            if handles.file < (length(handles.onDevices) + 1)
                for z = handles.file:length(handles.onDevices)
                    set(handles.AllTabs(z),'Title',char(handles.onDevices(z)));
                    set(handles.phaseDisplay(z),'visible','on','String',handles.phaseDisplay(z+1).String);
                    
                    % the text box for target tones displays which ones were
                    % selected for the associated device in the correct tab
                    set(handles.targetDisplay(z),'visible','on','String',handles.targetDisplay(z+1).String);
                    
                    % the text box for nontarget tones displays which ones were
                    % selected for the associated device in the correct tab
                    set(handles.nontargetDisplay(z),'visible','on','String',handles.nontargetDisplay(z+1).String);
                end
            end
            set(handles.targetDisplay(length(handles.onDevices) + 1),'visible','off','String','Target Tones: ');
            set(handles.AllTabs(length(handles.onDevices) + 1),'Title',['Pi' num2str(length(handles.onDevices) + 1)]);
            set(handles.phaseDisplay(length(handles.onDevices) + 1),'visible','off','String','Phase: ');
            set(handles.nontargetDisplay(length(handles.onDevices) + 1),'visible','off','String','Nontarget Tones: ');
            
        end
        
        %if the loop has been running for 60 seconds, the device has likely
        %errored. Once 60s has passed, a dialogue box will pop up asking
        %the user whether the device is still running. If the device is not
        %running then the user will select "Device has failed", if the
        %device is still running then the user will select "Device is
        %running" and will go through another cycle of the stop function
        if toc(g) > 60
            stopQuestion = questdlg('This device is taking awhile to stop. Check to see if the device is still running.','Stop Error','Device is running','Device has failed','Device is running');
            switch stopQuestion
                case 'Device is running'
                    g = tic;
                case 'Device has failed'
                    set(handles.terminateButton,'visible','on','Enable','on')
                    deleteDevice = 1;
            end
        end
    end

%the stop button will stop the device that has its tab selected, if a tab
%is selected that does not have a running device displayed then this
%message will pop up
else
    popup = msgbox('Device not selected. Select tab with device you wish to stop.');
    handles.Stop = 0;
end

%renames variable so data can be saved to a file
onDevices = handles.onDevices;
save([handles.devicesFolder,'currentDevices.mat'],'onDevices')

%checks to see if more than one device is still running after the current
%device is stopped, if so, then the "Stop" button and "Pause All" buttons
%are reenabled. If not, then the IP scanning functions are made available
%again
if ~isempty(handles.onDevices)
    set(handles.stopButton,'Enable','on');
    set(handles.pauseButton,'Enable','on');
else
    set(handles.scanIP,'Enable','on');
    set(handles.upperLimit,'Enable','on');
    set(handles.lowerLimit,'Enable','on');
end

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);

% --- Executes on button press in waterTest, triggers water to be released
% in order to test for functionality
function waterTest_Callback(hObject, eventdata, handles)

%if the toggle button is pressed, the raspberry pi is told to turn on the
%solenoid in order to deliver water
if handles.waterTest.Value == 1
    writeDigitalPin(handles.rpi, 13, 1)
end
%if the toggle button is pressed again to stop the water, the raspberry pi
%is told to turn off the solenoid stopping water delivery
if handles.waterTest.Value == 0
    writeDigitalPin(handles.rpi, 13, 0)
end

guidata(hObject,handles);

% --- Executes on button press in previousParams, loads the parametesr that
% were set for the most recent device that was started
function previousParams_Callback(hObject, eventdata, handles)

guidata(hObject,handles);
%tries to load previous parameters, of no previous parameters have been
%saved then a message pops up saying as such
pp = 0;
try
    load([handles.devicesFolder, char(handles.cageID(handles.piChoice)), '\PreviousPiParams.mat'])
    pp = 1;
catch
    pp = msgbox('Parameters have not previously been set in this file path. Please input the parameters you wish to run.');
end

%if previous parameters were successfully loaded then they are input into
%the gui
if pp == 1
    handles.target = targetChoice;
    handles.nontarget = nontargetChoice;
    handles.phaseChoice = phaseChoice;
    handles.toneLevel = toneLevelChoice;
    %sets the silent trials radio button value to 0 or 1 depending on the
    %previously saved parameters
    set(handles.silentTrials,'Value',silentTrials);
    
    % this shows which phase was previously selected
    if handles.phaseChoice == 1 %habituation
        set(handles.phaseSelection, 'Value', 2);
    else
        % Target tone checkboxes are enabled for all other phases
        set(handles.tone1,'Enable','on')
        set(handles.tone2,'Enable','on')
        set(handles.tone3,'Enable','on')
        set(handles.tone4,'Enable','on')
        set(handles.tone5,'Enable','on')
        set(handles.tone6,'Enable','on')
        set(handles.tone7,'Enable','on')
        set(handles.tone8,'Enable','on')
        set(handles.tone9,'Enable','on')
        set(handles.tone10,'Enable','on')
        set(handles.tone11,'Enable','on')
        set(handles.tone12,'Enable','on')
        
        if handles.phaseChoice == 2 %shaping
            set(handles.phaseSelection, 'Value', 3);
        end
        if handles.phaseChoice == 3 %detection
            set(handles.phaseSelection, 'Value', 4);
            
            %enables option to select tone level
            set(handles.level1,'Enable','on')
            set(handles.level2,'Enable','on')
            set(handles.level3,'Enable','on')
            set(handles.level4,'Enable','on')
            set(handles.level5,'Enable','on')
            set(handles.level6,'Enable','on')
            set(handles.level7,'Enable','on')
            
            %enables silent trials option
            set(handles.silentTrials,'Enable','on')
        end
        
        if handles.phaseChoice == 4 %discrimination
            set(handles.phaseSelection, 'Value', 5);
            
            % Nonarget tone checkboxes are enabled
            set(handles.toneNT1,'Enable','on')
            set(handles.toneNT2,'Enable','on')
            set(handles.toneNT3,'Enable','on')
            set(handles.toneNT4,'Enable','on')
            set(handles.toneNT5,'Enable','on')
            set(handles.toneNT6,'Enable','on')
            set(handles.toneNT7,'Enable','on')
            set(handles.toneNT8,'Enable','on')
            set(handles.toneNT9,'Enable','on')
            set(handles.toneNT10,'Enable','on')
            set(handles.toneNT11,'Enable','on')
            set(handles.toneNT12,'Enable','on')
            
            %enables option to select tone level
            set(handles.level1,'Enable','on')
            set(handles.level2,'Enable','on')
            set(handles.level3,'Enable','on')
            set(handles.level4,'Enable','on')
            set(handles.level5,'Enable','on')
            set(handles.level6,'Enable','on')
            set(handles.level7,'Enable','on')
            
            %enables silent trials option
            set(handles.silentTrials,'Enable','on')
        end
    end
    
    %checks the boxes that were checked in the previous parameters that
    %were set and keeps the unchecked boxes unchecked for target tones,
    %nontarget tones, and tone levels
    if ismember(1,handles.target)
        set(handles.tone1, 'Value', 1);
    else
        set(handles.tone1,'Value',0);
    end
    if ismember(1.4,handles.target)
        set(handles.tone2, 'Value', 1);
    else
        set(handles.tone2,'Value',0);
    end
    if ismember(2,handles.target)
        set(handles.tone3, 'Value', 1);
    else
        set(handles.tone3,'Value',0);
    end
    if ismember(2.8,handles.target)
        set(handles.tone4, 'Value', 1);
    else
        set(handles.tone4,'Value',0);
    end
    if ismember(4,handles.target)
        set(handles.tone5, 'Value', 1);
    else
        set(handles.tone5,'Value',0);
    end
    if ismember(5.7,handles.target)
        set(handles.tone6, 'Value', 1);
    else
        set(handles.tone6,'Value',0);
    end
    if ismember(8,handles.target)
        set(handles.tone7, 'Value', 1);
    else
        set(handles.tone7,'Value',0);
    end
    if ismember(11.3,handles.target)
        set(handles.tone8, 'Value', 1);
    else
        set(handles.tone8,'Value',0);
    end
    if ismember(16,handles.target)
        set(handles.tone9, 'Value', 1);
    else
        set(handles.tone9,'Value',0);
    end
    if ismember(22.6,handles.target)
        set(handles.tone10, 'Value', 1);
    else
        set(handles.tone10,'Value',0);
    end
    if ismember(32,handles.target)
        set(handles.tone11, 'Value', 1);
    else
        set(handles.tone11,'Value',0);
    end
    if ismember(45.3,handles.target)
        set(handles.tone12, 'Value', 1);
    else
        set(handles.tone12,'Value',0);
    end
    if ismember(1,handles.nontarget)
        set(handles.toneNT1, 'Value', 1);
    else
        set(handles.toneNT1,'Value',0);
    end
    if ismember(1.4,handles.nontarget)
        set(handles.toneNT2, 'Value', 1);
    else
        set(handles.toneNT2,'Value',0);
    end
    if ismember(2,handles.nontarget)
        set(handles.toneNT3, 'Value', 1);
    else
        set(handles.toneNT3,'Value',0);
    end
    if ismember(2.8,handles.nontarget)
        set(handles.toneNT4, 'Value', 1);
    else
        set(handles.toneNT4,'Value',0);
    end
    if ismember(4,handles.nontarget)
        set(handles.toneNT5, 'Value', 1);
    else
        set(handles.toneNT5,'Value',0);
    end
    if ismember(5.7,handles.nontarget)
        set(handles.toneNT6, 'Value', 1);
    else
        set(handles.toneNT6,'Value',0);
    end
    if ismember(8,handles.nontarget)
        set(handles.toneNT7, 'Value', 1);
    else
        set(handles.toneNT7,'Value',0);
    end
    if ismember(11.3,handles.nontarget)
        set(handles.toneNT8, 'Value', 1);
    else
        set(handles.toneNT8,'Value',0);
    end
    if ismember(16,handles.nontarget)
        set(handles.toneNT9, 'Value', 1);
    else
        set(handles.toneNT9,'Value',0);
    end
    if ismember(22.6,handles.nontarget)
        set(handles.toneNT10, 'Value', 1);
    else
        set(handles.toneNT10,'Value',0);
    end
    if ismember(32,handles.nontarget)
        set(handles.toneNT11, 'Value', 1);
    else
        set(handles.toneNT11,'Value',0);
    end
    if ismember(45.3,handles.nontarget)
        set(handles.toneNT12, 'Value', 1);
    else
        set(handles.toneNT12,'Value',0);
    end
    if ismember(0,handles.toneLevel)
        set(handles.level1,'Value',1)
    else
        set(handles.level1,'Value',0)
    end
    if ismember(-5,handles.toneLevel)
        set(handles.level2,'Value',1)
    else
        set(handles.level2,'Value',0)
    end
    if ismember(-10,handles.toneLevel)
        set(handles.level3,'Value',1)
    else
        set(handles.level3,'Value',0)
    end
    if ismember(-15,handles.toneLevel)
        set(handles.level4,'Value',1)
    else
        set(handles.level4,'Value',0)
    end
    if ismember(-20,handles.toneLevel)
        set(handles.level5,'Value',1)
    else
        set(handles.level5,'Value',0)
    end
    if ismember(-25,handles.toneLevel)
        set(handles.level6,'Value',1)
    else
        set(handles.level6,'Value',0)
    end
    if ismember(-30,handles.toneLevel)
        set(handles.level7,'Value',1)
    else
        set(handles.level7,'Value',0)
    end
    % "Set Params" button is enabled
    set(handles.setParams,'Enable','on');
end

% allows the variables defined in this function to be used in other functions
guidata(hObject,handles);

% --- Executes on button press in terminateButton, if a device takes too
% long to stop, this button will pop up to essentially force quit the
% device
%The only difference between this loop and the one for the stop function is
%that this function does not wait for the file performance.mat to stop
%existing, this function is for the case that something happened before the
%phase could resave its data to a different file name. Therefore this just
%stops the device. The device will resave that data to a new file the next
%time it runs. The terminate function allows the GUI to not crash if a
%device stops working.
function terminateButton_Callback(hObject, eventdata, handles)
%ask the user if they want to terminate the device
terminateDevice = 0;
tdbox = questdlg('Are you sure you want to terminate the device?','Terminate Device','Yes','No','No');
switch tdbox
    case 'Yes'
        terminateDevice = 1;
    case 'No'
        terminateDevice = 0;
end

%reassigns the data in handles.onDevices to a non-handles variable to make
%it easier to deal with
onDevices = handles.onDevices;

if terminateDevice == 1
    %deletes device from variable that keeps track of current devices
    x = find(strcmp(char(onDevices(handles.file)),handles.cageID));
    handles.onDevices(handles.file) = [];
    
    % saving new variables
    guidata(hObject,handles);
    % deleting batch job
    delete(handles.job{x});
    
    % this resets the variable quit back to 0 so the function runs the next
    % time it is called
    quit = 0;
    intervalStop = 0;
    save([handles.devicesFolder, char(onDevices(handles.file)) '/stopButton.mat'],'quit','intervalStop','-append');
    % takes off the " = In Use" portion next to the device name and IP address
    % in the drop down menu to indicate that the device is now available
    device = find(strcmp(handles.cageID,handles.stopPi));
    changeName = char(handles.piSelection.String(device));
    changeName((length(changeName)-8):length(changeName)) = [];
    handles.piSelection.String(device) = cellstr(changeName);
    
    %resets the tabs to only show devices that are running, 
    %essentially deletes the display of the device that is being 
    %stopped
    if handles.file < (length(handles.onDevices) + 1)
        for z = handles.file:length(handles.onDevices)
            set(handles.AllTabs(z),'Title',char(handles.onDevices(z)));
            set(handles.phaseDisplay(z),'visible','on','String',handles.phaseDisplay(z+1).String);
            
            % the text box for target tones displays which ones were
            % selected for the associated device in the correct tab
            set(handles.targetDisplay(z),'visible','on','String',handles.targetDisplay(z+1).String);
            
            % the text box for nontarget tones displays which ones were
            % selected for the associated device in the correct tab
            set(handles.nontargetDisplay(z),'visible','on','String',handles.nontargetDisplay(z+1).String);
        end
    end
    set(handles.targetDisplay(length(handles.onDevices) + 1),'visible','off','String','Target Tones: ');
    set(handles.AllTabs(length(handles.onDevices) + 1),'Title',['Pi' num2str(length(handles.onDevices) + 1)]);
    set(handles.phaseDisplay(length(handles.onDevices) + 1),'visible','off','String','Phase: ');
    set(handles.nontargetDisplay(length(handles.onDevices) + 1),'visible','off','String','Nontarget Tones: ');
end

%saves the new list of currently running devices
onDevices = handles.onDevices;
save([handles.devicesFolder,'currentDevices.mat'],'onDevices')

%if no devices are running anymore then the IP scanning functions are
%available and the "Stop" button and "Pause All" button are not available
if isempty(handles.onDevices)
    set(handles.scanIP,'Enable','on');
    set(handles.upperLimit,'Enable','on');
    set(handles.lowerLimit,'Enable','on');
    set(handles.stopButton,'Enable','off');
    set(handles.pauseButton,'Enable','off');
end

%disables the "Terminate" button and makes it invisible again
set(handles.terminateButton,'visible','off','Enable','off')

guidata(hObject,handles);

% --- Executes on button press in speakerCalibration., calibrates the
% speakers ***you will need a microphone for this
function speakerCalibration_Callback(hObject, eventdata, handles)
%reassigns these values in order to use them as arguments for the
%SpeakerCalibration function
rpi = handles.rpi;
filepath = [handles.fileLocation.String,'\'];

%asks user for confirmation of speaker calibration
scbox = questdlg('Are you sure you want to calibrate the speaker on this device?','Calibrate Speaker','Yes','No','No');
ultra = 0;
switch scbox
    case 'Yes'
        scbox = questdlg([{'Would you like to calibrate ultrasounds?'};{'Ensure you have a 192k sound card'};],'Audio Frequency Range','Yes','No','No');
        switch scbox
            case 'Yes'
                ultra = 1;
            case 'No'
                ultra = 0;
        end
        SpeakerCalibration(rpi,filepath,ultra)
    case 'No'
end

        

guidata(hObject,handles);

% --- Executes on button press in pauseButton, pauses all currently running
% devices, very useful when cleaning/changing cages and refilling the water
% bottle
function pauseButton_Callback(hObject, eventdata, handles)

%saves this variable to the stopButton.mat file so the next trial each
%device runs, it will download this new variable and enter its pause loop
pauseProgram = 1;
for z = 1:length(handles.onDevices)
    save([handles.devicesFolder, char(handles.onDevices(z)) '/stopButton.mat'],'pauseProgram','-append');
end

%disables the "Pause All" button and makes it invisible
set(handles.pauseButton,'Enable','off','Visible','off')
%enables the "Resume All" button and makes it visible
set(handles.resumeButton,'Enable','on','Visible','on')
%disables the Pi Selection drop down menu and the "Stop" button
set(handles.piSelection,'Enable','off')
set(handles.stopButton,'Enable','off')

guidata(hObject,handles);

% --- Executes on button press in resumeButton, resumes all currently
% paused devices
function resumeButton_Callback(hObject, eventdata, handles)


%saves this variable to the stopButton.mat file so that each paused device
%will exit its pause loop
pauseProgram = 0;
for z = 1:length(handles.onDevices)
    save([handles.devicesFolder, char(handles.onDevices(z)) '/stopButton.mat'],'pauseProgram','-append');
end

%Enables and makes visible the "Pause All" button
set(handles.pauseButton,'Enable','on','Visible','on')
%Disables and makes inviisible the "Resume All" button
set(handles.resumeButton,'Enable','off','Visible','off')
%Enables the Pi Selection drop down menu and the "Stop" button
set(handles.stopButton,'Enable','on')
set(handles.piSelection,'Enable','on')

guidata(hObject,handles);

% --- Executes on button press in testSound, tests the sound on the
% selected device to make sure the speaker is functioning properly
function testSound_Callback(hObject, eventdata, handles)

%while the button is pressed (press once), a 1kHz sound will play. The file
%is 4.5 seconds so the loop will occur about every 6 seconds
while handles.testSound.Value == 1
    system(handles.rpi,'sudo mplayer /home/tonebox/Tone_1kHz_0dB.wav');
    disp('sound has played')
    pause(1)
end

guidata(hObject,handles);
