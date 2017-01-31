function [listTr, listTe] = select_subject_loocv(allSamples, SubTest)

listTe = allSamples(:,allSamples(2,:) == SubTest);
listTr = allSamples(:,allSamples(2,:) ~= SubTest);
