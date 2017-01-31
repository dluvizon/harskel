function globFeatures = run_global_features(kmeans, nruns, winN, save)
% Compute global features

%% Load global parameters, seted up by the setup.m script
global outdir;

locFeatJoint1 = loadvar(sprintf('%s/locFeatures_RP', outdir.data));
locFeatJoint2 = loadvar(sprintf('%s/locFeatures_DV', outdir.data));

nFeat = numel(locFeatJoint1) + numel(locFeatJoint2);
globFeatures = cell(nruns,nFeat);
for r = 1:nruns
    cnt=0;
    for nf = 1:numel(locFeatJoint1)
        cnt = cnt+1;
        Aux = sprintf('%02d', cnt);
        [C, assign, f] = compute_clusters(locFeatJoint1{nf}, kmeans, Aux, 1);
        F = compute_global_features(f, assign, C, winN);
        globFeatures{r,cnt} = F;
    end
    for nf = 1:numel(locFeatJoint2)
        cnt = cnt+1;
        Aux = sprintf('%02d', nf);
        [C, assign, f] = compute_clusters(locFeatJoint2{nf}, kmeans, Aux, 1);
        F = compute_global_features(f, assign, C, winN);
        globFeatures{r,cnt} = F;
    end
end

if save
    savevar([outdir.data '/globFeatures'], globFeatures);
end
