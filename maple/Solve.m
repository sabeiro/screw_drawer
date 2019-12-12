with(linalg);
a:=matrix([[1,6,5,8],[5,2,5,5],[6,3,7,1],[8,7,2,6]]);
#evalm(a &* a); #matrix product
b:=vector([1,4,3,2]);
c:=linsolve(a,b);
#evalm(inverse(a) &* b);#come sopra
LUdecomp(a, P='p', L='l', U='u' , U1='u1', R='r', rank='ran', det='d');
print(l);
print(u);


Circle := (x,y) -> R^2 - (x-Xc)^2 - (y-Yc)^2;
assert(R>0);
assert(Xc>0);
assert(Yc>0);
#L := 5.0;
#t := 1.0;
#TanTheta := 1.;
Curve := { (L-Xc)^2-Yc^2 = R^2,
    Xc^2+(t-Yc)^2 = R^2,
    TanTheta = - Xc/(t-Yc)};
Sol := (L,t,TanTheta) -> solve(Curve,{Xc,Yc,R});
#Sol := fsolve(Curve,{Xc,Yc,R});
subs(Xc=Sol[1][3],Yc=Sol[1][1],R=Sol[1][2],Cirle(x,y));
plot(Circle(Xc,Yc,R));


Yc := (L^2-t^2+2*TanTheta*L*t)/(2*L*TanTheta-2*t);
Xc := TanTheta*(Yc-t);
R := sqrt(Xc^2 + (t-Yc)^2);



L = 5.;
t = 1.;
TanTheta = 1.;
#Yc = (L**2-t**2+2*TanTheta*L*t)/(2*L*TanTheta-2*t);
#Xc = TanTheta*(Yc-t);
Yc = (L**2-t**2+2*L*t/TanTheta)/(2*L/TanTheta-2*t);
Xc = (Yc-t)/TanTheta;
R = sqrt(Xc**2 + (t-Yc)**2);
g(x,y) = R^2 - (x-Xc)^2 - (y-Yc)^2;
f(x) = -sqrt( R**2 - (x-Xc)**2) + Yc;
plot [0:L][0:t] f(x)
