function [skeletons, sIndex] = load_msr_action3d_skel(dpath, list)
% Load skeletons from MSR Action 3D dataset.
%
%        File: load_msr_action3d_skel.m
%       Usage: [skeletons, sIndex] = load_msr_action3d_skel(dpath, list);
% Description: Load all skeletons in 'list' from 'dpath'.

global debug;

%% Load all skeletons in list
skeletons = cell(0,0,0);
sIndex = cell(0,0,0);
for spl = list
    a = spl(1);
    s = spl(2);
    e = spl(3);
    fname = sprintf('a%02d_s%02d_e%02d_skeleton.txt', a, s, e); 
    if debug > 1
        fprintf('Loading skeleton "%s"\n', fname);
    end
    skl = load_skeleton_msr_action3d([dpath '/' fname], 4, 20);
    if isempty(skl)
        warning('Bad skeleton: "%s"\n', fname);
        continue;
    end
    S = convert_skeleton_layout_to_default(skl(1:3,:,:));
    idx = 1;
    skel = [];
    sidx = [];
    for nf = 1:size(S,3)
        if ~check_skeleton(S(:,:,nf))
            continue;
        end
        skel(:,:,idx) = S(:,:,nf);
        sidx = [sidx; nf];
        idx = idx+1;
    end
    skeletons{a,s,e} = skel;
    sIndex{a,s,e} = sidx;
end

function s = load_skeleton_msr_action3d(fname, npoints, njoints)
    fd = fopen(fname, 'r');
    if fd == -1
        error('Could not open file "%s"\n', fname);
    end
    s = fscanf(fd, '%f');
    fclose(fd);
    s = reshape(s, npoints, njoints, size(s, 1) / (npoints * njoints));
end
end