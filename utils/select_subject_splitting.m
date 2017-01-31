function [listTr, listTe] = select_subject_splitting(allSamples, TrSubj)

listTr = [];
for s = TrSubj
    listTr = [listTr allSamples(:,allSamples(2,:) == s)];
    allSamples(:,allSamples(2,:) == s) = [];
end
listTe = allSamples;
