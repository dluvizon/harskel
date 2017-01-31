function [data, list] = serialize(cellarray, varargin)
% Serialize a cellarray to a matrix.
% Each cell element is [d x N]. 'd' can vary from element to element, but
% each cell element must have the same number of columns 'N'.

assert(iscell(cellarray));
elem = size(cellarray);
nProj = size(cellarray,4);
elem = elem(1:3);
posi = prod(elem);

if isempty(varargin)
    %% If varargin is empty, construct a full list of samples to serialize
    opts = zeros(posi, size(elem,2));
    i = size(elem,2);
    for e = elem(end:-1:1)
        nr = posi / e;
        tmp = repmat((1:e)', nr, 1);
        opts(:,i) = tmp;
        opts = sortrows(opts, i);
        i = i - 1;
    end
    opts = opts';
else
    %% Otherwise, use the user input
    opts = varargin{1};
end
data = [];
list = [];
%% For each input in the list in the form []
for j = opts
    for p = 1:nProj
        if isempty(cellarray{j(1),j(2),j(3),p})
            continue
        end
        s1 = size(data,2) + 1;
        s2 = s1 - 1 + size(cellarray{j(1),j(2),j(3),p},2);
        data = [data cellarray{j(1),j(2),j(3),p}];
        list = [list; [j(1) j(2) j(3) p s1 s2]];
    end
end