function f = concat_features(X, param)
% Cancatenate features.
%
% param:
%       .powerLaw
%       .doPCA
%       .doPCAPar
%       .doNorm
%       .listTr

global tm

%% Concatenate features given the weights W
tmpD = [];
prvList = [];
for k = 1:numel(X)
    [xd,xlist] = serialize(X{k});
    if ~isempty(prvList)
        if sum(sum(prvList ~= xlist)) > 0
            error('Features %d and %d not matching for all samples!',...
                k-1, k);
        end
    end
    tmpD = [tmpD; xd];
    prvList = xlist;
end

tic;
if param.powerLaw
    tmpD = sign(tmpD) .* (abs(tmpD) .^ param.powerLaw);
end
if param.doNorm
    tmpD = normc(tmpD);
end
if param.doPCA
    tmpD = pca(tmpD, param.doPCAPar);
end
tm.featAgg = tm.featAgg + toc;

f = deserialize(tmpD, xlist);
