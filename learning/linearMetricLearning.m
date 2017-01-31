function L = linearMetricLearning(xTr, yTr, param)
% Learn a linear transformation L
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
%                 .maxIter    : (Optional) maximum number of iterations
%                 .Linit      : (Optional) initial matrix L
%                 .feat       : (Optional) cell array in the format {a,s,e}
%                             with all samples. If given, it will be used to
%                             plot the classification performance.

%% Define useful external variables
global debug
global par

%% Variables to be exported
global export
export.epoch = [];
export.nimp  = [];
export.loss  = [];
export.normg = [];
export.accr  = [];

%% Set default parameters
if ~isfield(param, 'outDim')
    param.outDim = size(xTr,1);
end
if ~isfield(param, 'vanish')
    param.vanish = 0.001;
end
if ~isfield(param, 'maxIter')
    param.maxIter = 20;
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
SDGSamples = 32;

% Descent step according to iterations
% | Epoch | Eta |
ETA = [...
    0      2e-6;...
    1      5e-4;...
    5      2e-4];

%       Min.  Max.  Ratio
ETA2 = [2e-6, 1e-3, 0.005];

%% Initialize L with PCA if it was not given
if isfield(param, 'Linit')
    L = param.Linit;
else
    [~, L] = pca(xTr, param.outDim);
end
LxTr = transLin(L,xTr);

%% Get some useful values
numTrSpl = size(xTr,2);
% Init epoch counters
lastEpoch = -Inf;
numTrDone = 0;
eta = 0;

%% Main loop
while true
    if lastEpoch > -Inf
        numTrDone = numTrDone + SDGSamples;
        %% Take a training subsample
        idx = randperm(numTrSpl,SDGSamples);
        %% Compute the gradient
        [~, GL] = computeLossGrad(LxTr, xTr, yTr, idx, L, param);
        %% Update L and LxTr
        %eta = ETA(ETA(:,1) < (epoch+1),2);
        %L = L - eta(end) * GL;
        eta = ETA2(3) / sqrt(normGL);
        eta = min(max(ETA2(1),eta), ETA2(2));
        L = L - eta * GL;
        LxTr = transLin(L,xTr);
    end
    epoch = floor(numTrDone / numTrSpl);
    %% Every new epoch, evaluate the function loss
    if epoch ~= lastEpoch
        lastEpoch = epoch;
        % Compute the loss function for all samples
        [loss,GL,nimp] =...
            computeLossGrad(LxTr, xTr, yTr, 1:numTrSpl, L, param);
        normGL = norm(GL);
        % Is 'feat' was given, compute the classification accuracy
        if isfield(param, 'feat')
            [X,dlist] = serialize(param.feat);
            lX = deserialize(transLin(L,X),dlist);
            class = classify_knn(lX, par.listTr, par.listTe, par.knn);
            [~, accr] = show_results(class, par.actions);
        else
            accr = Inf;
        end
        export.epoch = [export.epoch; epoch];
        export.nimp  = [export.nimp;  nimp];
        export.loss  = [export.loss;  loss];
        export.normg = [export.normg; normGL];
        export.accr  = [export.accr;  accr];
        if debug > 0
            fprintf('Ep. %05d | G %g | Eta %g | N.Imp %05d | Loss %g | Acc %.1f%%\n',...
                epoch, normGL, eta, nimp, loss, 100 * accr);
        end
    end
    if (epoch >= param.maxIter) || (normGL < param.vanish)
        break;
    end
end

function [loss, grad, nimp] = computeLossGrad(LxTr, xTr, yTr, idx, L, param)
    % Set return variables
    loss = 0;
    grad = zeros(size(L));
    nimp = 0;
    % Init
    N    = size(LxTr,2);
    Ns   = size(idx,2);
    LXs  = LxTr(:,idx);
    %% Compute a matrix [Ns x N] of distances from samples to data
    D   = repmat(sum(LXs .* LXs,1)',1,N)...
        + repmat(sum(LxTr .* LxTr,1),Ns,1)...
        - 2 * LXs' * LxTr;
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
        % Gradient from targets (pull)
        Gtrg  = repmat(xTr(:,idx(i)),1,Ntrg) - xTr(:,I(i,iTrg));
        LGtrg = L * Gtrg;
        Gpull = LGtrg * Gtrg';
        % Gradient from impostors (push)
        Gimp  = repmat(xTr(:,idx(i)),1,Nimp) - xTr(:,I(i,iImp));
        LGimp = L * Gimp;
        Tmp1  = repmat(Gtrg,1,1,Nimp);
        LTmp1 = repmat(LGtrg,1,1,Nimp);
        Tmp2  = permute(repmat(Gimp,1,1,Ntrg), [1 3 2]);
        LTmp2  = permute(repmat(LGimp,1,1,Ntrg), [1 3 2]);
        Isel  = H>0;
        Tmp1  = Tmp1(:,Isel);
        LTmp1 = LTmp1(:,Isel);
        Tmp2  = Tmp2(:,Isel);
        LTmp2 = LTmp2(:,Isel);
        Gpush = LTmp1 * Tmp1' - LTmp2 * Tmp2';
        grad = grad + (1-param.mu)*Gpull + param.mu*Gpush;
    end
    R = param.gamma * (L'*L - eye(size(L,2)));
    loss = loss + trace(R*R');
    if ~isempty(xTr)
        grad = grad + 2*(L*R);
    end
end

end
