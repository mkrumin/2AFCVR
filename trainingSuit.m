function varargout = trainingSuit(varargin)
% TRAININGSUIT MATLAB code for trainingSuit.fig
%      TRAININGSUIT, by itself, creates a new TRAININGSUIT or raises the existing
%      singleton*.
%
%      H = TRAININGSUIT returns the handle to a new TRAININGSUIT or the handle to
%      the existing singleton*.
%
%      TRAININGSUIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAININGSUIT.M with the given input arguments.
%
%      TRAININGSUIT('Property','Value',...) creates a new TRAININGSUIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trainingSuit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trainingSuit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trainingSuit

% Last Modified by GUIDE v2.5 30-Oct-2012 11:41:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trainingSuit_OpeningFcn, ...
                   'gui_OutputFcn',  @trainingSuit_OutputFcn, ...
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


% --- Executes just before trainingSuit is made visible.
function trainingSuit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trainingSuit (see VARARGIN)


% Choose default command line output for trainingSuit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trainingSuit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trainingSuit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in animal_popupmenu.
function animal_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to animal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns animal_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from animal_popupmenu

val=get(hObject, 'Value');
if val==1
    animal='000';
else
    allStrings=get(hObject, 'String');
    stringSelected=allStrings{val};
    ind=strfind(stringSelected, ' ');
    animal=stringSelected((ind(end)+1):end);
end
handles.animal=animal;
guidata(hObject, handles);
loadAnimalSetup(hObject, handles);


% --- Executes during object creation, after setting all properties.
function animal_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

fid=fopen('animalslist.txt');
tline = fgetl(fid);
while ischar(tline)
    strings=get(hObject, 'String');
    if ~iscell(strings)
        strings={strings};
    end
    len=length(strings);
    strings{len+1, 1}=tline;
    set(hObject, 'String', strings);
    disp(tline)
    tline = fgetl(fid);
end

fclose(fid);


% --- Executes on selection change in task_popupmenu.
function task_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to task_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns task_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task_popupmenu


% --- Executes during object creation, after setting all properties.
function task_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in go_pushbutton.
function go_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to go_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function params_uitable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to params_uitable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global EXP
EXP=setExperimentPars;

updateTable(hObject, EXP);


% --- Executes when entered data in editable cell(s) in params_uitable.
function params_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to params_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

global EXP
data = get(hObject,'Data');
editedPar=data{eventdata.Indices(1), 1}; 
newValue=data{eventdata.Indices(1),eventdata.Indices(2)};
EXP.(editedPar)=newValue;
% EXP=setfield(EXP, editedPar, newValue);

function loadAnimalSetup(hObject, handles)

global EXP
animal=handles.animal;
hTable=handles.params_uitable;
hAxes=handles.map_axes;
if isempty(animal)
    cla(hAxes);
    set(hTable, 'Enable', 'off');
    EXP=setExperimentPars;
else
    ballDir=['C:\data\ball\', animal, filesep];
    set(hTable, 'Enable', 'on');
    if isdir(ballDir)
        dataFolders=dir(ballDir);
        folderNames=[];
        for i=1:length(dataFolders)
            if length(dataFolders(i).name)==10 % yyyy-mm-dd formatted folders only
                folderNames=[folderNames; dataFolders(i).name];
            end
        end
        folderNames=sortrows(folderNames);
        theFolder=[ballDir, folderNames(end, :)];
        fileList=dir([theFolder, filesep, '*allTrials.mat']);
        if ~isempty(fileList)
            % loading the last one in the list, ideally need to load the
            % latest
            file2load=fileList(end).name;
            data=load([theFolder, filesep, file2load]);
            EXP=data.EXP;
        else
            EXP=setExperimentPars;
        end
        
    else
        EXP=setExperimentPars;
    end
end
updateTable(hTable, EXP);
drawMap(hAxes, EXP);

function updateTable(hObject, EXP)

allFields=fieldnames(EXP);
nPars=length(allFields);
expParams=cell(nPars, 2);
for iPar=1:nPars
%     fprintf('%s = %d\n', allFields{iPar}, getfield(EXP, allFields{iPar}));
    expParams{iPar, 1}=allFields{iPar};
    expParams{iPar, 2}=EXP.(allFields{iPar});
end
set(hObject, 'Data', expParams);

function drawMap(hObject, EXP)

axes(hObject);
x1=EXP.corridorWidth/2;
x2=EXP.roomWidth/2;
z1=EXP.roomLength-EXP.corridorWidth;
z2=EXP.roomLength;

cla;
xs=[-x1; -x1; -x2; -x2; x2; x2; x1; x1; -x1];
zs=[0; z1; z1; z2; z2; z1; z1; 0; 0];
plot(xs, zs, 'k', 'LineWidth', 2);
set(hObject, 'Visible', 'off');
set(hObject, 'DataAspectRatio', [1 1 1]);
