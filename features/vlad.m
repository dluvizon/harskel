function index = vlad(locFeatList, assign, clusters)

[D,m] = size(clusters);
T = zeros(D,m);
for i=1:m
    sel = assign == i;
    X = locFeatList(:,sel);
    Xi = zeros(D,1);
    if sum(sel)>0
        Xi = sum(X, 2) - sum(sel)*clusters(:,i);
    end
    T(:,i) = Xi;
end
index = reshape(T, 1, D*m);