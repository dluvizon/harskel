function desc = displacement_vectors(skel, sIndex, i1, i2)
desc = [];
if ~check_skeleton(skel(:,:,i1)) || ~check_skeleton(skel(:,:,i2))
    % At least one of these skeletons are not good.
    return;
end
Nj = size(skel,2);
desc = zeros(3,Nj);
for j = 1:Nj
    dT = sIndex(i2) - sIndex(i1);
    desc(:,j) = (skel(:,j,i1) - skel(:,j,i2)) / dT;
end
desc = reshape(desc,[],1);