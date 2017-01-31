function draw_depth_skeleton_images(depth, skl, pathDir)
% Save one PNG image for each frame.  This jpeg image contains
% the depth image (in background) and the skeleton in the first plane.

h = size(depth,1);
w = size(depth,2);
nframes = size(depth,3);
if nframes ~= size(skl,3)
    warning('Number of frames in depth (%d) != frames in skel (%d)\n',...
        nframes, size(skl,3));
    nframes = min(nframes, size(skl,3));
end

cpal = [0.1 0.6 0.0];
lpal = [1.0 0.3 0.1];

for f = 1:nframes
    %% For each frame, do
    S = skl(1:2,:,f) + 1;
    S = bsxfun(@times, S, [w/2; h/2]);
    S = S-1;
    S(2,:) = h - S(2,:);
    mmax = max(max(depth(:,:,f)));
    depthImg = depth(:,:,f) / mmax;
    fname = sprintf('%s/%05d.png', pathDir, f);
    RGBImg = zeros(h, w, 3);
    %% Convert this depth image to a gray RGB image
    RGBImg(:,:,1) = depthImg;
    RGBImg(:,:,2) = depthImg;
    RGBImg(:,:,3) = depthImg;
    %% Draw the 20 points from this skeleton
    for j = 1:20
        RGBImg = draw_rgb_circle(RGBImg, S(1,j), S(2,j), 2.8, cpal);
    end
    %% Draw the main lines of the skeleton
    RGBImg = draw_rgb_skeleton_segments(RGBImg, S, 1:4, lpal);
    RGBImg = draw_rgb_skeleton_segments(RGBImg, S, [3 5:8], lpal);
    RGBImg = draw_rgb_skeleton_segments(RGBImg, S, [3 9:12], lpal);
    RGBImg = draw_rgb_skeleton_segments(RGBImg, S, [1 13:16], lpal);
    RGBImg = draw_rgb_skeleton_segments(RGBImg, S, [1 17:20], lpal);
    imwrite(RGBImg, fname);
end
