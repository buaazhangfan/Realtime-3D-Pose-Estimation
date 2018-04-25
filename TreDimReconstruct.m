% FileName: TreDimReconstruct.m
% Description: implement 3D reconstruction
% Author: F. Zhang and C.Z. Li
% Data last modified: 2nd Feb 2018

function TreDimReconstruct(objectMarkerCoordinatesinCRS, originofWRSinCRS, savePath, objectOrientationinCRS)
    % Input:
    %     objectMarkerCoordinatesinCRS: marker coordinates in camera reference system
    %     originofWRSinCRS: origin coordinate of world reference system in camera ref system
    %     savePath: path of saving reconstructed figure
    %     objectOrientationinCRS: object orientation in camera ref system

    % Put marker points into right order for visualization
    objectMarkerCoordinatesinCRS = objectMarkerCoordinatesinCRS(1:3, :);
    objectMarkerCoordinatesinCRS(:, [3 4]) = objectMarkerCoordinatesinCRS(:, [4 3]);
    objectMarkerCoordinatesinCRS(:, [4 6]) = objectMarkerCoordinatesinCRS(:, [6 4]);
    objectMarkerCoordinatesinCRS = [objectMarkerCoordinatesinCRS, objectMarkerCoordinatesinCRS(:, 1)];

    % Visualization
    % Connect markers to stimulate the location of the object
    plot3(objectMarkerCoordinatesinCRS(1, :), objectMarkerCoordinatesinCRS(2, :),...
        objectMarkerCoordinatesinCRS(3, :), 'b-', 'MarkerSize', 50, 'LineWidth', 10); hold on;
    % Plot the origin of the world coordinate system
    plot3(originofWRSinCRS(1, 1), originofWRSinCRS(2, 1),...
        originofWRSinCRS(3, 1), 'r*', 'MarkerSize', 50); hold on;
    % Plot the point of real camera
    plot3(0, 0, 0, 'r*'); hold on;
    text(0,0,-100,'camera'); hold on;
    % Plot a camera to stimulate the orientation of the object
    plotCamera('Size', 20, 'Orientation', objectOrientationinCRS, 'Location', originofWRSinCRS(1:3, :)');
    % Graph setup
    axis([-300, 30, -200, 200, -100, 1000]);
    grid on;
    view(11, -65);
    saveas(gcf, savePath);
    hold off;
end