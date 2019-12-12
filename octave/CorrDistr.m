function y = f(x);
  for i = 1:length(x);
    if (x(i) > 0. && x(i) < 1.) y(i) = 1.;
    else y(i) = 0.;
    endif
  endfor
endfunction

x = 0.:.01:2.;
corr = f(x);
step = 2./length(x);
NSample = length(x);
sw = fft(y,NSample);
spe = sw.*conj(sw)/(NSample*step);
sw1 = sqrt(spe(1:NSample/2)).*randg(1:NSample/2);
plot (1:NSample/2,sw1);
st = fft(sw1,NSample/2);
st1 = sqrt(st.*conj(st)/(NSample*step));
histo = hist(st1,20);
