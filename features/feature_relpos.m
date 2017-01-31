function locFeat = feature_relpos(skels, joints, pivot, samples, par)

% Replicate pivot
pivot = pivot * ones(size(joints));

%% Compute local features
locFeat = cell(size(skels));
for spl = samples
    S = skels{spl(1),spl(2),spl(3)};
    if isempty(S)
        continue;
    end
    nFrames = size(S,3);
    Sgood = zeros(1,nFrames);
    for i = 1:nFrames
        if check_skeleton(S(:,:,i))
            % Both skeletons are good
            Sgood(i) = 1;
        end
    end
    F = zeros(numel(joints) * size(S,1), sum(Sgood));
    Fcnt=1;
    for i = 1:nFrames
        if ~Sgood(i)
            continue;
        end
        RP = S(:,joints,i) - S(:,pivot,i);
        F(:,Fcnt) = reshape(RP,[],1);
        Fcnt = Fcnt + 1;
    end
    if isempty(F)
        warning('RP Local feature empty!');
    end
    locFeat{spl(1),spl(2),spl(3)} = par.weightRelPos * F;
end
