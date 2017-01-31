function lX = transLin(L,X)

X = bsxfun(@minus, X, mean(X,2));
lX = L*X;