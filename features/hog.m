function H = hog(skeletons, template, weight)

if nargin ~= 3
    weight = 1:20;
end
nf = size(skeletons, 3);    % Num. of frames
nj = size(skeletons, 2);    % Num. of joints
nbins = size(template,2);
H = zeros(nbins,nj);
for i = 2:nf
    if ~check_skeleton(skeletons(:,:,i)) || ~check_skeleton(skeletons(:,:,i-1))
        % This skeleton is not good.
        continue;
    end
    for j = 1:nj
        v = skeletons(:,j,i) - skeletons(:,j,i-1);
        if weight(j) > 0
            normV = weight(j) * norm(v);
        else
            continue;
        end
        v = v / norm(v);
        nv = zeros(1,nbins);
        for b = 1:nbins
            nv(b) = v' * template(:,b);
        end
        [~,I] = sort(nv, 'descend');
        bin = I(1);
        H(bin,j) = H(bin,j) + normV;
    end
end
H = H(:);
