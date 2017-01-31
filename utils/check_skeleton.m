function isok = check_skeleton(skeleton)
isok = false;
if isempty(skeleton)
    return;
end
Npoints = size(skeleton, 1);
skeleton = reshape(skeleton, Npoints, []);
if sum(max(skeleton) == 0)
    return;
end
isok = true;