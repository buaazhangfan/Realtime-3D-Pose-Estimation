function varargout = img_acq(varargin)
% IMG_ACQ MATLAB code for PoseEstimationV2
%      IMG_ACQ, by itself, creates a new IMG_ACQ or raises the existing
%      singleton*.
%
%      H = IMG_ACQ returns the handle to a new IMG_ACQ or the handle to
%      the existing singleton*.
%
%      IMG_ACQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_ACQ.M with the given input arguments.
%
%      IMG_ACQ('Property','Value',...) creates a new IMG_ACQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_acq_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_acq_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_acq

% Last Modified by GUIDE v2.5 31-Jan-2018 14:35:13

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_acq_OpeningFcn, ...
                   'gui_OutputFcn',  @img_acq_OutputFcn, ...
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


% --- Executes just before img_acq is made visible.
function img_acq_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_acq (see VARARGIN)

% Choose default command line output for img_acq
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes img_acq wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = img_acq_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%  Main Function  %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

% Set save root for image
rootpath = 'realtime/';

% Camera parameters loading
cameraParams = load('cameraParams.mat');

%% Image loading and pre-processing
% Image acquision from video using webcam on Macbook(macOS High Sierra)
vid = videoinput('macvideo', 1, 'YCbCr422_1280x720');
set(vid, 'ReturnedColorSpace', 'RGB');
imageRes = vid.VideoResolution;
nBands   = vid.NumberOfBands;
himage   = image(zeros(imageRes(2),imageRes(1),nBands),'parent',handles.axes5);
preview(vid, himage);

% Collecting images frame by frame and processing them in real time
DOFAll = [];
for i = 1:50                            % i is the number of images 
    pause(0.18);
    
%% Image acquisition
    imgOriginal = getsnapshot(vid);             
    name = [num2str(i) '.jpg'];
    outputpath = [rootpath, name];
    imwrite(imgOriginal, outputpath);
    axes(handles.axes1);
    imshow(imgOriginal);
    
%% Image pre-processing
    % Process the image in order to remove the background and therefore to allow a good thresholding
    imgGray    = rgb2gray(imgOriginal);
    imgGrayInv = 255 - imgGray;
    imgEroded  = imerode(imgGrayInv, strel('disk',80));
    imgDilated = imdilate(imgEroded, strel('disk',80));
    background = imgDilated;              % Get the background of image in order to have a better binary image
    imgFront   = imsubtract(imgGrayInv, background); 
    imgFront   = imadjust(imgFront);
    % Create a binary version of the image
    level      = graythresh(imgFront);
    imgBinarized = imbinarize(imgFront, level*1.2);
    imgBinarized = imclose(imgBinarized, strel('disk', 5));
    
    % Markers extraction
    [labeled,numObjects] = bwlabel(imgBinarized, 4);
    graindata  = regionprops(labeled, 'all');
    axes(handles.axes6);
    imshow(labeled);
    ii = 0;
    for eachObj = 1 : numObjects
        % Extracting markers satisfying eccentricity and area conditions
        eccentricityCond = 0.8;
        areaCond = 3000;
        if(graindata(eachObj).Eccentricity < eccentricityCond && graindata(eachObj).Area > areaCond)
            ii = ii + 1;
            markerCentroids(ii,:) = graindata(eachObj).Centroid;  % set region centroids as markers
        end
    end
    
    % Markers found check (By # of regions found)
    if ii > 6
        warning('Some extra markers are found');
    elseif ii <6
        warning('The number of found markers is less than 6');
    end

    % Mark six markers found
    for k = 1:6
        name = sprintf('%2d', k);
        text(markerCentroids(k,1), markerCentroids(k,2), name);
        hold on;
    end
    
 %% Pose estimation
    % Marker coordinates in world reference system(WRS)
    % The origin of WCS is defined as the letf-upper cornor of the object
    objectMarkerCoordinatesinWRS = [74.25, 105, 0; 111.33, 52.5, 0; 111.33, 157.5, 0;
                                   185.67, 52.5, 0; 185.67, 157.5, 0; 222.75, 105, 0];
    % Launch MATLAB estimateWorldCameraPose()
    % Return camera's orientation and location in WRS
    [worldOrientation(:,:),worldLocation(:,:)] = estimateWorldCameraPose(markerCentroids(1:6,:),...
        objectMarkerCoordinatesinWRS,cameraParams.cameraParams,'MaxReprojectionError',20);
    % Camera pose --> Object pose
    object.R(:,:) = worldOrientation(:,:)'; 
    object.t(:,:) = -worldLocation(:,:) * worldOrientation(:,:)';
    % Derive Euler angles from camera orientation matrix
    eul(:,:) = rotm2eul(object.R(:,:),'XYZ'); 
    eul_deg(:,:) = eul(:,:) * 180 / pi;
    
    % Object position and orientation
    position.x = object.t(1,1);
    position.y = object.t(1,2);
    position.z = object.t(1,3);
    
    if eul_deg(1,1) > 0     % euler.x
        euler.x = eul_deg(1,1) - 180;
    elseif eul_deg(1,1) < 0
        euler.x = eul_deg(1,1) + 180;
    end
    euler.y = eul_deg(1,2);
    euler.z = eul_deg(1,3);
    DOFAll = [DOFAll; position.x position.y position.z euler.x euler.y euler.z];
    save DOFAll.mat DOFAll;
    
    % Display
    set(handles.edit1,'String',num2str(position.x));
    set(handles.edit3,'String',num2str(position.y));
    set(handles.edit4,'String',num2str(position.z));
    set(handles.edit5,'String',num2str(euler.x));
    set(handles.edit6,'String',num2str(euler.y));
    set(handles.edit7,'String',num2str(euler.z));
end

delete(vid);
clear;

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.



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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
