function skels = rotate_all_skeletons(skels)
% Center each skeleton

nASE = size(skels);
for a = 1:nASE(1)
    for s = 1:nASE(2)
        for e = 1:nASE(3)
            S = skels{a,s,e};
            if isempty(S)
                continue;
            end
            nFrames = size(S,3);
            for f = 1:nFrames
                centerHip = reshape(S(:,1,f),3,[]);
                S = bsxfun(@minus,S,centerHip);
                rightHip = reshape(S(:,13,f),3,[]);
                leftSHip = reshape(S(:,10,f),3,[]);
                vectHip = leftSHip - rightHip;
                vectHip(2) = 0;
                vectHip = normc(vectHip);
                ang = -acos(vectHip' * [1;0;0]);
                R = [cos(ang) 0 sin(ang); 0 1 0; -sin(ang) 0 cos(ang)];
                S(:,:,f) = R * S(:,:,f);
            end
            skels{a,s,e} = S;
        end
    end
end