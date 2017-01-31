function skeletons = scale_skeletons(skeletons)
% Scale each skeleton

nASE = size(skeletons);
for a = 1:nASE(1)
    for s = 1:nASE(2)
        for e = 1:nASE(3)
            S = skeletons{a,s,e};
            if isempty(S)
                continue;
            end
            topNeck = reshape(S(:,2,:),3,[]);
            maxNeck = max(topNeck(2,:));
            
            bottomFoot1 = reshape(S(:,13,:),3,[]);
            bottomFoot2 = reshape(S(:,10,:),3,[]);
            minFoot = min([bottomFoot1(2,:) bottomFoot2(2,:)]);
            ScaleFactor = 3 * (maxNeck - minFoot);
            skeletons{a,s,e} = S ./ ScaleFactor;
        end
    end
end