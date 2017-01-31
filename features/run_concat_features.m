function finalFeatures = run_concat_features(globFeatures, pcaFix, save)

global outdir
global par

nASE  = size(globFeatures{1});
nProj = size(globFeatures{1},4);
nRuns = size(globFeatures,1);
nFeat = size(globFeatures,2);
finalFeatures = [];

W = zeros(1,nFeat);
for nf = 1:nFeat
    W(nf) = eval_loocv(globFeatures{1,nf}, par.listTr, par.knn, par.topN);
end
W = W / norm(W);

for r = 1:nRuns
    concatFeatTmp = cell(nASE);
    for nf = 1:nFeat
        for a = 1:nASE(1)
            for s = 1:nASE(2)
                for e = 1:nASE(3)
                    for p = 1:nProj
                        if isempty(globFeatures{r,nf}{a,s,e,p})
                            continue;
                        end
                        F = W(nf) * globFeatures{r,nf}{a,s,e,p};
                        concatFeatTmp{a,s,e,p} = [concatFeatTmp{a,s,e,p}; F];
                    end
                end
            end
        end
    end
    [D,list] = serialize(concatFeatTmp);
    D = sign(D) .* (abs(D) .^ 0.5);
    D = normc(D);
    D = pca(D, pcaFix);
    finalFeatures = [finalFeatures; D];
end
finalFeatures = deserialize(finalFeatures,list);

if save
    class = classify_knn(finalFeatures, par.listTr, par.listTe, par.knn, par.topN);
    [~, accr] = show_results(class, par.actions);
    fprintf('perf: %f\n', accr);
    savevar([outdir.data '/finalFeatures'], finalFeatures);
end
