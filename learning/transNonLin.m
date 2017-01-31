function Z = transNonLin(W,b,X)
Z = max(0,bsxfun(@minus, W*X, b));