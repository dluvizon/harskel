function locFeat = feature_dispvect(skels, sIndex, joints, samples, par)

%% Set up parameters
winSz = 3;
stepPrev = int32((winSz - 0.5)/2);
stepLast = int32((winSz - 1.5)/2);

%% Compute local features
locFeat = cell(size(skels));
for spl = samples
    S = skels{spl(1),spl(2),spl(3)};
    if isempty(S)
        continue;
    end
    sidx = sIndex{spl(1),spl(2),spl(3)};
    nFrames = size(S,3);
    % Compute the window of frames according to winSize
    firstFrame = min(nFrames, stepPrev + 1);
    lastFrame  = max(1, nFrames - stepLast);
    if firstFrame >= lastFrame
        warning('Action with %d frames only\n', nFrames);
        continue;
    end
    Sgood = zeros(1,lastFrame);
    for i = firstFrame:lastFrame
        i1 = i - stepPrev;
        i2 = i + stepLast;
        if check_skeleton(S(:,:,i1)) && check_skeleton(S(:,:,i2))
            % Both skeletons are good
            Sgood(i) = 1;
        end
    end
    F = zeros(numel(joints) * size(S,1), sum(Sgood));
    Fcnt=1;
    for i = firstFrame:lastFrame
        i1 = i - stepPrev;
        i2 = i + stepLast;
        if ~Sgood(i)
            % At least one of these skeletons are not good.
            continue;
        end
        dT = sidx(i2) - sidx(i1);
        DV = (S(:,joints,i1) - S(:,joints,i2)) / dT;
        F(:,Fcnt) = reshape(DV,[],1);
        Fcnt = Fcnt + 1;
    end
    if isempty(F)
        warning('DV Local feature empty!');
    end
    locFeat{spl(1),spl(2),spl(3)} = par.weightDisVec * F;
end
