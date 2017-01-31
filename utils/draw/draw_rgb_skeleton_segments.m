function I = draw_rgb_skeleton_segments(I, S, seg, rgb)

for i = 1:(length(seg)-1)
    k = seg(i);
    w = seg(i+1);
    I = draw_rgb_line(I, [S(1,k), S(2,k)], [S(1,w), S(2,w)], rgb);
end
