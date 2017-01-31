function anime_skel_3d(skel)

% skel = skel/1e3;
setAxis=[...
    min(reshape(skel(1,:,:),[],1))...
    max(reshape(skel(1,:,:),[],1))...
    min(reshape(skel(3,:,:),[],1))...
    max(reshape(skel(3,:,:),[],1))...
    min(reshape(skel(2,:,:),[],1))...
    max(reshape(skel(2,:,:),[],1))];
nFrames = size(skel,3);
f = 1;
while true
    plot_skel_3d(skel(:,:,f), setAxis, 10, 15);
    pause(1/10);
    f = f+1;
    if f > nFrames
        f = 1;
    end
end
