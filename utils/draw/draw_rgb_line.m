function I = draw_rgb_line(I, p1, p2, rgb)
% Draw a line in image (I) from point p1([x,y]) to point p2([x,y]) in RGB.

w = size(I, 2);
h = size(I, 1);
if max([p1 p2] < 1) || max([p1(1) p2(1)] >= w) || max([p1(2) p2(2)] >= h)
    return
end
if p1 == p2
    return
end

rgb = rgb(:);
if abs(p1(1) - p2(1)) > abs(p1(2) - p2(2))
    if p2(1) < p1(1)
        aux = p1;
        p1 = p2;
        p2 = aux;
    end
    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);
    for x = p1(1):p2(1)
        y = int32(p1(2) + (x - p1(1)) * dy / dx);
        xi = int32(x);
        I(y,xi,:) = rgb;
    end
else
    if p2(2) < p1(2)
        aux = p1;
        p1 = p2;
        p2 = aux;
    end
    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);
    for y = p1(2):p2(2)
        x = int32(p1(1) + (y - p1(2)) * dx / dy);
        yi = int32(y);
        I(yi,x,:) = rgb;
    end
end
