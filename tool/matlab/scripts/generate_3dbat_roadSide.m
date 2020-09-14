% generate the dataset for annotation of roadSide

clc;
close all;

if ~exist('src_data_root')
  src_data_root = 'C:\Users\Administrator\Desktop\pcd_data';
end

if ~exist('dest_data_root')
  dest_data_root = 'C:\Users\Administrator\Documents\ethan\workspace\3d-bat\input\NuScenes';
end

supportFormat = {'.pcd'};

total_annotations = 0;
total_annotations_id = [];

AllFiles = dir([src_data_root '/*.*']);
for i = 1 : length(AllFiles)
  % ignore the folder
  if ~(AllFiles(i).isdir)
    % get the filename extenntion
    [~, id, ext] = fileparts(AllFiles(i).name);
    if ismember(ext, supportFormat)
      total_annotations = total_annotations + 1;
      total_annotations_id = [total_annotations_id str2num(id)];
    end
  end
end

total_segments = 9;

seg_annotations = floor(total_annotations/total_segments);

for index = 1 : total_annotations
  current_annotation_index = total_annotations_id(index);
  cur_pc = pcread(sprintf('%s/%06d.pcd', src_data_root, current_annotation_index));

  cur_seg = floor((index-1)/seg_annotations) + 1;

  cur_seg_dir = sprintf('%s/roadSide_%02d', dest_data_root, cur_seg);

  % write the leveled points to ascii encoding style
  pcwrite(cur_pc, sprintf('%s/pointclouds/%06d.pcd', cur_seg_dir, index), 'Encoding', 'ascii');

  cur_annotation_filename = sprintf('%s/filename.txt', cur_seg_dir);
  fid = fopen(cur_annotation_filename, 'a');
  if index == total_annotations || mod(index, seg_annotations) == 0
    str = sprintf('%06d', index);
  else
    str = sprintf('%06d\r\n', index);
  end
  fprintf(fid, str);
  fclose(fid);

  fprintf('processing %06d/%06d\n', index, total_annotations);
end