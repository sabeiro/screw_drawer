#theta = unifrnd(0.,2.*pi,10000,1);
#rad   = .5 + unifrnd(0.,1.,10000,1).^(1./3.);
#ran   = unifrnd(-1.,1.,10000,1);
# x = rad.*sqrt(1.0 - ran.^2).*cos(theta);
# y = rad.*sqrt(1.0 - ran.^2).*sin(theta);
# z = rad.*ran;
# #plot3(x,y,z,".")
# NBins = 40;
# RadBin = linspace(.5,1.5,NBins+1);
# for b=1:NBins	
#     norm(b) = 4.*pi/3.*(RadBin(b+1)^3 - RadBin(b)^3);
# endfor
# dist = sqrt( x.*x .+ y.*y .+ z.*z);
# histo = hist(dist,NBins);
# plot(histo./norm);


function Rand = ProbVal(Random,Prob);
Cum = 0.;
for i=i:length(Prob)
    Cum += Prob(i);
    if(Random < Cum)
    Rand = i;
    last ;
    endif
endfor
endfunction


NBins = 100;
NRand = 1000;
x = linspace(0.0,1.0,NBins);
Rand = linspace(0.0,1.0,NBins);
Prob = sin(x*pi/6.0);
Random = unifrnd(0.,1.,NRand,1);
for i = 1:NRand
    Rand(i) = ProbVal(Random(i),Prob);
endfor
plot(x,Prob,Rand);
