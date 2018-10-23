% FileName: PoseEstimation.m
% Description: Estimate an object's pose by 6 markers and reconstruct in 3D
% Author: F. Zhang and C.Z. Li
% Data last modified: 2nd Feb 2018
% Camera parameters loading
cameraParams = load('/Users/apple/Desktop/Pose_estimation/cameraParams.mat');  

% cam = webcam;
% Image processing & pose estimation frame by frame
for h = 1:246 

    disp(['No.' num2str(h) ' frame is being processed!']);

    % % Data pathes setup
    name = strcat(num2str(h),'.jpg');
    rootPath   = '/Users/apple/Desktop/Pose_estimation/input/';
    picPath    = '/Users/apple/Desktop/Pose_estimation/output/';
    posePath   = '../Pose_estimation/pose/';
    path       = [rootPath, name];
    outputPath = [picPath,  name];
    pose       = [posePath, name];

    % Image loading and pre-processing
    img     = imread(path);                % Image loading
    imgGray = rgb2gray(img);                % RGB --> Gray
    level   = graythresh(imgGray);          % Binarize threshold
    imgBW   = imbinarize(imgGray, level);   % Image binarizing
    imgBW1  = 1 - imgBW;                    % Invert
    B       = strel('square', 7);           % Dilate structuring element
    imgBW   = imdilate(imgBW1, B);          % Image dilate

    % figure(1);imshow(img);
    % figure(2);imshow(imgBW)
    
    % Markers finding
    [labeled, numObjects] = bwlabel(imgBW, 4);
    graindata = regionprops(labeled, 'all');
    ii = 0;   % marker counter
    for i = 1:numObjects
        % Fliter regionprops by area threshold 2200 ~ 8000
        if ( graindata(i).Area > 2200 && graindata(i).Area < 8000 ) 
            ii = ii + 1;
            markerCentroids(ii,:,h) = graindata(i).Centroid; % 
        end
    end
    % Markers found check (By # of regions found)
    if ii > 6
        warning('Some extra markers are found');
    elseif ii <6
        warning('The number of found markers is less than 6');
    end

    % Pose estimation by frame
    % Marker coordinates in world reference system
    % The origin of WCS is defined as the letf-lower cornor of the object
    objectMarkerCoordinatesinWRS = [74.25, 105, 0; 111.33, 52.5, 0;
                                    111.33, 157.5, 0; 185.67, 52.5, 0;
                                    185.67, 157.5, 0; 222.75 , 105, 0];
               
    % Launch MATLAB estimateWorldCameraPose()
    % Return camera's orientation and location
    [worldCameraOrientation(:,:,h),worldCameraLocation(:,:,h)] = ...
        estimateWorldCameraPose(markerCentroids(1:6,:,h),...
        objectMarkerCoordinatesinWRS, cameraParams.cameraParams, 'MaxReprojectionError',10);
    
    % Camera pose --> Object pose
    object.R(:,:,h) = worldCameraOrientation(:,:,h)'; 
    object.t(:,:,h) = - worldCameraLocation(:,:,h) * worldCameraOrientation(:,:,h)';
    
    % Derive Euler angles from orientation matrix
    eul(:,:,h)      = rotm2eul(object.R(:,:,h),'XYZ');
    eul_deg(:,:,h)  = eul(:,:,h) * 180 / pi;
    
    % Derive marker coordinates in camera reference system
    worldPointsHomo =  [objectMarkerCoordinatesinWRS, ones(6,1)];
    R = [object.R(:,:,h), object.t(:,:,h)'; 0, 0, 0, 1];
    objectMarkerCoordinatesinCRS(:, :, h) = R * worldPointsHomo';
    
    % % 3D reconstruction
    originofWCSinCCS = R * [0 0 0 1]';
    TreDimReconstruct(objectMarkerCoordinatesinCRS(:, :, h),originofWCSinCCS, outputPath, object.R(:, :, h));
end