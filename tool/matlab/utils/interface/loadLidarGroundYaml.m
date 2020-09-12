function [lidar2GroundMat, lidar2Ground6dof] = loadLidarGroundYaml(filePath)
    %% %YAML:1.0
    %% ---
    %% LidarToGroundExtrinsicMat: 
    %%   rows: 4
    %%   cols: 4
    %%   dt: d
    %%   data: [ 4x4 ]
    %% mount_yaw: 1x1
    %% mount_pitch: 1x1
    %% mount_roll: 1x1
    %% mount_x: 1x1
    %% mount_y: 1x1
    %% mount_z: 1x1

    % we use YAMLMATLAB tools to parse the YAML file
    % @installation: Install it by  addpath(genpath('path/to/codes'));
    % @attention: for the autoware generated yml file, you should manually delete the fist comment line and '!!opencv-matrix'
    % reference URL: https://shan2011.blogspot.com/2013/05/transferring-data-from-opencv-to-matlab.html
    % reference URL: http://vision.is.tohoku.ac.jp/~kyamagu/software/yaml/

    % the calibration matrix from the camera to lidar
    calib = YAML.read(filePath);

    % camera intrinsic matrix
    lidar2GroundMat = reshape(calib.LidarToGroundExtrinsicMat.data, calib.LidarToGroundExtrinsicMat.rows, calib.LidarToGroundExtrinsicMat.cols);
    lidar2GroundMat = lidar2GroundMat'; % matlab matrix will form the matrix along the cols order


    % image size
    mount_yaw = calib.mount_yaw;
    mount_pitch = calib.mount_pitch;
    mount_roll = calib.mount_roll;
    mount_x = calib.mount_x;
    mount_y = calib.mount_y;
    mount_z = calib.mount_z;

    lidar2Ground6dof = [
      mount_yaw ...
      mount_pitch ...
      mount_roll ...
      mount_x ...
      mount_y ...
      mount_z
    ];
end
