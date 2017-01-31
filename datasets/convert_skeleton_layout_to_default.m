function skeleton = convert_skeleton_layout_to_default(skeleton)
%        File: convert_skeleton_layout_to_default.m
%       Usage: skeleton = convert_skeleton_layout_to_default(skeleton);
% Description: For some unknown reason, there are, at least, two
%              skeleton layouts. One, consedering here as the 'default',
%              can be found in the 3D Online Action Dataset from MSR, and
%              follows this image: << http://research.microsoft.com/en-us/um
%              /people/zliu/actionrecorsrc/SkeletonModelMSRActivity3D.jpg >>
%              The other one, can be found in the MSR_Action3D_Dataset.
%              In this function, we convert the MSR_Action3D_Dataset skeleton
%              to the 'defatult' layout.
c = [7 4 3 20 1 8 10 12 2 9 11 13 5 14 16 18 6 15 17 19];
skeleton = skeleton(:,c,:);
