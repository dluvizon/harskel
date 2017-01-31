% Set up the environment.

%% Define the global variables to export parameters and options.
clearvars -global;
global par
global debug
global outdir

%% Parameters to be changed:
par = struct();

%% Parameters concerning the feature extraction stage.
% PCA and normalization inside individual clusters
par.clusterPCA    = 1;
par.clusterNorm   = 0;
par.clusterAlpha  = 0;

% Weight for relative position and displacement vector features
par.weightRelPos = 1;
par.weightDisVec = 15;

% Number of k-means concatenations
par.kmeansRuns    = 5;
par.kmeansK       = 23;

%% Parameters for features concatenation
par.fConcatdoPCA     = 0;
par.fConcatdoPCAPar  = 0;
par.fConcatdoNorm    = 0;
par.fConcatpowerLaw  = 0;

%% Parameters for kmeans concatenation
par.kConcatdoPCA     = 0;
par.kConcatdoPCAPar  = 0;
par.kConcatdoNorm    = 1;
par.kConcatpowerLaw  = 0.5;

%% Parameters for metric learning (stages 1,2)
par.mls1_mu      = 0.9;
par.mls1_gamma   = 0.1;
par.mls1_margin  = 0.1;
par.mls1_maxiter = 2;
par.mls1_outdim  = 512;

par.mls2_mu      = 0.5;
par.mls2_gamma   = 0.1;
par.mls2_margin  = 0.1;
par.mls2_maxiter = 50;
par.mls2_outdim  = 256;

% Number of neighbors in kNN
par.knn  = 7;

%% Debug options
debug = 1;

%% Add subfolders to path
addpath([pwd '/classifiers']);
addpath([pwd '/datasets']);
addpath([pwd '/features']);
addpath([pwd '/learning']);
addpath([pwd '/utils']);
addpath([pwd '/utils/draw']);
addpath([pwd '/eval']);
addpath([pwd '/preprocessing']);

%% Notice:
% Point the datasetsPath to your local dataset if you want to recompute the
% pre-processed skeletons. It is not needed if you use the provided files
% from the ./input folder (by default).
datasetsPath = [getenv('HOME') '/Dataset'];

%% Configure dataset MSRAction3D
par.datasetName = 'MSRAction3D';
par.datasetPath = [datasetsPath '/MSR/Action3D/Skeleton_Real3D'];
par.skelMat     = 'MSR_Action3D_Skeletons';
par.skelIdx     = 'MSR_Action3D_SkelIndex';
par.testOreifej = 0;
%% Configure dataset UTKinect
% par.datasetName = 'UTKinectAction';
% par.datasetPath = [datasetsPath '/UTKinect_Action'];
% par.skelMat     = 'UTKinect_Skeletons';
% par.skelIdx     = 'UTKinect_SkelIndex';
%% Configure dataset Florence 3D Action
% par.datasetName = 'Florence3DAction';
% par.datasetPath = [datasetsPath '/Florence_3d_actions'];
% par.skelMat     = 'Florence_3D_Action_Skeletons';
% par.skelIdx     = 'Florence_3D_Action_SkelIndex';

%% Configure evaluation for LOOCV or cross validation
par.loocv = 0;

if par.loocv
    par.listLOOCV = load_file_list(...
        ['input/' par.datasetName '/loocv.txt'], 'a%d_s%d_e%d\n', 3);
    par.allSamples = par.listLOOCV;
else
    par.listTe = load_file_list(...
        ['input/' par.datasetName '/full_cross_te.txt'], 'a%d_s%d_e%d\n', 3);
    par.listTr = load_file_list(...
        ['input/' par.datasetName '/full_cross_tr.txt'], 'a%d_s%d_e%d\n', 3);
    par.allSamples = [par.listTe par.listTr];
end

if strcmp(par.datasetName, 'MSRAction3D') && par.testOreifej
    par.allSamples = load_file_list(...
        'input/MSRAction3D/OreifejFileList.txt', 'a%d_s%d_e%d\n', 3);
end

% Number of Actions, Subjects, and Events
par.actions = unique(par.allSamples(1,:));

%% Create output directories if needed, and export its path.
outdir.root = init_dir('output');
outdir.data = init_dir([outdir.root '/data']);
outdir.img = init_dir([outdir.root '/img']);
outdir.log = init_dir([outdir.root '/log']);

%% Setup VLfeat
run([pwd '/3rdparty/vlfeat-0.9.20/toolbox/vl_setup.m']);

%% Add libsvm to path
addpath([pwd '/3rdparty/libsvm/matlab']);
