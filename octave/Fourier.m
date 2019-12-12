for i = 1:1000; x(i) = sin(i/1000*360*4) ; endfor
y = fft(x);
z = ifft(y);
load('Ondulate.dat')
z = Ondulate([1:length(Ondulate);1],3);
w = fft2(z);
