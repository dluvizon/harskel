function skels2csv()
global outdir;
global par;

S = loadvar([outdir.data '/' par.skelMat '_pp']);
writeCSV(par.listTe, outdir.te, S);
writeCSV(par.listTr, outdir.tr, S);

function writeCSV(list,dir,S)
    for t = list
        a = t(1);
        s = t(2);
        e = t(3);
        if isempty(S{a,s,e})
            continue
        end
        skel = S{a,s,e};
        nAxis = size(skel,1);
        nJoints = size(skel,2);
        fname = sprintf('%s/skel_%02d_%02d_%02d.csv', dir, a, s, e);
        tmp = reshape(skel, nAxis*nJoints, []);
        csvwrite(fname, tmp');
    end
end
end