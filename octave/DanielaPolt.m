#octave
NPoint = 41;
tx = ty = linspace (-4.*pi, 4.*pi, NPoint)';
[xx, yy] = meshgrid (tx, ty);
tz = tanh((xx-yy)*.5)+tanh(yy)*.5+tanh(-xx*.5);
mesh (tx, ty, tz);
print -deps Tanh.eps
