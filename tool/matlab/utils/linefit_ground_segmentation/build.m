%% build the mex-cpp file by mex command
clc;

PCL_INCLUDE_DIRS = {
  '-I/usr/include/pcl-1.7', ...
};

EIGEN_INCLUDE_DIRS = {
  '-I/usr/include/eigen3', ...
};

INCLUDE_DIRS = {
  '-I./inc', ...
};

CERES_INCLUDE_DIRS =   {
    ['-I/usr/local/include'], ...
    ['-I/usr/include/eigen3'], ...
    ['-I/usr/include/usr/include'], ...
    ['-I/usr/include/suitesparse'], ...
};

CERES_LIBRARY_DIRS = {
    ['-L','/usr/local/lib'], ...
};

CERES_LIBRARIES = {
    ['/usr/local/lib/libceres.a'], ...
    ['-lcholmod'], ...
    ['-lglog'], ...
    ['-lcxsparse'], ...
    ['-llapack'], ...
    ['-lblas'], ...
    ['-lgomp'], ...
    ['-largeArrayDims'], ...
};

%% ======================================================================================== %%
disp('=====================================================================================');
disp('build function groundSegmentationMex');
disp('=====================================================================================');
opts = {
    % ['-DDEBUG '], ...
    % ['CXXFLAGS="\$CXXFLAGS -std=c++11"'], ... % 
};
src = {
    ['./cpp/groundSegmentationMex.cpp'], ...
    ['./cpp/ground_segmentation.cc'], ...
    ['./cpp/segment.cc'], ...
    ['./cpp/bin.cc'], ...
};
mex(...
    opts{:}, ...
    PCL_INCLUDE_DIRS{:}, ...
    EIGEN_INCLUDE_DIRS{:}, ...
    INCLUDE_DIRS{:}, ...
    src{:}, ...
    '-outdir', ...
    './mex'); 

%% ======================================================================================== %%
disp('=====================================================================================');
disp('estimatePitchRollByCoNormalCeresMex');
disp('=====================================================================================');
opts = {
    % ['-DDEBUG '], ...
};
src = {
    ['cpp/estimatePitchRollByCoNormalCeresMex.cpp'], ...
};

mex(...
    opts{:}, ...
    src{:}, ...
    CERES_INCLUDE_DIRS{:}, ...
    CERES_LIBRARY_DIRS{:}, ...
    CERES_LIBRARIES{:}, ...
    '-outdir', ...
    './mex', ...
    '-output', ...
    'estimatePitchRollByCoNormalCeresMex'); 