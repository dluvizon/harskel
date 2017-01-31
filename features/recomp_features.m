function fF = recomp_features(par, outdir, rndID)
% Run the complete pipeline to generate features, return the final feature
% vectors in fF.
%
% The variable par should be defined as in the file setup.m

global tm

tic; % Start timing
nRunsKmeans  = par.kmeansRuns;

allSpl  = par.allSamples;
sklFile = [outdir.data '/' par.skelMat '_pp'];
idxFile = [outdir.data '/' par.skelIdx '_pp'];

%% Reset random seed if given an ID
if nargin > 2
    rng(rndID);
    vl_twister('STATE', rndID);
end

%% Extract local features
skels = loadvar(sklFile);
sIndex = loadvar(idxFile);
locFeat = cell(1,7);
locFeat{1} = feature_dispvect(skels, sIndex, [9 1 6 12 15], allSpl, par);
locFeat{2} = feature_dispvect(skels, sIndex, [8 2 5 11 14], allSpl, par);
locFeat{3} = feature_dispvect(skels, sIndex, [7 3 4 10 13], allSpl, par);
locFeat{4} = feature_relpos(skels, [1 6  9], 3, allSpl, par);
locFeat{5} = feature_relpos(skels, [1 6 12], 13, allSpl, par);
locFeat{6} = feature_relpos(skels, [1 9 15], 10, allSpl, par);
locFeat{7} = feature_relpos(skels, [6 9], 1, allSpl, par);
tm.locFeat = tm.locFeat + toc;


%% Features aggregation
tic;
tmpF = cell(1,nRunsKmeans);
param.powerLaw = par.fConcatpowerLaw;
param.doPCA    = par.fConcatdoPCA;
param.doPCAPar = par.fConcatdoPCAPar;
param.doNorm   = par.fConcatdoNorm;
tm.featAgg = tm.featAgg + toc;
for r = 1:nRunsKmeans
    gF = cell(1,7);
    for l = 1:numel(locFeat)
        % The timing on k-means is done inside comput_clusters
        [C, assign, f] = compute_clusters(locFeat{l}, par);
        tic;
        gF{l} = compute_global_features(f, assign, C, Inf);
        tm.featAgg = tm.featAgg + toc;
    end
    tic;
    tmpF{r} = concat_features(gF, param);
    tm.featAgg = tm.featAgg + toc;
end

% Concatenate all runs from kmeans
tic;
param.powerLaw = par.kConcatpowerLaw;
param.doPCA    = par.kConcatdoPCA;
param.doPCAPar = par.kConcatdoPCAPar;
param.doNorm   = par.kConcatdoNorm;
fF = concat_features(tmpF, param);
tm.featAgg = tm.featAgg + toc;
