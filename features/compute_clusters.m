function [C, assign, cellDataNorm] = compute_clusters(X, par)
% Compute clusters.

global tm

%% Load parameters
k        = par.kmeansK;
doPCA    = par.clusterPCA;
doNorm   = par.clusterNorm;
powerLaw = par.clusterAlpha;

global debug

%% Serialize data
tic;
[data, slist] = serialize(X);
if debug > 1
    fprintf('K-means: size of data matrix: %d x %d\n', size(data));
end
tm.featAgg = tm.featAgg + toc;

[C, ~, energy] = vl_kmeans(data, k,...
    'Distance', 'L2',...
    'Initialization', 'plusplus',...
    'NumRepetitions', 1);

tic;
forest = vl_kdtreebuild(C);
A = vl_kdtreequery(forest, C, data);

if debug > 2
    fprintf('lv_kmeans energy: %.0f\n', energy);
end

%% Do PCA and normalize data individually for each cluster, if set
for c = 1:k
    i = find(A == c);
    if powerLaw
        data(:,i) = sign(data(:,i)) .* (abs(data(:,i)) .^ powerLaw);
    end
    if doPCA
        data(:,i) = pca(data(:,i));
    end
    if doNorm
        data(:,i) = normc(data(:,i));
    end
end

%% Return the assignments and the normalized data
assign = deserialize(A, slist);
cellDataNorm = deserialize(data, slist);
tm.featAgg = tm.featAgg + toc;