clear;
#load("-ascii","Risposta.dat","x","y","z");
#NPoint = 100;
#tx = ty = linspace (0, 2.*pi, NPoint)';
#[xx, yy] = meshgrid (tx, ty);
#tz = xx.*yy;
#DataIn = fopen("Risposta.dat","r");
#[tx,ty,tz,NPoint] = fscanf(DataIn,"%f %f %f\n");
#[A,NTot] = fscanf(DataIn,"%f %f %lf\n",[NPoint*NPoint,3]);
#tx = A(1:NPoint*NPoint,1);
#ty = A(1:NPoint*NPoint,2);
#tz = A(1:NPoint*NPoint,3);
#mesh (tx, ty, tz);


load Risposta.dat;
tx = 1:length(tz);
ty = 1:length(tz);
mesh(tx,ty,tz);
