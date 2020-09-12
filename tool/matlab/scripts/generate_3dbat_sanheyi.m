% generate the dataset for annotation of sanheyi

clc;
close all;

addpath('../thirdParty/yaml');
addpath('../utils/interface');
addpath('../utils/linefit_ground_segmentation/func');
addpath('../utils/linefit_ground_segmentation/mex');

if ~exist('raw_data_root')
  raw_data_root = '/media/bingo/SSD/camera_lidar_fusion/sanheyi/20200817/fusion';
end

if ~exist('raw_images_path')
  raw_images_path = 'cam_front_undistorted';
end

if ~exist('raw_points_path')
  raw_points_path = 'lidar2';
end

if ~exist('lidar2GroundConfig')
  lidar2GroundConfig = 'lidar2ground_extrinsic.yml';
end

if ~exist('groundRemoveConfig')
  groundRemoveConfig = 'groundRemoveConfig.yml';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('annotation_data_root')
  annotation_data_root = '/media/bingo/SSD/annotation/sanheyi/20200817';
end

if ~exist('annotation_images_path')
  annotation_images_path = 'images/CAM_FRONT';
end

if ~exist('annotation_points_path')
  annotation_points_path = 'pointclouds';
end

if ~exist('annotation_points_without_ground_path')
  annotation_points_without_ground_path = 'pointclouds_without_ground';
end

if ~exist('annotation_annotations_path')
  annotation_annotations_path = 'annotations/LIDAR_TOP';
end

if ~exist('start_index')
  start_index = 372;
end

if ~exist('end_index')
  end_index = 473;
end

if ~exist('skip_num')
  skip_num = 5;
end

supportImageFormat = {'.jpg', '.png', '.jpeg', '.tiff'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
raw_images_dir = sprintf('%s/%s', raw_data_root, raw_images_path);
raw_points_dir = sprintf('%s/%s', raw_data_root, raw_points_path);

annotation_images_dir = sprintf('%s/%s', annotation_data_root, annotation_images_path);
annotation_points_dir = sprintf('%s/%s', annotation_data_root, annotation_points_path);
annotation_points_without_ground_dir = sprintf('%s/%s', annotation_data_root, annotation_points_without_ground_path);
annotation_annotations_dir = sprintf('%s/%s', annotation_data_root, annotation_annotations_path);

annotation_filename = sprintf('%s/%s', annotation_data_root, 'filename.txt');

params_config_file = sprintf('%s/%s', raw_data_root, groundRemoveConfig);
if ~exist(params_config_file,'file')
    return;
end

params = YAML.read(params_config_file);
ground_removal_params = struct();
ground_removal_params.linefit_seg_r_min = params.linefit_seg_r_min;
ground_removal_params.linefit_seg_r_max = params.linefit_seg_r_max;
ground_removal_params.linefit_seg_n_bins = params.linefit_seg_n_bins;
ground_removal_params.linefit_seg_n_segments = params.linefit_seg_n_segments;
ground_removal_params.linefit_seg_max_dist_to_line = params.linefit_seg_max_dist_to_line;
ground_removal_params.linefit_seg_max_slope = params.linefit_seg_max_slope;
ground_removal_params.linefit_seg_max_fit_error = params.linefit_seg_max_fit_error;
ground_removal_params.linefit_seg_long_threshold = params.linefit_seg_long_threshold;
ground_removal_params.linefit_seg_max_long_height = params.linefit_seg_max_long_height;
ground_removal_params.linefit_seg_max_start_height = params.linefit_seg_max_start_height;
ground_removal_params.linefit_seg_sensor_height = params.linefit_seg_sensor_height;
ground_removal_params.linefit_seg_line_search_angle = params.linefit_seg_line_search_angle;
ground_removal_params.linefit_seg_n_threads = params.linefit_seg_n_threads;

linefitGroundSegmentParams = struct();
linefitGroundSegmentParams.r_min_square = double(ground_removal_params.linefit_seg_r_min * ground_removal_params.linefit_seg_r_min);
linefitGroundSegmentParams.r_max_square = double(ground_removal_params.linefit_seg_r_max * ground_removal_params.linefit_seg_r_max);
linefitGroundSegmentParams.n_bins = double(ground_removal_params.linefit_seg_n_bins);
linefitGroundSegmentParams.n_segments = double(ground_removal_params.linefit_seg_n_segments);
linefitGroundSegmentParams.max_dist_to_line = double(ground_removal_params.linefit_seg_max_dist_to_line);
linefitGroundSegmentParams.max_slope = double(ground_removal_params.linefit_seg_max_slope);
linefitGroundSegmentParams.max_error_square = double(ground_removal_params.linefit_seg_max_fit_error * ground_removal_params.linefit_seg_max_fit_error);
linefitGroundSegmentParams.long_threshold = double(ground_removal_params.linefit_seg_long_threshold);
linefitGroundSegmentParams.max_long_height = double(ground_removal_params.linefit_seg_max_long_height);
linefitGroundSegmentParams.max_start_height = double(ground_removal_params.linefit_seg_max_start_height);
linefitGroundSegmentParams.sensor_height = double(ground_removal_params.linefit_seg_sensor_height);
linefitGroundSegmentParams.line_search_angle = double(ground_removal_params.linefit_seg_line_search_angle);
linefitGroundSegmentParams.n_threads = double(ground_removal_params.linefit_seg_n_threads);
linefitGroundSegmentParams.leveling = false;
linefitGroundSegmentParams.levelingPreset = false;

% load the leveling parameters
lidar2GroundConfigFilename = sprintf('%s/%s', raw_data_root, lidar2GroundConfig);
[lidar2GroundMat, ~] = loadLidarGroundYaml(lidar2GroundConfigFilename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the directory for the annotations
if ~exist(annotation_images_dir)
  command = sprintf('mkdir -p %s', annotation_images_dir);
  system(command);
end

if ~exist(annotation_points_dir)
  command = sprintf('mkdir -p %s', annotation_points_dir);
  system(command);
end

if ~exist(annotation_points_without_ground_dir)
  command = sprintf('mkdir -p %s', annotation_points_without_ground_dir);
  system(command);
end

if ~exist(annotation_annotations_dir)
  command = sprintf('mkdir -p %s', annotation_annotations_dir);
  system(command);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get number of images for this dataset
nimages = 0;
imageFilenamesId = [];

% get all the image filenames
AllImageFiles = dir([raw_images_dir '/*.*']);
for i = 1 : length(AllImageFiles)
  % ignore the folder
  if ~(AllImageFiles(i).isdir)
    % get the filename extenntion
    [~, id, ext] = fileparts(AllImageFiles(i).name);
    if ismember(ext, supportImageFormat)
      nimages = nimages + 1;
      imageFilenamesId = [imageFilenamesId str2num(id)];
    end
  end
end

fid = fopen(annotation_filename, 'w');

index = start_index: skip_num : end_index;
index_num = length(index);

for i = 1 : index_num
  cur_index = imageFilenamesId(index(i));
  % read the image from the raw images directory
  cur_image = imread(sprintf('%s/%06d.png', raw_images_dir, cur_index));
  % save the image to annotation directory
  imwrite(cur_image, sprintf('%s/%06d.jpg', annotation_images_dir, cur_index));
  % read pointcloud, leveling the pointcloud and remove the ground points
  cur_pc = pcread(sprintf('%s/%06d.pcd', raw_points_dir, cur_index));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % leveling the points
  cur_points_xyz = cur_pc.Location;
  cur_points_xyz_hom = [cur_points_xyz ones(size(cur_points_xyz, 1), 1)];
  cur_points_xyz_leveled_hom = (lidar2GroundMat * cur_points_xyz_hom')';
  cur_points_xyz_leveled = cur_points_xyz_leveled_hom(:, 1:3);
  cur_pc_leveled = pointCloud(single(cur_points_xyz_leveled), 'Intensity', single(cur_pc.Intensity));

  % write the leveled points to ascii encoding style
  pcwrite(cur_pc_leveled, sprintf('%s/%06d.pcd', annotation_points_dir, cur_index), 'Encoding', 'ascii');

  % remove the ground points
  [~, cur_points_xyz_leveled_without_ground] = groundSegmentationMex(linefitGroundSegmentParams, double(cur_points_xyz_leveled));
  cur_pc_leveled_without_ground = pointCloud(single(cur_points_xyz_leveled_without_ground));

  % write the leveled points without ground to ascii encoding style
  pcwrite(cur_pc_leveled_without_ground, sprintf('%s/%06d.pcd', annotation_points_without_ground_dir, cur_index), 'Encoding', 'ascii');

  if i == index_num
    str = sprintf('%06d', cur_index);
  else
    str = sprintf('%06d\r\n', cur_index);
  end
  
  fprintf(fid, str);

  fprintf('processing %06d/%06d\n', i, nimages);
end

fclose(fid);