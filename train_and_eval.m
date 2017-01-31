%% Reset parameters and variables
clearvars;
setup;

global par;

%% Recompute skeletons
recomp_skeletons;

if strcmp(par.datasetName, 'MSRAction3D')
    eval_msraction3d_full([3 3])
    testSVM;
elseif strcmp(par.datasetName, 'UTKinectAction')
    eval_utkinect_full([1 1])
elseif strcmp(par.datasetName, 'Florence3DAction')
    eval_florence3d_full([1 1])
end

