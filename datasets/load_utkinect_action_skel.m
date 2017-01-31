function [skeletons, sIndex] = load_utkinect_action_skel(dpath)
% Load skeletons from UTKinect-Action dataset.
%
%        File: load_utkinect_action_skel.m
%       Usage: skeletons = load_utkinect_action_skel(dpath, list);
% Description: Load all skeletons in 'list' from 'dpath'.

global debug;

%% Load all skeletons in list
labelsList = load_utkinect_action_label([dpath '/actionLabel.txt']);
skeletons = cell(size(labelsList));
sIndex = cell(size(labelsList));

nASE = size(labelsList);
for s = 1:nASE(2)
    for e = 1:nASE(3)
        fname = sprintf('joints_s%02d_e%02d.txt', s, e);
        if debug > 1
            fprintf('Loading skeleton "%s"\n', fname);
        end
        
        %% Open file
        S = load_utkinect_skelfile([dpath '/joints/' fname]);
        %% Handle each action from this file
        for a = 1:nASE(1)
            for f = labelsList{a,s,e}(1):labelsList{a,s,e}(2)
                if isnan(f)
                    continue;
                end
                if ~check_skeleton(S{f})
                    continue;
                end
                skeletons{a,s,e} = [skeletons{a,s,e} S{f}];
                sIndex{a,s,e} = [sIndex{a,s,e}; f];
            end
            skeletons{a,s,e} = reshape(skeletons{a,s,e}, 3, 20, []);
        end
    end
end

function S = load_utkinect_skelfile(fname)
    fd = fopen(fname, 'r');
    if fd == -1
        error('Could not open file "%s"\n', fname);
    end
    Sraw = fscanf(fd, '%f');
    fclose(fd);
    Sraw = reshape(Sraw, 1 + 3 * 20, []);
    idx = Sraw(1,:);
    S = cell(0);
    i = 1;
    for ic = idx
        S{ic} = Sraw(2:end,i);
        i = i+1;
    end
end

function labelList = load_utkinect_action_label(filename)
    fd = fopen(filename, 'r');
    if fd == -1
        error('Could not open file "%s"\n', filename);
    end

    labelList = cell(0,0,0);
    while true
        se = fscanf(fd, '\ns%02d_e%02d\n');
        if isempty(se)
            break;
        end
        A  = fscanf(fd, '%f', [2 10]);
        a = 1;
        for aIndex = A
            labelList{a,se(1),se(2)} = aIndex;
            a = a + 1;
        end
    end
    fclose(fd);
end
end