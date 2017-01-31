function [cellarray] = deserialize(data, list)
% De-serialize a matrix (with its corresponding list) into a
% cell array. See the function lvz_serialize().

cellarray = {};
for j = list'
    cellarray{j(1),j(2),j(3),j(4)} = data(:,j(5):j(6));
end