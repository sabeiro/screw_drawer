clear;
NPoint = 41;

tx = ty = linspace (0, 2.*pi, NPoint)';
[xx, yy] = meshgrid (tx, ty);
#r = sqrt (xx .^ 2 + yy .^ 2) + eps;
#tz = sin (r) ./ r;
#tz = sin(xx*4.).*sin(yy*4.);
#tz = sin(xx.*yy*2);
tz = sin(xx*4.);
tw = fft(tz,NPoint,2);
tw = tw.*conj(tw)/(NPoint*NPoint);
save Spectrum.mat tw
mesh (tx, ty, tw);
#mesh (tx, ty, tz);
Relazione = fopen("Spettro.dat","w");
fprintf(Relazione,"#Spettro2d\n");
for ix=1:NPoint;
    for iy=1:NPoint;
	fprintf(Relazione,"%f %f %f\n",tx(ix),ty(iy),tw(ix,iy));
    endfor
endfor
fclose(Relazione);
