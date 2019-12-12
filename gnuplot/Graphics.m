set size .4,.6;
unset border;
set term latex;
#--------------PhasePV--------------------
f(x) = a*x**3+b*x**2+c*x;a=1.;b=-5.;c=1.;
set arrow from 0,0 to 6,0 nohead;
set xlabel '$\rho$';
set ylabel '$P_s-P_m$';
set label '$\rho_c$' at 5,-.2;
unset xtics;
unset ytics;
set output 'PhasePV.tex';
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
set output 'WeightingFunction.tex';
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
set output 'Potential.tex';
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
set border;
set xtics;
set ytics;
set pointsize .1;
set output 'ProjectionCyl2_5.tex';
plot [27:57][0:30] 'ProjectionCyl2_5.xyz' u 1:2 title '' with point 2;
set term post;
set output 'ProjectionCyl2_5.ps';
set size 1,1;
replot;
set term latex;
set size .4,.6;
unset border;
#-------------------Sphere-----------------------------
#f(x) = a * (3./(2.-3.*sin(x)+sin(x)**3.))**1.33*cos(x)**4 - ips;
#  a=.17;
#  ips=25.19;
# #g(x) = a*x + b; a = 1.;b = 0. ;
# h(x) = x<r ? -sqrt( r**2 - x**2 ) + c : c ; r = 21.; c=39.;
#  fit h(x) '../Tropf/RadialShell.xye' u 1:2:3 via r,c ;
#  angle = atan( 14.28/sqrt(r**2 - 14.28**2) )/pi*180;
#  print angle;
# ## set title 'Contact Angle fit 76. -- cm/V 68.35q  Hamaker 2.5';
#  set xlabel 'Radial Distance (R_e/\sigma)';
#  set ylabel 'Height (R_e/\sigma)';
#  plot [0:16][14:30] 'RadialShellLJ2_5.xye' title '', h(x) title '';
#  set term post;
#  set output 'ContactAngle.ps';
#  replot;
#  print 1.472/pi*180;
