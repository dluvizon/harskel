function [skeletons, sIndex] = load_florence_3d_action_skel(dpath)
% Load skeletons from Florence 3D Action dataset.

% fname = sprintf('%s/Florence_dataset_Features.txt', dpath);
fname = sprintf('%s/Florence_dataset_WorldCoordinates.txt', dpath);
fd = fopen(fname, 'r');
if fd == -1
    error('Could not open file "%s"\n', fname);
end
S = fscanf(fd, '%f');
fclose(fd);
S = reshape(S, 3 + 45, []);
VidIds  = unique(S(1,:));
Subject = unique(S(2,:));
Actions = unique(S(3,:));
Events  = 1:ceil(size(VidIds,2) / (size(Actions,2) * size(Subject,2)));

skeletons = cell(max(Actions),max(Subject),max(Events));
sIndex = cell(size(skeletons));
auxE = zeros(max(Actions),max(Subject));

for id = VidIds
    %% Select the data from this video
    lines = S(:, S(1,:) == id);
    %% Recovery the action (a), subject (s), and event (e)
    a = lines(3,1);
    s = lines(2,1);
    auxE(a,s) = auxE(a,s)+1;
    e = auxE(a,s);
    %% Recovery the skeleton
    skeletons{a,s,e} = reshape(lines(4:end,:), 3, 15, []);
    % tframe = lines(28,:);
    % dt = tframe(2:end) - tframe(1:end-1);
    % idx = [1, int32(dt / min(dt))];
    % sIndex{a,s,e} = cumsum(idx);
    sIndex{a,s,e} = 1:size(skeletons{a,s,e}, 3);
end
