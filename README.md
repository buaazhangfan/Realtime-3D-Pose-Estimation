## Single Camera based Realtime 3D Pose Estimation
+ 097457 Vision Based 3D Measurement
+ Politecnico di Milano, Fall 2017
+ Author: F. Zhang and C.Z. Li

------
+ Our project aims to building a system to estimate 3D Pose (6 DOFs) of an geometry-given object in space with only one camera using ***Solve P3P Algorithm***.

+ In most cases, if you want to get the 3d coordinates of an object you need two cameras to get images and then calculate the 3d coordinates. However, when you get the geometry imformation of an object you can do this with only one camera.

+ This project consists of camera calibration, image acquistion, image processing, image segmentation, pose estimation and simple 3D reconstruction.

Overview:

<div align=center><img src="https://github.com/buaazhangfan/Realtime-3D-Pose-Estimation/blob/master/pics/theory.png" width = 30% height = 50% div align=center />


<div align=center><img src="https://github.com/buaazhangfan/Realtime-3D-Pose-Estimation/blob/master/pics/process.png" width = 30% height = 50% div align=center />

------
<div align=left>

1. folder `calibration/` contains chessboard images to calibrate the camera using Zhang's calibration method.
	
2. folder `ChessBoard/` contains C++ files to generate a chessborad image at any size.

3. folder `input/` contains the input images

4. folder `output/` contains the output 3d pose reconstruction result

------
<div align=left>

+ The `TreDimReconstruct.m` calculate the output result of input images.
+ The `PoseEstimationV1.m` is the core files that doing image processing and pose estimation calculations.
+ The `img_acq.m` is the user interface of our project which intergrated all functions.

------
Remember to calibrate the camera first to get the camera-parameter matrix.

<div align=center><img src="https://github.com/buaazhangfan/Realtime-3D-Pose-Estimation/blob/master/pics/calibration.png" width = 30% height = 50% div align=center />

------

Final Result

<div align=center><img src="https://github.com/buaazhangfan/Realtime-3D-Pose-Estimation/blob/master/pics/result.png" width = 70% height = 70% div align=center />

User interface


<div align=center><img src="https://github.com/buaazhangfan/Realtime-3D-Pose-Estimation/blob/master/pics/final.png" width = 70% height = 70% />



