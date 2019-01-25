## Single Camera based Realtime 3D Pose Estimation
+ 097457 Vision Based 3D Measurement
+ Politecnico di Milano, Fall 2017
+ Author: F. Zhang and C.Z. Li

--
+ Our project aims to building a system to estimate 3D Pose (6 DOFs) of an geometry-given object in space with only one camera using ***Solve P3P Algorithm***.

+ In most cases, if you want to get the 3d coordinates of an object you need two cameras to get images and then calculate the 3d coordinates. However, when you get the geometry imformation of an object you can do this with only one camera.

+ This project consists of camera calibration, image acquistion, image processing, image segmentation, pose estimation and simple 3D reconstruction.

--
1. folder `calibration/` contains chessboard images to calibrate the camera using Zhang's calibration method.
	
2. folder `ChessBoard/` contains C++ files to generate a chessborad image at any size.





