set size .4,.6;
unset border;
#--------------PhasePV--------------------
f(x) = a*x**3+b*x**2+c*x;a=1.;b=-5.;c=1.;
set arrow from 0,0 to 6,0 nohead;
set xlabel '$\rho$';
set ylabel '$P_s-P_m$';
set label '$\rho_c$' at 5,-.2;
unset xtics;
unset ytics;
set term latex;
set output 'Graph/PhasePV.tex';
plot [0:6][-20:20] f(x) title '';
unset arrow
unset label;
#-------------Sample-Weighting-Function-------------------
set size .2,.3;
f(x) = x<1?1 - x:0;
set xlabel '$r$'
set ylabel '$w(r)$'
set arrow from 0,0 to 1.2,0;
set arrow from 0,0 to 0,1.2;
set label '$r_c$' at 1,.1;
set label '$1$' at -.2,1;
set term latex;
set output 'Graph/WeightingFunction.tex';
plot [0:1.2][0:1.2] f(x) title '';
unset arrow;
unset label;
#-------------------Potential---------------------------------
f(x) = x > .6*r? (r/x)**12 - (r/x)**6:-100.*x +1000.* (1.+.6*r);r=2.;
set xlabel '$r$'
set ylabel '$U(r)$'
set arrow from 0,0 to 8.,0;
set arrow from 0,0 to 0,2100;
set label '$r_c$' at 3*r,10;
set term latex;
set output 'Graph/Potential.tex';
#set size square .4,.6;
set multiplot ;
set size square .4,.6;
set origin 0,0;
plot [0:8][-1:] f(x) title '';
unset label;
unset xlabel;
unset ylabel;
unset arrow;
r = 1;
set arrow from 0,0 to 4.,0;
set arrow from 0,0 to 0,1;
set label '$r_0$' at r,.1;
set label '$\epsilon$' at 1.3,-.25;
set size square .4,.4;
set origin .065,.15;
plot [0:4][-.4:1] f(x) title '';
unset multiplot;
unset arrow;
unset label;
#-------------------Cylinder-----------------------------
set output 'ProjectionCyl2_5.tex';
plot [27:57][0:30] 'ProjectionCyl2_5.xyz' u 1:2 title '';
