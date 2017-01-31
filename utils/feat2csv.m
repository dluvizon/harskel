function feat2csv(X, list, outpath)

outpath = init_dir(outpath);
for l = list
    a = l(1);
    s = l(2);
    e = l(3);
    if isempty(X{a,s,e})
        continue
    end
    fname = sprintf('%s/%02d%02d%02d00.csv', outpath, a, s, e);
    csvwrite(fname, X{a,s,e});
end
