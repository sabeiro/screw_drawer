set logscale x
set logscale y
set fit logfile "ciccia.dat"
f(x) = 1./(a1*x*x) + .5/(b1*x + c1);a1=12.5342;b1=-0.207808;c1=17.4283;
b1 = -0.207808 # FIXED
fit [0.002:] log(f(x)) 'SpectrumFile' u 1:(log($2)) via a1,b1,c1
#p 'SpectrumFile' u 1:(log($2))  w l, f(x)
g(x) = 1./(a*x*x - 4.*a*d*x + e) + .5/(b*x + c);a=a1;b=b1;c=c1;d=0.137106;e=7.86324;
fit [0.002:] log(g(x)) 'SpectrumFile' u 1:(log($5)) via d,e
fit [0.002:] log(g(x)) 'SpectrumFile' u 1:(log($5)) via a,b,c,d,e
set term post
set output 'SpectrumFile.ps'
p [0.01:] 'SpectrumFile' u 1:2 , 'SpectrumFile' u 1:5 , f(x) , g(x)
print "k_ben ", a, " k_lambda ", b, " gamma ", c, " zeta ", d, " k_el ", e
print "k_ben ", a1, " k_lambda ", b1, " gamma ", c1
