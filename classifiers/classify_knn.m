function cdist = classify_knn(cellX, listTr, listTe, knn)

global debug

cdist = cell(1,size(listTe, 2));
%% For each test sample
i = 1;
for iTe = listTe
    if debug > 1
        fprintf('Classifying sample a%02d_a%02d_a%02d\n', iTe);
    end
    [c,d] = classify(cellX, iTe, listTr, knn);
    cdist{i}.ase = iTe;
    cdist{i}.class = c;
    cdist{i}.dist = d;
    if (debug > 1) && (c ~= iTe(1))
        fprintf('\t\t\t\tmiss: [%03d] :: (%02d) a%02d_s%02d_e%02d\n', i, c, iTe);
    end
    i = i+1;
end

%% Classify one test sample 'iTe', given the trainning list 'listTr'.
function [class, dist] = classify(cellX, iTe, listTr, knn)
    % Initialize variables to return;
    dist = [];
    nProj = size(cellX,4);
    class = [];
    target = cellX{iTe(1),iTe(2),iTe(3),1};
    if isempty(target)
        if debug > 1
            warning('Target empty: a%02d_s%02d_e%02d\n!', iTe);
        end
        return;
    end
    dist = zeros(nProj * size(listTr,2), 4);
    is = 1;
    for t = listTr
        for p = 1:nProj
            neighbor = cellX{t(1),t(2),t(3),p};
            if isempty(neighbor)
                dist(is,:) = [];
                continue;
            end
            dist(is,1) = closest_dist2(target, neighbor);
            dist(is,2:4) = t;
            is = is + 1;
        end
    end
    % Sort the list in 'descend' mode according to the distance value
    dist = sortrows(dist,1);
    % Select the 'knn' closest elements
    class = find_neighboors(dist(1:knn,2), 1);
end

%% Return the closes dir from column vector x1 [d x 1] and matrix xM [d x M]
function d = closest_dist2(x1, xM)
    d = Inf;
    for l = 1:size(xM,2)
        dtmp = dist2(x1,xM(:,l));
        if dtmp < d
            d = dtmp;
        end
    end
end

function class = find_neighboors(closest, topN)
    class = [];
    for t = 1:topN
        if isempty(closest)
            return
        end
        [~,~,C] = mode(closest);
        if size(C{1},1) > 1
            %% In case of tied, choose the closest one
            for ic = closest'
                if sum(ic == C{1})
                    votes = ic;
                    break;
                end
            end
        else
            votes = C{1};
        end
        c = mode(votes);
        class = [class c];
        idx = ~(closest == c);
        closest = closest(idx);
    end
end

end