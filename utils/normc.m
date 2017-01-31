function x = normc(x)
x = x ./ (sum(abs(x).^2).^0.5);