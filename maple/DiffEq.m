de := c1*diff(y(x),x$4) + c2*diff(y(x),x$2) + c3*y(x) = 0;
Y := rhs(dsolve(de,y(x)));

#v := <a,b>;
#SetCoordinates(v,polar);

#search for a solution
clear;
with(Student[VectorCalculus]) ;
Sol(r) := exp(r)/r;
#DiffEq(r) := Laplacian(Laplacian(Sol(r),polar),polar) + Laplacian(Sol(r),polar) + Sol(r);
DiffEq(r) := Laplacian(Sol(r),polar) + Sol(r);
solve(DiffEq(r)=0,r);
simplify(DiffEq(r));

DiffLap(r) := Laplacian(Sol(r),polar) + Sol(r);

Sol(r) := exp(r)*sin(r)/sqrt(r);
DiffLap2(r) := r*r*diff(Sol(r),r$2) + 2*r*diff(Sol(r),r) + r^2*Sol(r);
simplify(DiffLap2(r));
DiffLap4(r) := r^2*diff(Sol(r),r$4) + 2*r*diff(Sol(r),r$3) + (1+r^2)*diff(Sol(r),r$2) + 1/r*diff(Sol(r),r) + r^2*Sol(r);
simplify(DiffLap4(r));
solve(DiffLap4(r)=0,r);
#prepare the known solution
a := 6.2; d := .15; e := 1.3;
Bend := a; Compr = d; Elast = e;
l1 := sqrt( 2*d + sqrt( (2*d)^2 - (a/e) ) );
l2 := sqrt( 2*d - sqrt( (2*d)^2 - (a/e) ) );
Sol := r -> a1*BesselJ(0,l1*r) + a2*BesselJ(0,l2*r);


#parameters
clear;
with(Student[VectorCalculus]) ;
Bend := 13.8858; Compr := 0.136 ; Elast := 7.84;
#solution
DiffEq := Laplacian(Laplacian(y(r),polar),polar) + 4.0*Compr*Laplacian(y(r),polar) + Elast/Bend*y(r) = 0.0;
#DiffEq := diff(y(r),r$4) + 4.0*Compr*diff(y(r),r$2) + Elast/Bend*y(r);
#Bound1 := subs(r=1.0,y(r)) = 1.75;
#Bound2 := subs(r=10.0,y(r)) = 0.0;
#Bound3 := subs(r=1.0 ,D(y)(r) ) = tan(-35.0/(2.0*Pi));
#Bound4 := subs(r=10.0,D(y)(r) ) = 0.0;
#rhs(dsolve({DiffEq,Bound1,Bound2,Bound3,Bound4},y(r)));
Sol := r -> rhs(dsolve(DiffEq,y(r)));
DiffEqBound := {DiffEq,y(1.0)=1.5,y(10.0)=0.00,D(y)(1.0)=tan(34.0/(2.0*Pi)),D(y)(10.0)=0.0};
SolNum := dsolve(DiffEqBound,y(r),type=numeric);
Sol(r);


FWrite := fopen("ThickProfMaple.dat",WRITE,TEXT);
for r from 1.0 by .2 to 10. do
    val := SolNum(r);
   fprintf(FWrite,"%lf %lf\n",r,rhs(val[2]));
end do:
fclose(FWrite);


#boundary
DerSolEq := r -> diff(Sol(r),r);
DerSol := r -> eval(DerSolEq(r));
Bound1 := subs(r=1.0,Sol(r)) = 1.5;
Bound2 := subs(r=10.0,Sol(r)) = 0.0;
Bound3 := subs(r=1.0 ,DerSol(r) ) = tan(35.0/(2.0*Pi));
Bound4 := subs(r=10.0,DerSol(r) ) = 0.0;
SSys := solve({Bound1,Bound2,Bound3,Bound4},{_C1,_C2,_C3,_C4});
assign(SSys);


InFile := "ThickProf2d.dat";
fopen(InFile,READ,TEXT);
Data := readdata(InFile,2);
with(plots,textplot,display);
plotData := plot(Data, style = point);
plotSol := plot(Sol(r)-_C7, r = 0.0 .. 10.0,labels=['R','Z']);
plotSolNum := plots[odeplot](SolNum,[r,y(r)],0..10);
display(plotData, plotSolNum, view = ([0.0 .. 10.0, -.5 .. 2.5]));


