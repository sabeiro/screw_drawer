#with(student):
#simpson(x*sin(x^2),x=1..5);
with (plots);
with(plottools);

readlib(realroot):
with(linalg):
with(LinearAlgebra):

f:=Rad-> (Rnp^2-( (Rnp+Dist) - Rad )^2)/(Rnp*Rad^5);
assume(Rnp>0);
F := int(f(Rad),Rad);
#F := int(f(Rad),Rad=Dist..(Dist+2*.Rnp));
G := simplify(eval(F(Rad),Rad=Dist+2*RadNp) - eval(F(Rad),Rad=Dist));

g := x-> (Rnp/x)^9 - (Rnp/x)^3;
f := x-> subs(Rnp=1.5,g(x));
fsolve(f(x) = 0);

Pot3 := 1/(12*x) * ( 2*Rnp/(x+Rnp)^3 + 2*Rnp/(x-Rnp)^3 + 1/(x+Rnp)^2 - 1/(x-Rnp)^2);
Pot9 := 1/(110*x) * ( 2*Rnp/(x+Rnp)^9 + 2*Rnp/(x-Rnp)^9 + 1/(x+Rnp)^8 - 1/(x-Rnp)^8);
LJ := x -> Pot9 - Pot3;
LJCO := x -> piecewise(x < Rnp*1.00428+0.428224,20.-440.*(x-Rnp*1.00428-0.428224), Pot9 - Pot3);
Force := x->-diff(Pot9-Pot3, x);
ForceCO := x -> piecewise(x < Rnp*1.00428+0.428224,440, Force(x));
LJPlot1 := x-> subs(Rnp=0.2,LJCO(x));
LJPlot2 := x-> subs(Rnp=1.2,LJCO(x));
LJPlot3 := x-> subs(Rnp=3.4,LJCO(x));
ForcePlot1 := x-> subs(Rnp=0.2,ForceCO(x));
ForcePlot2 := x-> subs(Rnp=1.2,ForceCO(x));
ForcePlot3 := x-> subs(Rnp=3.4,ForceCO(x));
limit(Force(x),x=0);
plot({LJPlot1(x),LJPlot2(x),LJPlot3(x),ForcePlot1(x),ForcePlot2(x),ForcePlot3(x)},x=0..6,y=-2..2);


PotCutOff := 20.;
Inverse := Rnp -> solve(LJ(x) = PotCutOff,x);
NMass := 15;
a := [seq([i,i],i=1..NMass)];
for i from 1 by 1 to NMass do
    Rad := 6./NMass*i;
    #Radici := evalf(allvalues(subs(Rnp=Rad,Inverse(Rnp))) );
    a[i][1] := Rad;
    a[i][2] := fsolve( subs(Rnp=Rad,LJ(x))=PotCutOff,x=Rad+.1..3*Rad);
    # if abs(Im(Radici[2])) > 0. then
    #     a[i][2] := Radici[1];
    # elif abs(Im(Radici[3])) > 0. then
    # 	a[i][2] := Radici[2];
    # else
    # 	a[i][2] := Radici[3];
    # fi;
od;
plot(a);
CutOff := seq( subs(Rnp=a[i,1],eval(LJ(x),x=a[i,2])) ,i=1..NMass);
ForceCO := seq( subs(Rnp=a[i,1],eval(Force(x),x=a[i,2])) ,i=1..NMass);


#Old
PotOld := x-> (a/(x-r+a))**9 - (a/(x-r+a))**3;
PotOldGraph := x-> subs(a=1.2,r=1.0,PotOld(x));
plot(PotOldGraph(x),x=0..3,y=-10..10);

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


f(x) = 1./(x*110.)*( (2.*Rnp)/(x+Rnp)**10 + (2.*Rnp)/(x-Rnp)**10 + 1./(x+Rnp)**9 - 1./(x-Rnp)**9 )-  1./(x*12.)*( (2.*Rnp)/(x+Rnp)**3 + (2.*Rnp)/(x-Rnp)**3 + 1./(x+Rnp)**2 - 1./(x-Rnp)**2 ) ;
g(x) = 1./(x*12.)*( (2.*Rnp)/(x+Rnp)**3 + (2.*Rnp)/(x-Rnp)**3 + 1./(x+Rnp)**2 - 1./(x-Rnp)**2 );


PotCutOff 0.
0.2000000000 0.5968492782 
0.4000000000 1.016664698 
0.6000000000 1.265186751
0.8000000000 1.479183171 
1.000000000 1.684665000 
1.200000000 1.887254712
1.400000000 2.088639674 
1.600000000 2.289448549 
1.800000000 2.489953147
2.000000000 2.690284477 
2.200000000 2.890511144 
2.400000000 3.090671512
2.600000000 3.290788201 
2.800000000 3.490875154 
3. 3.690941286

Fit = 1.007*x + 0.674


PotCutOff 81.
0.2000000000 0.5029442968 
0.4000000000 0.7440844948 
0.6000000000 0.9580267142                      
0.8000000000 1.165442877 
1.000000000 1.370117590 
1.200000000 1.573353908
1.400000000 1.775734427 
1.600000000 1.977562020 
1.800000000 2.179010738
2.000000000 2.380188082 
2.200000000 2.581164190 
2.400000000 2.781986837
2.600000000 2.982689723 
2.800000000 3.183297323 
3. 3.383827843

Fit = 1.009*x + 0.359

PotCutOff 20. -> Force 440
0.4000000000 0.7930742870 
0.8000000000 1.221042195 
1.200000000 1.631253638
1.600000000 2.036676831 
2.000000000 2.440062332 
2.400000000 2.842382979
2.800000000 3.244074997 
3.200000000 3.645364209 
3.600000000 4.046379556
4.000000000 4.447200128 
4.400000000 4.847877176 
4.800000000 5.248445392
5.200000000 5.648929102 
5.600000000 6.049345879 
6. 6.449708732

Fit = 1.00428*x + 0.428224
