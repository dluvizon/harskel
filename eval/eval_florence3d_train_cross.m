function eval_florence3d_train_cross(id, idLog, opts)
% Wrapper to our method, allowing to give parameters as arguments
%
% Param:
%       id: (Required) used to identify saved and logged files.
%           It must be a list of IDs, e.g. [1 2 4 7 ...].
%       opts: (Optional) if given, must have 16 values, according to the
%       learning parameters in setup.m. If not given, use default values.

global par;
global outdir;
global export

if nargin == 3
    assert(size(opts,2) == 16, 'opts must be 1x16 (%dx%d)', size(opts));
    par.mls1_mu      = opts( 1);
    par.mls1_gamma   = opts( 2);
    par.mls1_margin  = opts( 3);
    par.mls1_maxiter = opts( 4);
    par.mls1_outdim  = opts( 5);
    par.mls2_mu      = opts( 6);
    par.mls2_gamma   = opts( 7);
    par.mls2_margin  = opts( 8);
    par.mls2_maxiter = opts( 9);
    par.mls2_outdim  = opts(10);
    par.mls3_mu      = opts(11);
    par.mls3_gamma   = opts(12);
    par.mls3_margin  = opts(13);
    par.mls3_maxiter = opts(14);
    par.mls3_outdim  = opts(15);
    par.knn          = opts(16);
else
    opts = [];
end

for ID = id(:)

    %% Loading saved features
    featName = sprintf('%s/feat_%s_%04d', outdir.data, par.datasetName, ID);
    X = loadvar(featName);
    
    [xTr,listTr] = serialize(X, par.listTr);
    yTr = listTr(:,1)';

    class = classify_knn(X, par.listTr, par.listTe, par.knn);
    [~, accr0] = show_results(class, par.actions);

    % Metric learning stage 1
    clear param;
    param.mu        = par.mls1_mu;
    param.gamma     = par.mls1_gamma;
    param.margin    = par.mls1_margin;
    param.kNN       = Inf;
    param.maxIter   = par.mls1_maxiter;
    param.outDim    = par.mls1_outdim;
    param.feat      = X;
    L1 = linearMetricLearning(xTr, yTr, param);
    [D,list] = serialize(X);
    Z = transLin(L1,D);
    X1 = deserialize(Z,list);

    class = classify_knn(X1, par.listTr, par.listTe, par.knn);
    [~, accr1] = show_results(class, par.actions);


    % Metric learning stage 2
    [xTr,~] = serialize(X1, par.listTr);
    clear param;
    param.mu        = par.mls2_mu;
    param.gamma     = par.mls2_gamma;
    param.margin    = par.mls2_margin;
    param.kNN       = Inf;
    param.maxIter   = par.mls2_maxiter;
    param.outDim    = par.mls2_outdim;
    param.feat      = X1;
    L2 = linearMetricLearning(xTr, yTr, param);
    [D,list] = serialize(X1);
    Z = transLin(L2,D);
    X2 = deserialize(Z,list);

    class = classify_knn(X2, par.listTr, par.listTe, par.knn);
    [~, accr2] = show_results(class, par.actions);
    bestAcc = max(export.accr);

    fprintf('Results cross: %.1f%% --> %.1f%% --> %.1f%% (%.1f%%)\n',...
        100*[accr0 accr1 accr2 bestAcc]);
end
