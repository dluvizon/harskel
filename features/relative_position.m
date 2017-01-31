function desc = relative_position(S, full)
desc = [];
%% Check for inconsistencies in skeleton joints
if ~check_skeleton(S)
    % This skeleton is not good.
    return;
end    
% 'S' is a single skeleton with 20 joints
if full
    desc = zeros(3,20*19/2);
    cnt = 1;
    for i = 1:19
        for j = (i+1):20
            desc(:,cnt) = S(:,j) - S(:,i);
            cnt = cnt+1;
        end
    end
else
    desc = zeros(3,19);
    for i = 2:20
        desc(:,i-1) = S(:,i) - S(:,1);
    end
end
desc = reshape(desc,[],1);