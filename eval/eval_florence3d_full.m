function eval_florence3d_full(id, opts)
% Wrapper to our method, allowing to give parameters as arguments
%
% Param:
%       id: (Required) used to identify saved files. If given two values,
%           i.e. [val1, val2], use val1 as ID and val2 as the seed for rand.
%       opts: (Optional) if given, must have 15 values, according to the
%       features parameters in setup.m. If not given, use default values.

global par
global outdir

% Global variable for timing
global tm
tm.locFeat = 0;
tm.featAgg = 0;
tm.featProj = 0;
tm.classKnn = 0;

if nargin == 2
    assert(size(opts,2) == 15, 'opts must be 1x15 (%dx%d)', size(opts));
    par.clusterPCA       = opts( 1);
    par.clusterNorm      = opts( 2);
    par.clusterAlpha     = opts( 3);
    par.weightRelPos     = opts( 4);
    par.weightDisVec     = opts( 5);
    par.kmeansRuns       = opts( 6);
    par.kmeansK          = opts( 7);
    par.fConcatdoPCA     = opts( 8);
    par.fConcatdoPCAPar  = opts( 9);
    par.fConcatdoNorm    = opts(10);
    par.fConcatpowerLaw  = opts(11);
    par.kConcatdoPCA     = opts(12);
    par.kConcatdoPCAPar  = opts(13);
    par.kConcatdoNorm    = opts(14);
    par.kConcatpowerLaw  = opts(15);
end

%% Recomputing features
if numel(id) == 1
    X = recomp_features(par, outdir);
else
    X = recomp_features(par, outdir, id(2));
end
% Saving features
featName = sprintf('%s/feat_%s_%04d', outdir.data, par.datasetName, id(1));
savevar(featName, X);

%% Evaluate features
if par.loocv
    eval_florence3d_train_loocv(id(1), 0);
else
    eval_florence3d_train_cross(id(1), 0);
end

% Compute the average execussion time per sample (in ms)
tm.locFeat = 1000 * tm.locFeat / size(par.allSamples, 2);
tm.featAgg = 1000 * tm.featAgg / size(par.allSamples, 2);
tm.featProj = 1000 * tm.featProj / size(par.allSamples, 2);
tm.classKnn = 1000 * tm.classKnn / size(par.listTe, 2);

fprintf('Timing:  locFeat = %g  featAgg = %g  featProj = %g  classKnn = %g\n',...
    tm.locFeat, tm.featAgg, tm.featProj, tm.classKnn)
