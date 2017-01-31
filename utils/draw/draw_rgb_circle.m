function I = draw_rgb_circle(I, x, y, r, rgb)
% Draw a circle in the RGB image (I), at position (x,y),
% radios (r) and color (rgb).

np = 7*r;
t = linspace(0, 2*pi, np)';
h = size(I, 1);
w = size(I, 2);
x = max(x, ceil(r+1));
y = max(y, ceil(r+1));
x = min(x, ceil(w-r-1));
y = min(y, ceil(h-r-1));
cx = int32(r.*cos(t) + x);
cy = int32(r.*sin(t) + y);
rgb = rgb(:);
for i = 1:np
    I(cy(i),cx(i),:) = rgb;
end
