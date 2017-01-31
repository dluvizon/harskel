function [W,b,bestAcc,bestIter] = nonLinearMetricLearning(xTr, yTr, param)
% Learn a non-linear transformation max(0, W*xTr - b)
% Parameters:
%           xTr : Matrix [d x N] with N sample vectors
%           yTr : Vector [1 x N] with N labels
%         param : Struct with parameters defined as follows.
%                 .mu         : Ratio between push and pull components
%                 .gamma      : Regularization coefficient
%                 .margin     : Margin between targets and impostors
%                 .kNN        : Number of neighbors to use in the loss
%                 .outDim     : (Optional) output dimension
%                 .vanish     : (Optional) gradient vanishing point to stop
%                 .startIter  : (Optional) initial iteration number
%                 .maxIter    : (Optional) maximum number of iterations
%                 .Winit      : (Optional) initial matrix W
%                 .binit      : (Optional) initial values for matrix b
%                 .bstep      : (Optional) step to update b according to eta
%                 .feat       : (Optional) cell array in the format {a,s,e}
%                             with all samples.  If given, it will be used to
%                             plot the classification performance.

%% Define useful external variables
global debug
global par

%% Variables to be exported
global export
export.iter = [];
export.nimp = [];
export.loss = [];
export.accr = [];

%% Set default parameters
if ~isfield(param, 'outDim')
    param.outDim = size(xTr,1);
end
if ~isfield(param, 'vanish')
    param.vanish = 1e-6;
end
if ~isfield(param, 'startIter')
    param.startIter = 0;
end
if ~isfield(param, 'maxIter')
    param.maxIter = 5000;
end
if ~isfield(param, 'bstep')
    param.bstep = 0.01;
end

%% Print parameters if enabled with external debug
if debug > 1
    fprintf('\n--- PARAMETERS ---\n');
    fprintf('mu        : %g\n', param.mu);
    fprintf('gamma     : %g\n', param.gamma);
    fprintf('margin    : %g\n', param.margin);
    fprintf('kNN       : %g\n', param.kNN);
    fprintf('outDir    : %g\n', param.outDim);
    fprintf('vanish    : %g\n', param.vanish);
    fprintf('startIter : %g\n', param.startIter);
    fprintf('maxIter   : %g\n', param.maxIter);
end

%% Set fixed parameters
SDGSamples    = 25;     % Number of samples to be used in SGD
SGDRepetition = 25;     % Frequence to evaluate the results
% Descent step according to iterations
% | Iter. | Eta |
ETA = [...
    0       5e-6;...
    50      3e-4;...
    1000    1e-4];

%% Initialize L with the first eigenvector and random Gram-Schmidt basis
if isfield(param, 'Winit')
    W = param.Winit;
else
    %[~, W] = pca(xTr, param.outDim);
    covMat = cov(bsxfun(@minus, xTr', mean(xTr,2)'));
    [v,~] = eigs(covMat,1);
    W = rndGramSchmidtBase(v', param.outDim);
end
if isfield(param, 'binit')
    if numel(param.binit) == 1
        b = param.binit * ones(size(W,1),1);
    else
        b = param.binit;
    end
else
    b = zeros(size(W,1),1);
end

Z = transNonLin(W, b, xTr);
bestAcc  = 0;
bestIter = 0;

%% Get some useful values
numTrSpl = size(xTr,2);

%% Main loop
if debug > 1
    fprintf('\nIter.   Impost.  Loss Func.      Acc.');
    fprintf('\n-------------------------------------\n');
end
for iter = param.startIter:param.maxIter
    if iter > 0
        %% Take a training subsample
        idx = randperm(numTrSpl,SDGSamples);
        %% Compute the gradient
        [~, GL, Gb] = computeLossGrad(Z, xTr, yTr, idx, W, b, param);
        %% Update L and LxTr
        eta = ETA(ETA(:,1)<iter,2);
        W = W - eta(end) * GL;
        b = b - (param.bstep * eta(end)) * Gb;
        Z = transNonLin(W, b, xTr);
    end
    %% Every SGD repetition, evaluate the function loss
    if mod(iter,SGDRepetition) == 0
        % Compute the loss function for all samples
        [loss,~,~,nimp] = computeLossGrad(Z, [], yTr, 1:numTrSpl, W, b, param);
        % Is 'feat' was given, compute the classification accuracy
        if isfield(param, 'feat')
            [X,dlist] = serialize(param.feat);
            zX = deserialize(transNonLin(W, b, X),dlist);
            class = classify_knn(zX, par.listTr, par.listTe, par.knn);
            [~, accr] = show_results(class, par.actions);
            if accr > bestAcc
                bestAcc = accr;
                bestIter = iter;
            end
        else
            accr = Inf;
        end
        export.iter = [export.iter; iter];
        export.nimp = [export.loss; nimp];
        export.loss = [export.loss; loss];
        export.accr = [export.accr; accr];
        if debug > 0
            fprintf('NonLin: %05d  %05d \t %g    \t %.1f%%\n',...
                iter, nimp, loss, 100 * accr);
        end
        if loss < param.vanish
            fprintf('Finished by vanishing loss\n');
            return;
        end
    end
end

function [loss, GW, Gb, nimp] = computeLossGrad(Z, xTr, yTr, idx, W, b, param)
    % Set return variables
    loss = 0;
    GW = zeros(size(W));
    Gb = zeros(size(b));
    nimp = 0;
    % Init
    N  = size(Z,2);
    Ns = size(idx,2);
    Zs = Z(:,idx);
    d = Z > 0;
    %% Compute a matrix [Ns x N] of distances from samples to data
    D   = repmat(sum(Zs .* Zs,1)',1,N)...
        + repmat(sum(Z .* Z,1),Ns,1)...
        - 2 * Zs' * Z;
    [B,I] = sort(D,2);
    TG = yTr(I) == repmat(yTr(idx)',1,N);
    for i = 1:Ns
        %% Find the targets
        iTrg = find(TG(i,:));
        kNN = min(size(iTrg,2),param.kNN);
        iTrg = iTrg(1:kNN);
        Ntrg = size(iTrg,2);
        
        %% Find the impostors
        iImp = find(TG(i,1:iTrg(end)) == 0);
        Nimp = size(iImp,2);
        nimp = nimp + Nimp;
        
        %% Compute the loss
        H = max(0,repmat(B(i,iTrg)',1,Nimp)...
            - repmat(B(i,iImp),Ntrg,1) + param.margin);
        loss = loss + (1-param.mu) * sum(B(i,iTrg)) + param.mu * sum(H(:));
        
        %% Compute the gradient;
        if isempty(xTr)
            % Is xTr is empty, do not comput the gradient
            continue;
        end
        
        %% Usefull variables
        Zij  = repmat(Z(:,idx(i)),1,Ntrg);
        Zil  = repmat(Z(:,idx(i)),1,Nimp);
        Zj   = Z(:,I(i,iTrg));
        Zl   = Z(:,I(i,iImp));
        dij  = repmat(d(:,idx(i)),1,Ntrg);
        dil  = repmat(d(:,idx(i)),1,Nimp);
        dj   = d(:,I(i,iTrg));
        dl   = d(:,I(i,iImp));
        xijT = repmat(xTr(:,idx(i))',Ntrg,1);
        xilT = repmat(xTr(:,idx(i))',Nimp,1);
        xjT  = xTr(:,I(i,iTrg))';
        xlT  = xTr(:,I(i,iImp))';
        
        %% Gradient from targets (pull) relative to W
        GwPull = (Zij - dij .* Zj) * xijT;
        
        %% Gradient from targets (pull) relative to b
        GbPull = sum(dij .* Zj + dj .* Zij - Zij - Zj, 2);
        
        %% Gradient from impostors (push) relative to W
        GwjTmp1  = repmat(Zj - dj .* Zij, 1, 1, Nimp);
        GwjTmp2  = repmat(dij .* Zj     , 1, 1, Nimp);
        xjTTmp1  = permute(repmat(xjT   , 1, 1, Nimp), [2 1 3]);
        xijTTmp2 = permute(repmat(xijT  , 1, 1, Nimp), [2 1 3]);
        
        GwlTmp1  = permute(repmat(Zl - dl .* Zil, 1, 1, Ntrg), [1 3 2]);
        GwlTmp2  = permute(repmat(dil .* Zl     , 1, 1, Ntrg), [1 3 2]);
        xlTTmp1  = permute(repmat(xlT           , 1, 1, Ntrg), [2 3 1]);
        xilTTmp1 = permute(repmat(xilT          , 1, 1, Ntrg), [2 3 1]);
        
        Isel = H > 0;
        GwjTmp1  = GwjTmp1(:,Isel);
        GwjTmp2  = GwjTmp2(:,Isel);
        GwlTmp1  = GwlTmp1(:,Isel);
        GwlTmp2  = GwlTmp2(:,Isel);
        xjTTmp1  = xjTTmp1(:,Isel)';
        xijTTmp2 = xijTTmp2(:,Isel)';
        xlTTmp1  = xlTTmp1(:,Isel)';
        xilTTmp1 = xilTTmp1(:,Isel)';
        GwPush = GwjTmp1*xjTTmp1 - GwjTmp2*xijTTmp2...
               - GwlTmp1*xlTTmp1 + GwlTmp2*xilTTmp1;
           
        %% Gradient from impostors (push) relative to b
        GbjTmp = repmat(dj .* Zij + dij .* Zj - Zj, 1, 1, Nimp);
        GblTmp = permute(repmat(dl .* Zil + dil .* Zl - Zl, 1, 1, Ntrg), [1 3 2]);
        GbjTmp = GbjTmp(:,Isel);
        GblTmp = GblTmp(:,Isel);
        GbPush = sum(GbjTmp - GblTmp, 2);

        GW = GW + (1-param.mu)*GwPull + param.mu*GwPush;
        Gb = Gb + (1-param.mu)*GbPull + param.mu*GbPush;
    end
    R = param.gamma * (W'*W - eye(size(W,2)));
    loss = loss + trace(R*R');
    if ~isempty(xTr)
        GW = GW + 2*(W*R);
    end
end

end
