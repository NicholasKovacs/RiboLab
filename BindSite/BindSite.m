function varargout = BindSite(varargin)
% BINDSITE MATLAB code for BindSite.fig
%      BINDSITE, by itself, creates a new BINDSITE or raises the existing
%      singleton*.
%
%      H = BINDSITE returns the handle to a new BINDSITE or the handle to
%      the existing singleton*.
%
%      BINDSITE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINDSITE.M with the given input arguments.
%
%      BINDSITE('Property','Value',...) creates a new BINDSITE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BindSite_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BindSite_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BindSite

% Last Modified by GUIDE v2.5 20-Apr-2012 18:09:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BindSite_OpeningFcn, ...
    'gui_OutputFcn',  @BindSite_OutputFcn, ...
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


% --- Executes just before BindSite is made visible.
function BindSite_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BindSite (see VARARGIN)

% Choose default command line output for BindSite
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if ~isdeployed()
    set(handles.debug_button,'Visible','on')
end

% UIWAIT makes BindSite wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BindSite_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function about_show_Callback(hObject, eventdata, handles)
% hObject    handle to about_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ErrorBoxGUI('title','Missing Feature','string',['This feature does not exist.',...
%         ' Yet.'])
h=AboutBindSite();
% --------------------------------------------------------------------
function file_open_Callback(hObject, eventdata, handles)
% hObject    handle to file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result=get(handles.output,'UserData');
if ~isempty(result)
    file=result.File;
else
    file='.\';
end
[FileName,PathName] = uigetfile({'*.csv';'*.txt';'*.*'},'Select the PDB List File',file);
if ~isequal(FileName,0) && ~isequal(PathName,0)
    set(handles.FilesProcessedText,'Visible','off')
    set(handles.FilesLoadedText,'Visible','off')
    
    file=fullfile(PathName,FileName);
    [path,name]=fileparts(file);
    
    textfile=fileread(file);
    
    IDlist=regexp(textfile,'[\w]+','match');
    numIDs=length(IDlist);
    Structures(numIDs,1)=PDBentry();
    %     h=PleaseWait();
    numFiles=length(IDlist);
    set(handles.FilesLoadedText,'String',sprintf('%d out of %d files loaded.',0,numFiles))
    set(handles.FilesLoadedText,'Visible','on')
    drawnow()
    
    for i=1:numFiles
        ID=fullfile(path,IDlist{i});
        if exist([ID,'.mat'],'file') == 2
            load([ID,'.mat'])
        elseif exist([ID,'.pdb'],'file') == 2
            pdb=importdata([ID,'.pdb']);
            save([ID,'.mat'],'pdb')
        else
            pdb = getpdb(IDlist{i}, 'ToFile', [ID,'.pdb']);
            save([ID,'.mat'],'pdb')
        end
        Structures(i)=PDBentry(pdb.Title);
        Structures(i).PDBfromStruct(pdb,IDlist{i})
        %Structures(i).Process()
        set(handles.FilesLoadedText,'String',sprintf('%d out of %d files loaded.',i,numFiles))
        drawnow()
    end
    result.Structures=Structures;
    result.File=file;
    result.IDlist=IDlist;
    
    set(handles.output,'UserData',result)
    %     delete(h)
    %     set(handles.FilesLoadedText,'String',sprintf('%i files have been loaded.',numIDs))
    
    
    if strcmp(get(handles.auto_mode,'checked'),'on')
        set(handles.gobutton,'Visible','off')
        BindSite('gobutton_Callback',handles.gobutton,[],guidata(hObject))
        BindSite('save_pml_menu_Callback',handles.save_pml_menu,[],guidata(hObject))
    else
       set(handles.gobutton,'Visible','on')
       set(handles.SettingsPanel,'Visible','on')
    end
end


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in killerbutton.
function killerbutton_Callback(hObject, eventdata, handles)
% hObject    handle to killerbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ErrorBoxGUI('title','Missing Feature','string',['This feature does not exist.',...
    ' Yet.'])


% --- Executes on button press in gobutton.
function gobutton_Callback(hObject, eventdata, handles)
% hObject    handle to gobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result=get(handles.output,'UserData');
% h=PleaseWait();
Contact_Cutoff=str2double(get(handles.ContactCutoffEdit,'String'));
ATFc=get(handles.AtomTypeFilterPopup,'String');
AtomFilterType=ATFc{get(handles.AtomTypeFilterPopup,'Value')};
famenu=get(handles.FilterAsp_Menu,'String');
FilterAsp=famenu{get(handles.FilterAsp_Menu,'Value')};

result.cads=CADS({result.Structures.ID});
numModels=length(result.IDlist);
MapUC=cell(numModels,1);
set(handles.FilesProcessedText,'String',sprintf('%d out of %d files processed.',0,numModels))
set(handles.FilesProcessedText,'Visible','on')
drawnow()

for Pro_ind=1:numModels
    result.cads(Pro_ind).AddPDB(result.Structures(Pro_ind),1);
    result.cads(Pro_ind).Subsets={};
    [MapUC{Pro_ind}]=MapContacts(result.cads(Pro_ind).PDB(1),'single',[],...
        Contact_Cutoff,[],'AtomFilterType',{AtomFilterType,'anything'},'FilterAsp',FilterAsp);
    
    result.cads(Pro_ind).Results(1).AddContactMapFiltered(MapUC{Pro_ind},'nofilter')
    switch AtomFilterType
        case 'Magnesium'
            objectname='Mg';
        case 'Calcium'
            objectname='Ca';
    end
    result.cads(Pro_ind).Settings.PyMOL.ObjectNames={result.cads(Pro_ind).Name};
    result.cads(Pro_ind).Settings.PyMOL.Target={result.cads(Pro_ind).Name};
    result.cads(Pro_ind).Settings.PyMOL.CoreNames={result.cads(Pro_ind).Name};
    
    result.cads(Pro_ind).Species={objectname}; %odd but works for now
    
    set(handles.FilesProcessedText,'String',sprintf('%d out of %d files processed.',Pro_ind,numModels))
    drawnow()
end

% KeepFilter=FilterMap(result.cads,'ContactCutoff',Contact_Cutoff);
% assignin('base','RLLSET',result)
set(handles.output,'UserData',result)
set(handles.save_pml_menu,'Enable','on')
% set(handles.save_pdb_menu,'Enable','on')


% delete(h)



function ContactCutoffEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ContactCutoffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ContactCutoffEdit as text
%        str2double(get(hObject,'String')) returns contents of ContactCutoffEdit as a double


% --- Executes during object creation, after setting all properties.
function ContactCutoffEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContactCutoffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AtomTypeFilterPopup.
function AtomTypeFilterPopup_Callback(hObject, eventdata, handles)
% hObject    handle to AtomTypeFilterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AtomTypeFilterPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AtomTypeFilterPopup


% --- Executes during object creation, after setting all properties.
function AtomTypeFilterPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AtomTypeFilterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function save_pml_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_pml_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
result=get(handles.output,'UserData');
% h=PleaseWait();

numModels=length(result.cads);
[pdb_path,DataSetName]=fileparts(result.File);
File_Names=cell(numModels,1);
for Pro_ind=1:numModels
    File_Names{Pro_ind}=WriteMapToPyMOL(result.cads(Pro_ind),'PDBfile',fullfile(pdb_path,...
        [result.cads(Pro_ind).PDB(1).ID,'.pdb']),'SavePDB',get(handles.SavePDBmodeCheck,'Value'));
end
MergePML(DataSetName,[File_Names{:}],pdb_path)
% drawnow()



% --------------------------------------------------------------------
function save_pdb_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_pdb_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SavePDBmodeCheck.
function SavePDBmodeCheck_Callback(hObject, eventdata, handles)
% hObject    handle to SavePDBmodeCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SavePDBmodeCheck


% --- Executes on button press in debug_button.
function debug_button_Callback(hObject, eventdata, handles)
% hObject    handle to debug_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dbstop if naninf
x=42/0;


% --- Executes on button press in FilterAsp_Menu.
function FilterAsp_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to FilterAsp_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FilterAsp_Menu


% --------------------------------------------------------------------
function settings_menu_Callback(hObject, eventdata, handles)
% hObject    handle to settings_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function auto_mode_Callback(hObject, eventdata, handles)
% hObject    handle to auto_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(hObject,'checked')
    case 'on'
        set(hObject,'checked','off')
        %set(handles.SettingsPanel,'Visible','off')
        
    case 'off'
        set(hObject,'checked','on')
        set(handles.SettingsPanel,'Visible','on')
        
end
