% read the boundingbox and draw the 3D bbox in Lidar and 2d bbox in image

clc;
close all;

addpath('../thirdParty/yaml');
addpath('../func');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('annotation_data_root')
  annotation_data_root = 'C:\Users\Administrator\Documents\ethan\workspace\3d-bat\input\NuScenes\SanheyiDemo';
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

if ~exist('annotation_sequence')
  annotation_sequence = 'SanheyiDemo';
end

if ~exist('annotation_config')
  annotation_config = 'config.txt';
end

if ~exist('index_filename')
  index_filename = 'filename.txt';
end

annotation_filename = sprintf('%s/%s/NuScenes_%s_annotations.txt', annotation_data_root, annotation_annotations_path, annotation_sequence);

annotation_config_filename = sprintf('%s/%s', annotation_data_root, annotation_config);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #: load the config params
config_params = YAML.read(annotation_config_filename);

P = str2num(config_params.P);
P = reshape(P, 4, 3)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #: load the bbox for the annotation_index
annotation_text = fileread(annotation_filename);
annotation_json = jsondecode(annotation_text);

nimages = size(annotation_json, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #: load the annotation filenames
filename_index = load(sprintf('%s/%s', annotation_data_root, index_filename));
filename_index = floor(filename_index);

image_dir = sprintf('%s/%s', annotation_data_root, annotation_images_path);
% set up figure
h = visualization('init', image_dir, filename_index(1));

% main loop
idx_ = 1;
while 1

  img_idx = filename_index(idx_);
  
  % load labels
  cur_annotation_jsons = annotation_json{idx_};
  objects = [];
  for i = 1 : length(cur_annotation_jsons)
    cur_annotation_json = cur_annotation_jsons(i);
    object = struct();
    object.ry = cur_annotation_json.rotationY;
    object.w = cur_annotation_json.width;
    object.l = cur_annotation_json.length;
    object.h = cur_annotation_json.height;
    object.t(1) = cur_annotation_json.x;
    object.t(2) = cur_annotation_json.y;
    object.t(3) = cur_annotation_json.z;
    objects = [objects object];
  end
  
  % visualization update for next frame
  visualization('update',image_dir,h,img_idx,nimages,idx_);
 
  % for all annotated objects do
  for obj_idx=1:numel(objects)
    
    % plot 3D bounding box
    [uv_corners, face_idx, ~] = computeBox3D(objects(obj_idx),P);
    orientation = computeOrientation3D(objects(obj_idx),P);
    drawBox3D(h(2).axes, objects(obj_idx),uv_corners,face_idx,orientation);
  end

  % force drawing and tiny user interface
  waitforbuttonpress; 
  key = get(gcf,'CurrentCharacter');
  switch lower(key)                         
    case 'q',  break;                                 % quit
    case '-',  idx_ = max(idx_-1,  1);          % previous frame
    case 'x',  idx_ = min(idx_+10,nimages-1); % +100 frames
    case 'y',  idx_ = max(idx_-10,0);         % -100 frames
    otherwise, idx_ = min(idx_+1,  nimages-1);  % next frame
  end

end

% clean up
close all;

