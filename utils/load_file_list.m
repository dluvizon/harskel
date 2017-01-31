function list = load_file_list(fname, template, nelem)
% Load a file list, convert it to a matrix and return.
%
% PARAMETERS
%    fname : File name containing the list.
% template : Template for each line, e.g. 'a%d_s%d_e%d\n'
%    nelem : Number of elements in one line, e.g. 3
% RETURN
%     list : A matrix [nelem x N], where N is the number of
%            lines in the file.

fp = fopen(fname);
if ~fp
    error('Could not open file "%d"\n', fname);
end
tmp = fscanf(fp, template);
fclose(fp);
N = size(tmp, 1) / nelem;
list = reshape(tmp, nelem, N);