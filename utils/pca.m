function [D,L] = pca(X, varargin)
% Do PCA in data X [dim x N].
%
%        File: pca.m
%       Usage: [X,L] = pca(X, userPar=[]);
% Description: Apply PCA in X, optional parameter userPar:
%                  - If userPar is from [1:Inf.], use as output size (outDim).
%                  - If userPar is from [0:1[, use as information to
%                  discard.
%                  - If userPar is empty, do not reduce the output size.
%              Return the tansformed data in D and the transformation
%              matrix L, such as D = L * (X - mat(mean(X))).
%      Author: Diogo Luvizon <diogo.luvizon@ensea.fr>

global debug
%% Transpose input data
X = X';

[~,dim] = size(X);
outDim = dim;

%% Subtract the average in each dimension
X = bsxfun(@minus, X, mean(X));

%% Compute covariance matrix and sort the eigenvectors and eigenvalues
covMat = cov(X);
[V,D] = eig(covMat, 'vector');
[latent,I] = sort(D, 'descend');

%% Check if the output dimension was set in varargin
if ~isempty(varargin)
    userPar = varargin{1};
    if userPar >= 1
        outDim = userPar;
    else
        latent = latent / sum(latent);
        l = cumsum(latent);
        outDim = sum(l < (1 - userPar));
    end
    if debug
        fprintf('pca: reduce features size from %d to %d\n', dim, outDim);
    end
end
outDim = min(outDim, size(I,1));
I = I(1:outDim);
L = V(:,I);

%% Transpose the output matrix L and compute the output data D
L = L';
D = L * X';

