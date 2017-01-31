function path = init_dir(path)
%----------------------------------------------------------------------------
%        FILE: init_dir.m
%       USAGE: path = init_dir(path);
% DESCRIPTION: Check if the directory pointed by path exist and create it
%              if needed. Warning: this function does no create directories
%              recursively.
%      AUTHOR: Diogo Luvizon <diogo.luvizon@ensea.fr>
%----------------------------------------------------------------------------
isdir = exist(path, 'dir');
if ~isdir
    mkdir(path);
end