#with(student):
#simpson(x*sin(x^2),x=1..5);
with(plottools);
with (plots);

readlib(realroot):
with(linalg):
with(LinearAlgebra):


f:= r -> Pi*(Rnp^2-( x - r )^2)/(x*r^5);
#Rnp :="Rnp";
#assume(Rnp>0);
F := x -> int(f(Rad),Rad=x+Rnp..x-Rnp);
G := simplify(eval(F(Rad),Rad=Dist+2*RadNp) - eval(F(Rad),Rad=Dist));

g := x-> (Rnp/x)^9 - (Rnp/x)^3;
f := x-> subs(Rnp=1.5,g(x));
fsolve(f(x) = 0);


Slope := 1.00203;
Interc := 0.31739;
ForceThr := 500.;
PotThr := 4.486717559;
Sigma := 0.04;
#Pot3 := (1/12)*(3*Rnp+x)/((x+Rnp)^3 * x) - (1/12)*(3*Rnp-x)/((-x+Rnp)^3 * x);
#Pot9 := (1/360)*(9*Rnp+x)/((x+Rnp)^9 * x)-(1/360)*(9*Rnp-x)/((-x+Rnp)^9 * x);
Pot3 := (1/12*x)*( (2*Rnp)/(x+Rnp)^3 + (2*Rnp)/(x-Rnp)^3 + 1/(x+Rnp)^2 + 1/(x-Rnp)^2);
Pot9 := (1/360*x)*( (2*Rnp)/(x+Rnp)^9 + (2*Rnp)/(x-Rnp)^9 + 1/(x+Rnp)^8 + 1/(x-Rnp)^8);
LJ := x -> Sigma*Pot9 - Pot3;
LJCO := x -> piecewise(x < Rnp*Slope+Interc,PotThr-ForceThr*(x-Rnp*SLope-Interc),LJ(x));
Force := x->-diff(LJ(x), x);
ForceCO := x -> piecewise(x < Rnp*Slope+Interc,ForceThr, Force(x));
LJ39 := x-> (a/(x-Rnp+a))**9 - (a/(x-Rnp+a))**3;
LJ39CO := x-> piecewise(x < Rnp - 0.39*a,81.-563.*(x-Rnp+0.39*a),LJ39(x));
a := 1.0;
LJ612 := x-> (a/(x-Rnp+a))**12 - (a/(x-Rnp+a))**6;
LJ612CO := x-> piecewise(x < Rnp - 0.39*a,81.-563.*(x-Rnp+0.39*a),LJ612(x));
a := 1.0;
LJPlot1 := x-> subs(Rnp=0.5,LJCO(x));
LJPlot2 := x-> subs(Rnp=1.2,LJCO(x));
LJPlot3 := x-> subs(Rnp=3.4,LJCO(x));
ForcePlot1 := x-> subs(Rnp=0.5,ForceCO(x));
ForcePlot2 := x-> subs(Rnp=1.2,ForceCO(x));
ForcePlot3 := x-> subs(Rnp=3.4,ForceCO(x));
limit(Force(x),x=0);
plot({LJPlot1(x),LJPlot2(x),LJPlot3(x),ForcePlot1(x),ForcePlot2(x),ForcePlot3(x)},x=0..6,y=-2..2,color=[red,blue,green,red,blue,green]);

with(plottools);
with (plots);

plot1 := plot(subs(Rnp=2.0,a=1.2,LJ39CO(x)),
      x=0..6,y=-2..2,color=COLOR(RGB,1.0,.0,1.0));
plot2 := plot(subs(Rnp=2.0,a=1.2,LJ612CO(x)),
      x=0..6,y=-2..2,color=COLOR(RGB,1.0,1.0,0.0));
plot3 := plot(subs(Rnp=1.5,LJCO(x)),
      x=0..6,y=-2..2,color=COLOR(RGB,.0,1.0,1.0));
display(plot1,plot2,plot3,view=[0..4,-2..2]);

plot({subs(Rnp=2.0,a=1.2,LJ39CO(x)),subs(Rnp=2.0,a=1.2,LJ612CO(x)),subs(Rnp=1.55,LJCO(x))},x=0..6,y=-2..2,color=[red,blue,green]);

#Pot3 := 1/(12*x) * ( 2*Rnp/(x+Rnp)^3 + 2*Rnp/(x-Rnp)^3 + 1/(x+Rnp)^2 - 1/(x-Rnp)^2);
#Pot9 := 1/(360*x) * ( 2*Rnp/(x+Rnp)^9 + 2*Rnp/(x-Rnp)^9 + 1/(x+Rnp)^8 - 1/(x-Rnp)^8);


ForceCutOff := 500.;
RadTemp := 2.0;
CutOff := fsolve( subs(Rnp = RadTemp,Force(x) = ForceCutOff),x=RadTemp+0.1..3.*RadTemp);
PotCutOff := eval( subs(Rnp=RadTemp,LJ(x)) ,x=xCutOff);
#Inverse := Rnp -> solve(LJ(x) = PotCutOff,x);
Inverse := Rnp -> solve(Force(x) = ForceCutOff,x);
NMass := 15;
a := [seq([i,i],i=1..NMass)];
for i from 1 by 1 to NMass do
    Rad := 6./NMass*i;
    #Radici := evalf(allvalues(subs(Rnp=Rad,Inverse(Rnp))) );
    a[i][1] := Rad;
    #a[i][2] := fsolve( subs(Rnp=Rad,LJ(x))=PotCutOff,x=Rad+.1..3*Rad);
    a[i][2] := fsolve( subs(Rnp=Rad,Force(x))=ForceCutOff,x=Rad+.1..3*Rad);
od;
plot(a);
CutOff := seq( subs(Rnp=a[i,1],eval(LJ(x),x=a[i,2])) ,i=1..NMass);
ForceCO := seq( subs(Rnp=a[i,1],eval(Force(x),x=a[i,2])) ,i=1..NMass);


Threshold := 120.;
CutOff := 2.4;
RadNp := 1.0;
PotCutOff := x -> (a/(x - Rad + a))^9 - (a/(x - Rad + a))^3;
Cross := fsolve(subs(a=CutOff,Rad=RadNp,PotCutOff(x))=Threshold);
#CrossZero := Rad -> solve(PotCutOff(x) = Threshold);
ForceCutOff := x-> -diff(PotCutOff(x),x);
Solve := eval(subs(a=CutOff,Rad=RadNp,ForceCutOff(x)),x=Cross);
#plot(subs(a=CutOff,Rad=RadNp,PotCutOff(x)),x=0.1..2.0);
NMass := 15;
Vect := [seq([i,i],i=1..NMass)];
for i from 1 by 1 to NMass do
    RadNp := 6./NMass*i;
    Vect[i][1] := RadNp;
    Vect[i][2] := fsolve(subs(a=CutOff,Rad=RadNp,ForceCutOff(x))=Threshold,x=0.01..3.0*RadNp);
od;
Vect;
Intercept := -0.996471;
Slope := 1;
# x < Rad - 0.41*a;
seq (eval(subs(a=CutOff,Rad=Vect[i][1],PotCutOff(x)),x=Vect[i][2]),i=1..NMass);



dPotOld := x->diff(PotOld(x),x);
OldSolve := r -> eval(dPotOld(x),x=0.);
normal(OldSolve(r));
factor(OldSolve(r));
numer(OldSolve(r));

# f := x-> (Rnp^2 - x^2)/(4.*x)*( - 1./(x+Rnp)^4 + 1./(x-Rnp)^4 )  
#          + (2.*Rnp)/(3.*x)*( - 1./(x+Rnp)^3 + 1./(x-Rnp)^3 ) 
#        + 1./(2.*Rnp)*( 1./(x+Rnp)^2 - 1./(x-Rnp)^2 );
fg := x -> f(x) - g(x);
h := x-> 1./x^9 - g(x);
dh := x->diff(h(x),x);
limit(dh(x),x=0);
l := x-> subs(Rnp=2.0,h(x));
fsolve({l(x)=0},x=0..3);


Pot3(x) = (1./12. )*(3.*Rnp+x)/((x+Rnp)**3 * x) - (1./12. )*(3.*Rnp-x)/((-x+Rnp)**3 * x);
Pot9(x) = (1./360.)*(9.*Rnp+x)/((x+Rnp)**9 * x) - (1./360.)*(9.*Rnp-x)/((-x+Rnp)**9 * x);

Pote3(x) = 1./(12. *x) * ( 2.*Rnp/(x+Rnp)**3 + 2.*Rnp/(x-Rnp)**3 + 1./(x+Rnp)**2 - 1./(x-Rnp)**2);
Pote9(x) = 1./(360.*x) * ( 2.*Rnp/(x+Rnp)**9 + 2.*Rnp/(x-Rnp)**9 + 1./(x+Rnp)**8 - 1./(x-Rnp)**8);


f(x) = Pot9(x) - Pot3(x);Rnp = 3.0;
g(x) = Pote9(x) - Pote3(x);Rnp = 3.0;
LJ39(x) = (Rnp/x)**9 - (Rnp/x)**3;
LJ612(x) = (Rnp/x)**12 - (Rnp/x)**6;
Rnp = 3; plot [Rnp:3*Rnp][:2] 444.*f(x), LJ39(x), LJ612(x)  

Sigma 0.001

0.4000000000 0.6136409922
0.8000000000 1.017079339
1.200000000 1.418384411
1.600000000 1.819076527
2.000000000 2.219506211
2.400000000 2.619799147
2.800000000 3.020011724
3.200000000 3.420173048
3.600000000 3.820299673
4.000000000 4.220401714
4.400000000 4.620485701
4.800000000 5.020556036
5.200000000 5.420615800
5.600000000 5.820667211
6. 6.220711904

Fit = 1.00083*x + 0.216784


Sigma 0.04

0.400000000 0.7100402957
0.8000000000 1.118035359
1.200000000 1.521204511    
1.600000000 1.922918491
2.000000000 2.323994848
2.400000000 2.724734233
2.800000000 3.125273693
3.200000000 3.525684750
3.600000000 3.926008414
4.000000000 4.326269898
4.400000000 4.726485560
4.800000000 5.126666483
5.200000000 5.526820437
5.600000000 5.926953038
6. 6.327068440
