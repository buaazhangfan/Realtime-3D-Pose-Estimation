
%% Image acquisition
    imgOriginal = imread('PPTImg/3.jpg');             
    
% Image pre-processing
    % Process the image in order to remove the background and therefore to allow a good thresholding
    imgGray    = rgb2gray(imgOriginal);
    imgGrayInv = 255 - imgGray;
    imgEroded  = imerode(imgGrayInv, strel('disk',80));
    imgDilated = imdilate(imgEroded, strel('disk',80));
    imgBackground = imgDilated;              % Get the background of image in order to have a better binary image
    imgFront   = imsubtract(imgGrayInv, imgBackground); 
    imgFrontAdjust   = imadjust(imgFront);
    % Create a binary version of the image
    level      = graythresh(imgFrontAdjust);
    imgBinarized = imbinarize(imgFrontAdjust, level*1.2);
    imgBinarized = imclose(imgBinarized, strel('disk', 5));

figure(1);
imshow(imgOriginal);
title('Original Image', 'fontsize', 20);
print('PPTImg/imgOriginal.png', '-dpng', '-r300');

figure(2);
imshow(imgGray);
title('Grayscale Image', 'fontsize', 20);
print('PPTImg/imgGray.png', '-dpng', '-r300');

figure(3);
imshow(imgGrayInv);
title('Invert GrayScale Image', 'fontsize', 20);
print('PPTImg/imgGrayInv.png', '-dpng', '-r300');

figure(4);
imshow(imgEroded);
title('Eroded Image', 'fontsize', 20);
print('PPTImg/imgEroded.png', '-dpng', '-r300');

figure(5);
imshow(imgDilated);
title('Dilated Image', 'fontsize', 20);
print('PPTImg/imgDilated.png', '-dpng', '-r300');

figure(6);
imshow(imgFront);
title('Front Image', 'fontsize', 20);
print('PPTImg/imgFront.png', '-dpng', '-r300');

figure(7);
imshow(imgFrontAdjust);
title('High Contrast Front Image', 'fontsize', 20);
print('PPTImg/imgFrontAdjust.png', '-dpng', '-r300');

figure(8);
imshow(imgBinarized);
title('Binarized Image', 'fontsize', 20);
print('PPTImg/imgBinarized.png', '-dpng', '-r300');

close all;