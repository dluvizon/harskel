function acc = eval_loocv(feat, listTr, knn)
% Test in the LOOCV approach

cnt = zeros(1,2);
for it = 1:size(listTr,2)
    listTe = listTr(:,it);
    listCr = listTr;
    listCr(:,it) = [];
    class = classify_knn(feat, listCr, listTe, knn);
    if class{1}.class == class{1}.ase(1)
        cnt(1) = cnt(1) + 1; 
    end
    cnt(2) = cnt(2) + 1;
end
acc = cnt(1) / cnt(2);