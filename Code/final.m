clear variables;
close all;

%% Load parameters and read images
load('cameraParameters.mat');
load('stereoParameters.mat');

im_L = imread("subject1_Left_1.jpg");
im_M = imread("subject1_Middle_1.jpg");
im_R = imread("subject1_Right_1.jpg");

% im_L = imread("subject4_Left_1255.jpg");
% im_M = imread("subject4_Middle_1255.jpg");
% im_R = imread("subject4_Right_1255.jpg");

%% Compensate for non-linear lens deformation
undistortim_L = undistortImage(im_L,cameraParams_Left1);
undistortim_M = undistortImage(im_M,cameraParams_Middle1);
undistortim_R = undistortImage(im_R,cameraParams_Right1);

%% Colour normalization
[normalizedim_L,normalizedim_M,normalizedim_R] = normalization(undistortim_L,undistortim_M,undistortim_R);

%% Extract background
% Define parameters for canny and structure elements
% Parameters for subject1
canny_params = {
    [0.01 0.14];
    [0.01 0.12];
    [0.01 0.09]
};

strel_params = {
    {'disk', 19};
    {'disk', 15};
    {'disk', 15}
};

% Parameters for subject4
% canny_params = {
%     [0.01 0.070];
%     [0.01 0.080];
%     [0.01 0.050]
% };
% 
% strel_params = {
%     {'disk', 8};
%     {'disk', 8};
%     {'disk', 9}
% };

[BG_L,BG_M,BG_R] = extractBG(normalizedim_L,normalizedim_M,normalizedim_R,canny_params,strel_params);

%% Rectify stereo images
[rectifiedim_L, rectifiedim_M1, reprojection_LM] = rectifyStereoImages(undistortim_L, undistortim_M, stereoParams_LM,OutputView='full');
[rectifiedim_M2, rectifiedim_R, reprojection_MR] = rectifyStereoImages(undistortim_M, undistortim_R, stereoParams_MR,OutputView='full');
[rectifiedim_BGL, rectifiedim_BGM1] = rectifyStereoImages(BG_L, BG_M, stereoParams_LM,OutputView='full');
[rectifiedim_BGM2, rectifiedim_BGR] = rectifyStereoImages(BG_M, BG_R, stereoParams_MR,OutputView='full');

figure;
subplot(2,2,1)
imshow(rectifiedim_M1);
title('rectifiedim_M1')
subplot(2,2,2)
imshow(rectifiedim_L);
title('rectifiedim_L')
subplot(2,2,3)
imshow(rectifiedim_M2);
title('rectifiedim_M2')
subplot(2,2,4)
imshow(rectifiedim_R);
title('rectifiedim_R')

figure;
subplot(2,2,1)
imshow(rectifiedim_BGM1);
title('background_M1')
subplot(2,2,2)
imshow(rectifiedim_BGL);
title('background_L')
subplot(2,2,3)
imshow(rectifiedim_BGM2);
title('background_M2')
subplot(2,2,4)
imshow(rectifiedim_BGR);
title('background_R')

stereoim = stereoAnaglyph(rectifiedim_L,rectifiedim_M1);
figure;
imshow(stereoim);

%% Stereo matching
% For subject1
% Left & Middle
disparityMap_LM = disparitySGM(rgb2gray(rectifiedim_L), rgb2gray(rectifiedim_M1),'DisparityRange',[240,352],'UniquenessThreshold',0);
disparityMap_LM = disparityMap_LM .* rectifiedim_BGL;
[disparityMap_L,unreliable_L] = removeUnreliable(disparityMap_LM);
figure;
imshow(disparityMap_L, [240,352]);
colormap jet; 
colorbar;

% Middle & Right
disparityMap_MR = disparitySGM(rgb2gray(rectifiedim_M2), rgb2gray(rectifiedim_R),'DisparityRange',[240,352],'UniquenessThreshold',0);
disparityMap_MR = disparityMap_MR .* rectifiedim_BGM2;
[disparityMap_R,unreliable_R] = removeUnreliable(disparityMap_MR);
figure;
imshow(disparityMap_R, [240,352]);
colormap jet; 
colorbar;

% For subject4
% Left & Middle
% disparityMap_LM = disparitySGM(rgb2gray(rectifiedim_L), rgb2gray(rectifiedim_M1),'DisparityRange',[336,464],'UniquenessThreshold',0);
% disparityMap_LM = disparityMap_LM .* rectifiedim_BGL;
% [disparityMap_L,unreliable_L] = removeUnreliable(disparityMap_LM,rectifiedim_L);
% figure;
% imshow(disparityMap_L, [336,464]);
% colormap jet; 
% colorbar;

% Middle & Right
% disparityMap_MR = disparitySGM(rgb2gray(rectifiedim_M2), rgb2gray(rectifiedim_R),'DisparityRange',[336,464],'UniquenessThreshold',0);
% disparityMap_MR = disparityMap_MR .* rectifiedim_BGM2;
% [disparityMap_R,unreliable_R] = removeUnreliable(disparityMap_MR,rectifiedim_M2);
% figure;
% imshow(disparityMap_R, [336,464]);
% colormap jet; 
% colorbar;

%% Generate 3D point cloud
% Left & Middle
xyzPoints_L = reconstructScene(disparityMap_L,reprojection_LM);
ptCloud_L = pointCloud(xyzPoints_L,'Color',rectifiedim_L);
figure;
pcshow(ptCloud_L);xlabel('X'); ylabel('Y'); zlabel('Z');
% pcwrite(ptCloud_L, 'ptCloud_L.ply', 'PLYFormat', 'binary');

% Middle & Right
xyzPoints_R = reconstructScene(disparityMap_R,reprojection_MR);
ptCloud_R = pointCloud(xyzPoints_R,'Color',rectifiedim_M2);
figure;
pcshow(ptCloud_R);xlabel('X'); ylabel('Y'); zlabel('Z');
% pcwrite(ptCloud_R, 'ptCloud_R.ply', 'PLYFormat', 'binary');

%% Merge 3D point clouds
% Downsample
ptCloud_L_ds = pcdownsample(ptCloud_L, 'random',.2);
ptCloud_R_ds = pcdownsample(ptCloud_R, 'random',.2);

% Transform the pose of ptCloud_L_ds to align it with ptCloud_R_ds
[tform,movingReg] = pcregistericp(ptCloud_L_ds, ptCloud_R_ds, 'Extrapolate', true);
figure;
pcshow(movingReg);xlabel('X'); ylabel('Y'); zlabel('Z');

% Merge two 3D point clouds
ptCloudOut = pcmerge(movingReg,ptCloud_R_ds,1);
figure();
pcshow(ptCloudOut);xlabel('X'); ylabel('Y'); zlabel('Z');
% pcwrite(ptCloudOut, 'ptCloudOut.ply', 'PLYFormat', 'binary');