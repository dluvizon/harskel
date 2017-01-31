function data = loadvar(filename)

data = [];
load(filename);
if isempty(data)
    error('File "%s" does not contains any variable "data".', filename);
end