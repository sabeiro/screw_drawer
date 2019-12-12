#! /bin/octave -qf
disp("Funzioni per generare segnali telegrafici casuali\n");
function x = numeri(N,media,v);
  x = media + randn(1,N)*sqrt(v);
endfunction;

function A = tempo(N,x);
  s=0;
  for m=0:N-1
    s = s + x(1,m+1);
    A(1,m+1) = s;
  end
endfunction;

function [vet,h,passo,media,N] = tele3(N,media,var,passo);
  x = numeri(N,media,var);
  A = tempo(N,x);
  h = 0;
  for i=1:N
    if(i==1)
      x = A(1,1);
      u = rand(1,1);
      x = x * u;
      g = rand(1,1);
      for t=0:passo:A(1,1)
	if(t<=x)
	  if(g<=0.5)
	    y = 1;
	  else
	    y = 0;
	  end
	else
	  if(g <= .5)
	    y = 0;
	  else 
	    y = 1;
	  end
	end
	h = h + 1;
	vet(h,1) = t;
	vet(h,2) = y;
      end
    else
      d = y;
      x = A(1,i) - A(1,i-1);
      u = rand(1,1);
      x = A(1,i-1) + x*u;
      for t = A(1,i-1):passo:A(1,i);
	if(t<=x)
	  if(d==1)
	    y = 0;
	  else
	    y = 1;
	  end
	else
	  if(d==1)
	    y = 1;
	  else
	    y = 0;
	  end
	end
	vet(h,1) = t;
	vet(h,2) = y;
	h = h + 1;
      end
    end
  end

  o = h-1;
  if(h <= N*media/passo)
    for h = o:N*media/passo
      y = 0;
      vet(h,1) = vet(h-1,1)+passo;
      vet(h,2) = y;
    end
  end
#  m = 1:N*media/passo;
#  plot(vet(m,1),vet(m,2))
#  axis([0,N*media 0 1.5]);
#  xlabel('tempi[ms]');
#  ylabel('signal');
  h
endfunction;

function [veteff,h,passo,N,media,quante,var] = \
      somma2(N,media,var,passo,quante);
  [vet,h,p,m,n] = tele3(N*2,media,var,passo);
  for i=0:quante
    [vet1] = tele3(N*2,media,var,passo);
    floor(h/2)
    for m = 1:floor(h/2)
      vet(m,2) = vet(m,2) + vet1(m,2);
    end
  end
  h = floor(h/2);
  M = 0;
  for m = 1:h
    M = M + vet(m,2);
  end
  M = M/h;
  h = N*media/passo;
  j = 1:N*media/passo;
  veteff(j,1) = vet(j,1);
  veteff(j,2) = vet(j,2);
  m = 1:h;
  plot(veteff(m,1),veteff(m,2));
#,'r',veteff(m,1),M);
  axis([0 N*media 0 quante+1.5]);
  xlabel('tempi[ms]');
  ylabel('signal 1/f');
endfunction;

function [veteff,passo,N,media,quante,w,P] = \
      fourier2(N,media,var,passo,quante);
  [veteff,h,passo,N,media,quante] = somma2(N,media,var,passo,quante);
  fc = 0.5 / passo;
  Df = fc / h;
  w = 0:fc/h:fc/2;
  g = 1:h;
  figure
  plot(veteff(g,1),veteff(g,2))
  xlabel('tempo[s]');
  ylabel('sovrapposizione segnali');
  k = N*media/passo;
  m = 1:h/2;
  fourier = fft(veteff(m,2),k);
  P = fourier.*conj(fourier)/(h*passo);
  w(m+1) = w(m) + Df;
  figure
  plot(w(m),P(m))
  axis([0 fc/2 0 quante**2*100]);
  xlabel('frequenza f[Hz]');
  xlabel('Modulo quadro');
  x = 0.001:0.001:3;
  y = 1./x;
  hold on;
  plot(x,y,'r');
  hold off;
 endfunction;
#manneville le journale de physique
#milotti arxiv 2005
#jun ichi yano  r blender 2003
