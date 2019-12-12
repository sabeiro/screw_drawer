f:=x-> ( 2.*x - sin(2.*x) )^2/(4./3.*sin(x)^3 - \
			       2.*x*cos(x)+cos(x)*sen(2*x)^2);
y := .5;
r := solve(f = y,x);
