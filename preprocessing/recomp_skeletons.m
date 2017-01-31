%% Notice:
% By default, this files just load the pre-processed skeletons stored
% in ./input.  If you want to recompute them, configure the variable
% par.datasetPath in setup.m and uncomment the corresponding lines bellow.
% The original datasets **are not** provided with this software, since they
% are publicly available on thier corresponding web sites:
% ** MSR Action 3D **:
% http://research.microsoft.com/en-us/um/people/zliu/ActionRecoRsrc/
% ** UTKinect Action 3D **:
% http://cvrc.ece.utexas.edu/KinectDatasets/HOJ3D.html
% ** Florence 3D Actions **:
% https://www.micc.unifi.it/resources/datasets/florence-3d-actions-dataset/

%% Load global parameters, seted up by the setup.m script
global par;
global outdir;

%% Load/save skeletons from/to file
% [skels, sIndex] = load_msr_action3d_skel(par.datasetPath, par.allSamples);
% [skels, sIndex] = load_utkinect_action_skel(par.datasetPath);
% [skels, sIndex] = load_florence_3d_action_skel(par.datasetPath);
% savevar(['input/Data/' par.skelMat], skels);
% savevar(['input/Data/' par.skelIdx], sIndex);
skels  = loadvar(['input/Data/' par.skelMat]);
sIndex = loadvar(['input/Data/' par.skelIdx]);

%% For the dataset Florence 3D Action
if strcmp(par.datasetName, 'Florence3DAction')
    recomput_lists_florence3d_action(skels, 1);
end

%% Write skeletons and depth images into debug files
% dPath  = [par.datasetPath '/../DepthMat'];
% imgDir = init_dir([outdir.img '/' par.datasetName]);
% for ase = par.allSamples
%     actDir = init_dir(sprintf('%s/a%02d_s%02d_e%02d', imgDir, ase));
%     depth  = loadvar(sprintf('%s/a%02d_s%02d_e%02d', dPath, ase));
%     draw_depth_skeleton_images(depth, skels{ase(1),ase(2),ase(3)}, actDir);
% end

%% Pre-processing skeleton joints
skels = shrink_skeletons(skels);
% skels = rotate_all_skeletons(skels);
% skels = scale_skeletons(skels);
savevar([outdir.data '/' par.skelMat '_pp'], skels);
savevar([outdir.data '/' par.skelIdx '_pp'], sIndex);
