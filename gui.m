function varargout = gui(varargin)
%GUI MATLAB code file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('Property','Value',...) creates a new GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to gui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI('CALLBACK') and GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 23-Mar-2020 08:03:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.jpg');
 
if ~isequal(filename,0)
    Img = imread(fullfile(pathname,filename));
    axes(handles.axes1)
    imshow(Img)
else
    return
end
 
handles.Img = Img;
guidata(hObject, handles)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Img = handles.Img;

% Color-Based Segmentation Using K-Means Clustering
% rgbtolab
cform = makecform('srgb2lab');
lab = applycform(Img,cform);
 
handles.lab = lab;
guidata(hObject, handles)

% segmentasi citra
Img = handles.Img;
lab = handles.lab;

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
 
nColors = 2;
[cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',3);
 
pixel_labels = reshape(cluster_idx,nrows,ncols);
 
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
 
for k = 1:nColors
    color = Img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end
 
area_cluster1 = sum(find(pixel_labels==1));
area_cluster2 = sum(find(pixel_labels==2));
 
[~,cluster_min] = min([area_cluster1,area_cluster2]);
 
Img_bw = (pixel_labels==cluster_min);
Img_bw = imfill(Img_bw,'holes');
Img_bw = bwareaopen(Img_bw,50);
 
mobil = Img;
R = mobil(:,:,1);
G = mobil(:,:,2);
B = mobil(:,:,3);
R(~Img_bw) = 0;
G(~Img_bw) = 0;
B(~Img_bw) = 0;
mobil_rgb = cat(3,R,G,B);
 
handles.Img_bw = Img_bw;
guidata(hObject, handles)

% Citra biner
Img_bw = handles.Img_bw;
 
stats = regionprops(Img_bw,'Area','Perimeter','Eccentricity');
area = stats.Area;
perimeter = stats.Perimeter;
metric = 4*pi*area/(perimeter^2);
eccentricity = stats.Eccentricity;
 
ciri_bentuk = cell(2,2);
ciri_bentuk{1,1} = 'Metric';
ciri_bentuk{2,1} = 'Eccentricity';
ciri_bentuk{1,2} = num2str(metric);
ciri_bentuk{2,2} = num2str(eccentricity);
 
handles.ciri_bentuk = ciri_bentuk;
guidata(hObject, handles)

% Citra greyscale
Img_bw = handles.Img_bw;
ciri_bentuk = handles.ciri_bentuk;
 
Img_gray = rgb2gray(Img);
Img_gray(~Img_bw) = 0;
 
pixel_dist = 1;
GLCM = graycomatrix(Img_gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
Contrast = mean(stats.Contrast);
Correlation = mean(stats.Correlation);
Energy = mean(stats.Energy);
Homogeneity = mean(stats.Homogeneity);
 
ciri_total = cell(6,2);
ciri_total{1,1} = ciri_bentuk{1,1};
ciri_total{1,2} = ciri_bentuk{1,2};
ciri_total{2,1} = ciri_bentuk{2,1};
ciri_total{2,2} = ciri_bentuk{2,2};
ciri_total{3,1} = 'Contrast';
ciri_total{4,1} = 'Correlation';
ciri_total{5,1} = 'Energy';
ciri_total{6,1} = 'Homogeneity';
ciri_total{3,2} = num2str(Contrast);
ciri_total{4,2} = num2str(Correlation);
ciri_total{5,2} = num2str(Energy);
ciri_total{6,2} = num2str(Homogeneity);
 
handles.ciri_total = ciri_total;
guidata(hObject, handles)

% Hasil
load ciri_database
ciri_total = handles.ciri_total;
 
ciri = zeros(1,6);
for i = 1:6
    ciri(i) = str2double(ciri_total{i,2});
end
 
[num,~] = size(ciri_database);
 
dist = zeros(1,num);
for n = 1:num
    data_base = ciri_database(n,:);
    jarak = sum((data_base-ciri).^2).^0.5;
    dist(n) = jarak;
end
 
[~,id] = min(dist);
 
if isempty(id)
    set(handles.edit1,'String','Unknown')
else
    switch id
        case {1,2,3,4,5,6,7,8,9,10}
            tingkat = 'Bus';
        case {11,12,13,14,15,16,17,18,19,20}
            tingkat = 'Minibus';
        case {21,22,23,24,25,26,27,28,29,30}
            tingkat = 'Sedan';
        case {31,32,33,34,35,36,37,38,39,40}
            tingkat = 'Truk';
        otherwise
            tingkat = 'Gambar tidak dapat dideteksi';
    end
    set(handles.edit1,'String',tingkat)
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
 
set(handles.text2,'String',[])
set(handles.edit1,'String', [])
 
