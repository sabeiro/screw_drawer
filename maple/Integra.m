#subs(x=a,f);
#eval(f,x=a);
#plot(f,x=1..100,y=1..100);
#diff(f,x); # D(f);
#diff(f,x$2);
#(D@@2)(f);
#-----------manipolate-functions---------------
#limit(f(x),x=infinity);
#expand(sin(x+y));
#factor(sin(x+y));
#simplify(sin(x+y));
#convert(cos(x),exp);
#normal(func,'expanded');
#solve({x^2=4},{x});
#% output of the previous command
# g := solve(f);
# fsolve(f,x=a..b); #find the numerical zeros
# implicitdiff(f,y,x); #derivative dy/dx
# Sum(expr,i=m..n);
# restart; #clears variable definition
#f:=x->piecewise(x<2,x^2,2*x+3);
#L:=x->f(a)+D(f)(a)*(x-a) #linearize
#int(f,x=1..3);
#### value(f);
#series(sin(x),x=0,10); #Taylor
#assume

f:= x -> Sum(Sum(x^(j-i),i=0..N),j=i+1..N);
g := value(f(x));
g := simplify(g(x);
