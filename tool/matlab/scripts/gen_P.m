% generate_P
clc;
close all;

addpath('../thirdParty/yaml');
addpath('../utils/interface');

if ~exist('raw_data_root')
  raw_data_root = '/media/bingo/SSD/camera_lidar_fusion/sanheyi/20200817/fusion';
end

if ~exist('lidar2GroundConfig')
  lidar2GroundConfig = 'lidar2ground_extrinsic.yml';
end

if ~exist('camera2LidarConfig')
  camera2LidarConfig = 'camera2lidar_extrinisc.yml';
end

lidar2GroundConfigFilename = sprintf('%s/%s', raw_data_root, lidar2GroundConfig);

camera2LidarConfigFilename = sprintf('%s/%s', raw_data_root, camera2LidarConfig);

[lidar2GroundMat, ~] = loadLidarGroundYaml(lidar2GroundConfigFilename);
[camera2LidarMat, CameraMat, ~, ~, ~] = loadLidarCameraYaml(camera2LidarConfigFilename);

lidar2camera = inv(camera2LidarMat) * inv(lidar2GroundMat);
P = CameraMat * lidar2camera(1:3, :);