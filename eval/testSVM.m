clearvars;
setup;
global par;
global outdir;

%% Load features
X = loadvar([outdir.data '/feat_MSRAction3D_0003']);

%% Use the previews metric learned
% L1 = loadvar([outdir.data '/L1_MSRAction3D_0003_0000']);
% L2 = loadvar([outdir.data '/L2_MSRAction3D_0003_0000']);
% L = L2*L1;
% [Z,list] = serialize(X);
% X = deserialize(L*Z, list);

[xTe,listTe] = serialize(X, par.listTe);
[xTr,listTr] = serialize(X, par.listTr);
yTe = listTe(:,1)';
yTr = listTr(:,1)';
nY = size(yTe,2);

class = classify_knn(X, par.listTr, par.listTe, par.knn);
[M, accr] = show_results(class, par.actions);

%% LIBSVM: http://www.csie.ntu.edu.tw/~cjlin/libsvm/

Inst = xTr';
Labs = yTr';
Targ = yTe';
Test = xTe';

svmpars = sprintf('-s 0 -t 3 -g 1 -r 0 -c 10 -q');
model = svmtrain(Labs, Inst, svmpars);
yPred = svmpredict(Targ, Test, model);
if size(yPred,1) == size(Targ,1)
    Acc = sum((yPred == Targ)) / nY;
    fprintf('Acc: k-NN (%f) / (SVM) %f\n', accr, Acc)
end
