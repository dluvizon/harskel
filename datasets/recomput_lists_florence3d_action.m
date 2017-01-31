function recomput_lists_florence3d_action(celllist, SubTest)

global par;
global debug;

nASE = size(celllist);
par.listTe = [];
par.listTr = [];
for a = 1:nASE(1)
    for s = 1:nASE(2)
        for e = 1:nASE(3)
            if isempty(celllist{a,s,e})
                continue;
            end
            if s == SubTest
                par.listTe = [par.listTe [a;s;e]];
            else
                par.listTr = [par.listTr [a;s;e]];
            end
            if debug > 1
                fprintf('a%02d_s%02d_e%02d\n', [a s e]);
            end
        end
    end 
end