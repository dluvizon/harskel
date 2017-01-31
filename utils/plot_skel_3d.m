function plot_skel_3d(skel, setAxis, az, al)

skel = skel';
scatter3(skel(:,1), skel(:,3), skel(:,2), 'filled', 'r');
hold on;
grid off;
axis equal;
if nargin > 1
    view(az, al);
    axis(setAxis);
else
    rotate3d on;
end

if size(skel,1) == 15
    % Skeleton with 15 joints
    segs = [1 2 2 4 5 2 7 8  3  3 10 11 13 14;  
            2 3 4 5 6 7 8 9 13 10 11 12 14 15];
elseif size(skel,1) == 20
    % Skeleton with 15 joints
    segs = [ 1 2 3 3 5 6 7 3  9 10 11  1 13 14 15  1 17 18 19;
             2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
else
    error('Unknown skeleton with %d joints.', size(skel,1));
end

for s = segs
    line(skel(s, 1), skel(s, 3), skel(s, 2));
end
hold off;