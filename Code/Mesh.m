clear variables;
close all;

ptCloud_L = pcread('ptCloud_L.ply');
ptCloud_R = pcread('ptCloud_R.ply');
ptCloudOut = pcread('ptCloudOut.ply');

%% 3D point cloud to 3D Mesh
res=10;
[TM_L,tri_L,a_L]=createMesh(ptCloud_L,res);
[TM_R,tri_R,a_R]=createMesh(ptCloud_R,res);
[TM,tri,a]=createMesh(ptCloudOut,res);

%% Assess the quality of the grid
th_angle = pi/6;
not_accept=find(min(a,[],2)<th_angle);
acc = 1-length(not_accept)/length(a);

%% Surface mesh
% depth = 8;
% mesh_L = pc2surfacemesh(ptCloud_L,"poisson",depth);
% surfaceMeshShow(mesh_L)
% mesh_R = pc2surfacemesh(ptCloud_R,"poisson",depth);
% surfaceMeshShow(mesh_R)
% mesh = pc2surfacemesh(ptCloudOut,"poisson",depth);
% surfaceMeshShow(mesh)