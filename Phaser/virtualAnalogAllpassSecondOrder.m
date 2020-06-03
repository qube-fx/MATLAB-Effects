function y  = virtualAnalogAllpassSecondOrder(x, fn, fs, r)
b(1) = r^2;
b(2) = -2*r*cos(2*pi*fn/fs);
b(3) = 1;
a(1) = 1;
a(2) = -2*r*cos(2*pi*fn/fs);
a(3) = r^2;
y = filter(b,a,x);
end