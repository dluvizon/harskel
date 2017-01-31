function [result, final] = show_results(cClass, classes)
% Plot the results of classification.

global debug

ns = length(cClass);
nClass = length(classes);
resultTotal = zeros(nClass);
for i = 1:ns
    if isempty(cClass{i}.class)
        % Discard empty testing samples
        continue
    end
    [~, it] = max(classes == cClass{i}.ase(1));
    sel = cClass{i}.class == cClass{i}.ase(1);
    if sum(sel) > 0
        [~, iy] = max(classes == cClass{i}.class(sel));
    else
        [~, iy] = max(classes == cClass{i}.class(1));
    end
    resultTotal(it,iy) = resultTotal(it,iy) + 1;
end
rowsSum = sum(resultTotal, 2);
result = bsxfun(@rdivide, resultTotal, rowsSum);
if debug > 1
    figure;
    imshow(result, 'InitialMagnification', 'fit');
    colormap(jet);
end
pos = trace(resultTotal);
tot = sum(resultTotal(:));
final = pos / tot;
if debug > 1
    fprintf('Final result: (%d / %d)  %.1f%%\n', pos, tot, 100 * final);
end