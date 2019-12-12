
set style line 1 lt 1
set style line 2 lt 3
set style line 3 lt 4
set style line 4 lt 5
set xlabel "mismatch" font "Helvetica,26"
set ylabel "angle" font "Helvetica,26"
set zlabel "thinning" font "Helvetica,26" 
set zlabel rotate 

#set ztics 0,.2
#set label "Label" at 2,0.5 textcolor lt 4

set terminal postscript color enhanced "Helvetica" 20
set title "thinning" font "Times-Roman,40"
set output "PepHeiMin.eps"

set dgrid3d 6,20,20
set hidden3d
set pm3d
set view 63,304

set terminal postscript eps enhanced
set output "PepHeiMin2d.eps"
splot [][][] 'Cont1000HeiAngMinDist.dat' u 1:2:3 with lines title "", 'Cont100HeiAngMinDist.dat' u 1:2:3 with lines title "", 'Cont10HeiAngMinDist.dat' u 1:2:3 with lines title ""

set title "minimum distance" font "Times-Roman,40"
set output "PepHeiThin2d.eps"
set view 63,304
set zlabel "min dist" font "Helvetica,26"

splot [][][] 'Cont1000HeiAngThin.dat' u 1:2:3 with lines title "", 'Cont100HeiAngThin.dat' u 1:2:3 with lines title "", 'Cont10HeiAngThin.dat' u 1:2:3 with lines title ""

