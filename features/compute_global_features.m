function globFeat = compute_global_features(locFeat, assign, clusters, winN)
% Compute global features

interStep = 5;

nASE = size(locFeat);
nProjections = size(locFeat,4);
globFeat = cell(nASE);
for a = 1:nASE(1)
    for s = 1:nASE(2)
        for e = 1:nASE(3)
            for p = 1:nProjections
                if isempty(locFeat{a,s,e,p})
                    continue;
                end
                %% Compute VLAD splitting the input samples
                X = locFeat{a,s,e,p};
                A = assign{a,s,e,p};
                nLocFeat = size(X,2);
                nGlobFeat = max(1, int32((nLocFeat-winN)/interStep));
                F = zeros(size(X,1) * size(clusters, 2), nGlobFeat);
                for i = 1:nGlobFeat
                    k = i + (i-1) * interStep;
                    j = min(k+winN-1,nLocFeat);
                    F(:,i) = vlad(X(:,k:j), A(k:j), clusters);
                end
                globFeat{a,s,e,p} = F;
            end
        end
    end
end
