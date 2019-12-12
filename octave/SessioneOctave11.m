cd ~/Boccolo/             
disp("Definizione delle costanti \n");
Fenditura = load("Fenditura.dat");
Fenditure = load("Fenditure.dat");
Passo = 0.5;# mm
PassiAlGiro = 400;
VentiDivisioni = 0.03; # mm
DalPerno = 65.5;
Braccio = 700; # mm
bNom = 0.035; # mm
aNom = 0.1; # mm
Lambda0    = 0.000650; # mm
ErrLambda0 = 0.000005; # mm
ErrRLambda0 = ErrLambda0 / Lambda0;
RaggioFotodiodo = 0.3;#mm
Ordine = [-4:5];
Ordine2a = [-4.5:1:5];
O1  = [2  ,23 ,45 ,68 ,84 ,103,122,139,162,184];
O2  = [4  ,16 ,49 ,62 ,84 ,103,122,148,167,194];
O2a = [12 ,25     ,40     ,76 ,85 ,94     ,114,131,158,176];
for i = 1:10;
Ascissa1(i)    = Fenditura(O1(i),1) * VentiDivisioni;
Intensita1(i)  = Fenditura(O1(i),2);
Ascissa2(i)    = Fenditura(O2(i),1) * VentiDivisioni;
Intensita2(i)  = Fenditure(O2(i),2);
i++;
endfor
for i = 1:10;
Ascissa2a(i)    = Fenditura(O2a(i),1) * VentiDivisioni;
Intensita2a(i)  = Fenditure(O2a(i),2);
i++;
endfor
Theta1 = atan(Ascissa1/Braccio);
SenTheta1 = sin(Theta1);
Theta2 = atan(Ascissa2/Braccio);
SenTheta2 = sin(Theta2);
Theta2a = atan(Ascissa2a/Braccio);
SenTheta2a = sin(Theta2a);
PrimaColonna = ["Tutte";"Positive";"Negative";"Tutte";"Positive";"Negative"];
disp("Definizione delle funzioni dei parametri della retta interpolante \n")
function[m,q,Sy,Sm,Sq,r,Res,Cov,n,xbarra,ybarra] = Interpolazione(x,y);
n = length(x);
xbarra = mean(x);
ybarra = mean(y);
Delta = n * sum(x .** 2) - sum(x)**2;
q = (sum(x .** 2) * sum(y) - sum(x) * sum(x .* y)) / Delta;
m = (n * sum(x .* y) - sum(x) * sum(y)) / Delta;
Res = (q + m * x) .- y;
Sy = sqrt(sum( Res .** 2)/(n - 2));
Sm = Sy * sqrt(n / Delta);
Sq = Sy * sqrt(sum(x .** 2) / Delta);
Cov = sum(x .* y)/n - xbarra*ybarra;
Varx = sum((x - xbarra).**2)/ (n -1);
Vary = sum((y - ybarra).**2)/ (n -1);
r = Cov / sqrt (Varx * Vary) ;
endfunction;
function [Media,Err] = MediaPes(x,Errx);
n = length(x);
Peso  = sum(1 ./ (Errx.**2));
Media = sum(x ./ (Errx.**2)) / Peso;
Err   = sqrt(1 / Peso);
endfunction;
function [ErrR] = ErrRInd(a,b,Sa,Sb,r);
ErrR = sqrt( (Sa/a)**2 + (Sb/b)**2 - 2*r*Sa*Sb/(a*b));
endfunction;
disp("Interpolandi: \n");
XI.a = Ordine';           YI.a = SenTheta1;
XI.b = Ordine(6:10)';     YI.b = SenTheta1(6:10);
XI.c = Ordine(1:4)';      YI.c = SenTheta1(1:4);
XI.d = Ordine';         YI.d = SenTheta2;
XI.e = Ordine(6:10)';   YI.e = SenTheta2(6:10);
XI.f = Ordine(1:4)';    YI.f = SenTheta2(1:4);
XI.g = Ordine2a(1:10)';   YI.g = SenTheta2a(1:10);
XI.h = Ordine2a(1:4)';    YI.h = SenTheta2a(1:4);
XI.i = Ordine2a(6:10)';   YI.i = SenTheta2a(6:10);
disp("ValoriDelleRetteInterpolanti \n");
x = ["a","b","c","d","e","f"]; i = 1; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.a,YI.a);
i++; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.b,YI.b);
i++; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.c,YI.c);
i++; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.d,YI.d);
i++; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.e,YI.e);
i++; disp(i);
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.f,YI.f);
i++;
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.g,YI.g);
i++;
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.h,YI.h);
i++;
[m(i),q(i),Sigmay.x(i),Sigmam(i),Sigmaq(i),r.x(i)] = Interpolazione(XI.i,YI.i);
i = 1;
IY.a = XI.a * m(i) + q(i);                 i++;
IY.b = XI.b * m(i) + q(i);                 i++;
IY.c = XI.c * m(i) + q(i);                 i++;
IY.d = XI.d * m(i) + q(i);                 i++;
IY.e = XI.e * m(i) + q(i);                 i++;
IY.f = XI.f * m(i) + q(i);                 i++;
IY.g = XI.g * m(i) + q(i);                 i++;
IY.h = XI.h * m(i) + q(i);                 i++;
IY.i = XI.i * m(i) + q(i);                 i++;
disp("ValoriIndiretti \n");
i = 1;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
b(i) = -Lambda0 / m(i);
Errb(i) = sqrt( ErrRLambda0**2 + (Sigmam(i)/m(i))**2)* b(i);   i++;
[bMedia, ErrbMedia] = MediaPes(b(1:6),Errb(1:6));
[aMedia, ErraMedia] = MediaPes(b(7:9),Errb(7:9));
				# Controllo
i=1;
do;
j = 1;   
ai(j) = i;           Ris(i,j) = ai(j);  j++; 
ai(j) = m(i);        Ris(i,j) = ai(j);  j++;     
ai(j) = Sigmam(i);   Ris(i,j) = ai(j);  j++;     
ai(j) = q(i);        Ris(i,j) = ai(j);  j++;      
ai(j) = Sigmaq(i);   Ris(i,j) = ai(j);  j++;     
ai(j) = Sigmay.x(i); Ris(i,j) = ai(j);  j++;      
ai(j) = r.x(i);      Ris(i,j) = ai(j);  j++;
ai(j) = r.x(i)**2;   Ris(i,j) = ai(j);  j++; 
i++;
until (i == 9);
Ris(i,1) = 3; 
				# Relazione
disp("Relazione \n");
Relazione = fopen("Relazione11.tex","w");
				# Chiacchere'
fprintf (Relazione," \\chapter{Fenomeni di Diffrazione e Interferenza} Per produrre la seguente esperienza sul fenomeno dell'interferenza abbiamo utilizzato un fascio di luce monocromatica prodotto da una sorgente laser, una diapositiva su cui erano incisi dei tagli di circa 70 micron di larghezza ed un fotodiodo come rivelatore di intensit\\`a luminosa. Passando la luce di un sola lunghezza d'onda tra le fenditure si potevano creare delle sorgenti di luce coerenti che manifestavano i caratteristici fenomeni di interferenza, massimi e minimi d'intensit\\`a luminosa a uguale distanza. L'interferenza \\`e dovuta alla differenza di percorso tra la diapositiva e lo schermo dovuta alla distanza tra le due sorgenti. Essendo il taglio confrontabile con la lunghezza d'onda della luce ($670 \\pm 5  nm $) possiamo notare anche i fenomeni di diffrazione in cui la relazione $sen(\\theta) = \\frac{k \\cdot \\lambda}{l}$, con l larghezza della fenditura, mostra come la distanza tra due massimi sia ben visibile a occhio nudo per un braccio abbastanza lungo. \\\\ Possiamo quindi prelevare dei valori d'intensit\\`a a diversi angoli ruotando il rilevatore attorno ad un perno a lunga distanza dalla sorgente (70 cm) di modo da poter confondere l'arco con la retta. Il valore \\`e direttamente fornito da un calcolatore elettronico ed il suo valore \\`e espresso in scala logaritmica. \\\\ I dati raccolti sono ingenti e non avrebbe alcun valore presentarli,  piuttosto \\`e importante mostrare il grafico che visualizza i dati raccolti  e che mostra chiaramente l'andamento alternato di egual periodo delle frange  d'interferenza. La stessa procedura \\`e stata eseguita con un reticolo  formato da due fenditure. In questo caso si pu\\`o notare la presenza di massimi e minimi principali e secondari, ovvero l'addizione dell'intensit\\`a dei tre i fasci di luce per taglio o di due soli.\\\\ Per una sola fenditura abbiamo individuato le posizioni per i minimi d'intensit\\`a.");#'
				# Grafico
fprintf(Relazione,"\\begin{center}\\begin{figure}\\input{Fenditura}\\end{figure}\\end{center}");
				# Chiacchere
fprintf (Relazione,"Abbiamo quindi interpolato i numeri d'ordine con i seni degli angoli tra la direzione del fascio e del braccio, inizialmente coi dati mescolati e successivamente separando la serie a destra del massimo principale con quella a sinistra.");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{c c c} \n Ordine & Posizione & $\\log(I)$ \\\\ \n");
for i = 1:10;
fprintf (Relazione,"%i & %i & %i\\\\ \n ",Ordine(i),Ascissa1(i),Intensita1(i));
endfor
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
				# Chiacchere
fprintf(Relazione,"Forniamo quindi i valori dei parametri dell'interpolazione \n");
fprintf (Relazione,"\\begin{center}\\begin{tabular}{c c c c c c c} \n \
&$m$ & $\\sigma_m$ & $q$ & $\\sigma_q$ & $\\breve\\sigma$ & $r$ \\\\ \n");
for i = 1:3
fprintf(Relazione,"%s & %3.3f & %3.4f & %3.3f & %3.4f & %3.4f & %1.4f \\\\ \n",PrimaColonna(i,1:7),m(i),Sigmam(i),q(i),Sigmaq(i),Sigmay.x(i),r.x(i));
endfor;
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
				# Grafico
fprintf(Relazione,"\\begin{center}\\begin{figure}\\input{OrdineFenditura12}\\end{figure}\\end{center}");
				# Chiacchere
fprintf (Relazione,"La stessa operazione \\`e stata compiuta per la diapositiva con due tagli. In questa, oltre agli stessi minimi della situzione precedente, come si pu\\`o vedere dalla sovrapposizione dei due grafici, possiamo notare quelli dovuti all'interferenza delle due sorgenti descritti dalla relazione $sen(\\theta)$ = $\\frac{k\\cdot \\lambda}{N \\cdot a}$  con a passo tra le fenditure.\\ Ripetendo l'analisi precedente otteniamo per i massimi principali:");
				# Grafico
fprintf(Relazione,"\\begin{center}\\begin{figure}\\input{Fenditure}\\end{figure}\\end{center}");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{c c c} \n Ordine & Posizione & $\\log(I)$ \\\\ \n");
for i = 1:10;
fprintf (Relazione,"%i & %i & %i\\\\ \n ",Ordine(i),Ascissa2(i),Intensita2(i));
endfor;
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf (Relazione,"\\begin{center}\\begin{tabular}{c c c c c c c} \n \
&$m$ & $\\sigma_m$ & $q$ & $\\sigma_q$ & $\\breve\\sigma$ & $r$ \\\\ \n");
for i = 4:6;
fprintf(Relazione,"%s & %3.2f & %3.3f & %3.2f & %3.3f & %3.3f & %1.4f \\\\ \n",PrimaColonna(i,1:7),m(i),Sigmam(i),q(i),Sigmaq(i),Sigmay.x(i),r.x(i));
endfor
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
				# Grafico
fprintf(Relazione,"\\begin{center}\\begin{figure}\\input{OrdineFenditure12}\\end{figure}\\end{center}");
fputs(Relazione,"");
				# Chiacchere
fprintf (Relazione,"Mentre per i minimi secondari");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{c c c} \n Ordine & Posizione & $\\log(I)$ \\\\ \n");
for i = 1:10;
fprintf (Relazione,"%i & %i & %i\\\\ \n ",Ordine(i),Ascissa2a(i),Intensita2a(i));
endfor
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf (Relazione,"\\begin{center}\\begin{tabular}{c c c c c c c} \n \
&$m$ & $\\sigma_m$ & $q$ & $\\sigma_q$ & $\\breve\\sigma$ & $r$ \\\\ \n");
for i = 7:9;
fprintf(Relazione,"%s & %3.2f & %3.3f & %3.2f & %3.3f & %3.3f & %1.4f \
\\\\ \n",PrimaColonna(10 - i,1:7),m(i),Sigmam(i),q(i),Sigmaq(i),Sigmay.x(i),r.x(i));
endfor
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
				# Grafico
fprintf(Relazione,"\\begin{center}\\begin{figure}\\caption{Minimi Secondari}\\input{MinimiSecondari}\\end{figure}\\end{center}");
fprintf(Relazione,"Otteniamo cos\\'i le seguenti determinazioni");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{c c c} \n  Interpolazione & b & $\\sigma_{b}$ \\\\ \n");
for i = 1:3;
  fprintf (Relazione,"$b_{%i}$ & %4.2f & $\\pm$ %4.3f \\\\ \n",i,b(i)*1000,Errb(i)*1000);
endfor;
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf(Relazione,"e");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{c c c} \n  Interpolazione & a & $\\sigma_{a}$ \\\\ \n");
for i = 4:6;
  fprintf (Relazione,"$a_{%i}$ & %4.2f & $\\pm$ %4.3f \\\\ \n",i - 2,b(i)*1000*2,Errb(i)*1000*2);
endfor;
fprintf (Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf(Relazione,"\\begin{section}{Commenti} Le interpolazioni \
    mostrano un andamento di buona lienarit\\`a per i minimi \
    principali, meno per i secondari. I coefficienti angolari non si \
    discostano molto tra loro (qualche percento), abbastanza da non \
    far sospettare un errore di posizionamento o di asimmentria dello zero considerati \
    i pochi punti interpolati. Possiamo vedere la simmetria della \
    figura anche nella posizione dei minimi.\\begin{displaymath}");
for i = 1:10;
  fprintf(Relazione,"%i \\quad ",O1(i) - 103);
endfor
fprintf(Relazione,"\\end{displaymath}");
fprintf(Relazione,"non verificata allo stesso modo dalla figura a due \
    fenditure \\begin{displaymath} \n");
for i = 1:10;
  fprintf(Relazione,"%i \\quad ",O2(i) - 103);
endfor
	fprintf(Relazione,"\\end{displaymath} Gli errori a posteriori \
    della larghezza delle fenditure non sono sempre compatibili e questo potrebbe \
    essere principalmente dovuto ai pochi punti interpolati per cui \
    una minima deviazione cambia molto la pendenza della retta. Per la \
    figura a due fenditure si pu\\`o vedere che i punti sono troppo \
    distanziati poich\\`e punti vicini assumono intensit\\`a molto \
    diverse e questo aumenta l'errore sulla posizione e intensit\\`a \
    dei minimi. Allo stesso modo si calcola il passo tra le fenditure. \
	    Anche in questo caso gli errori sono molto diversi \
	    perch\\'e allo stesso modo influenzeranno sull'errore i \
	    pochi punti utilizzati.");
fprintf(Relazione,"\\end{section}\n");
fclose(Relazione);
				# Tabelle
Tabelle = fopen("Tabelle11.tex","w");
fprintf(Tabelle,"\\appendix \n I valori dell'intensit\\`a per \
    posizione nell'esperimento di diffrazione. \
    \\begin{center}\\begin{tabular}{|c c c| c c c| c c c| c c c| c c \
				    c|} \n $Pos$ & $I_1$ & $I_2$ & \
    $Pos$ &  $I_1$ & $I_2$ & $Pos$ & $I_1$ & $I_2$ & $Pos$ & $I_1$ & \
    $I_2$ & $Pos$ & $I_1$ & $I_2$\\\\ \n");
for i = 1:41;
  fprintf(Tabelle,"%i & %i & %i & %i & %i & %i & %i & %i & %i & %i & \
  %i & %i & %i & %i & %i\\\\ \n ",Fenditura(i,1),Fenditura(i,2),Fenditure(i,2),Fenditura(i+41,1),Fenditura(i+41,2),Fenditure(i+41,2),Fenditura(i+82,1),Fenditura(i+82,2),Fenditure(i+82,2),Fenditura(i+123,1),Fenditura(i+123,2),Fenditure(i+123,2),Fenditura(i+164,1),Fenditura(i+164,2),Fenditure(i+164,2));
endfor
fprintf(Tabelle,"\\end{tabular}\n\\end{center}\n");
fclose(Tabelle);
				# Grafici
disp("Salva i grafici \n");
gset term latex;
gset data style points;
gset point .7;
gset size 1,1.2;
gset title 'Singola Fenditura';
gset output 'Fenditura.tex' ; 
gset xlabel 'Spostamento'; gset ylabel 'log(I)';
gplot 'Fenditura.dat' with linespoint title'';
gset term x11;
replot;
kbhit();
gset term latex;
gset title 'Doppia Fenditura';
gset output 'Fenditure.tex'; 
gset xlabel 'Spostamento'; gset ylabel 'log(I)';
gplot 'Fenditure.dat' with linespoint title'';
gset term x11;
replot;
kbhit();
gset term x11;
replot;
gset pointsize 2;
gset term latex;
gset title 'Singola Fenditura';
GrfA.a = [XI.a,YI.a];GrfA.b = [XI.b,YI.b];GrfA.c = [XI.c,YI.c];
GrfIA.a = [XI.a,IY.a];GrfIA.b = [XI.b,IY.b];GrfIA.c = [XI.c,IY.c];
gset output 'OrdineFenditura12.tex';
gplot GrfA.a with points 1 title'', GrfIA.a with lines title \
    'Tutti',GrfA.b with points title'', GrfIA.b with lines title \
    'Positive',GrfA.c with points 7 title'', GrfIA.c with lines title 'Negative';
gset term x11;
replot;
kbhit();
gset term latex;
gset title 'Doppia Fenditura';
GrfA.d = [XI.d,YI.d];GrfA.e = [XI.e,YI.e];GrfA.f = [XI.f,YI.f];
GrfIA.d = [XI.d,IY.d];GrfIA.e = [XI.e,IY.e];GrfIA.f = [XI.f,IY.f];
gset output 'OrdineFenditure12.tex';
gplot GrfA.d with points 1 title'', GrfIA.d with lines title \
    'Tutti',GrfA.e with points title'', GrfIA.e with lines title \
    'Positive',GrfA.f with points 7 title'', GrfIA.f with lines title 'Positive';
gset term x11;
replot;
kbhit();
gset term latex;
GrfA.g = [XI.g,YI.g];GrfA.h = [XI.h,YI.h];GrfA.i = [XI.i,YI.i];
GrfIA.g = [XI.g,IY.g];GrfIA.h = [XI.h,IY.h];GrfIA.i = [XI.i,IY.i];
gset output 'MinimiSecondari.tex';
gplot GrfA.g with points 3 title'', GrfIA.g with lines title 'Tutti', GrfA.h with points 3 title'', GrfIA.h with lines title 'Negative', GrfA.i with points 3 title'', GrfIA.i with lines title 'Positive';
gset term x11;
replot;
gset size .9,.8;
gset term post;
gset linestyle 1 lt 1 lw 1 pt 1 ps 2;
gset linestyle 2 lt 1 lw 1 pt 1 ps 2;
gset title 'Singola e Doppia Fenditura';
gset output 'Fenditurae.eps'; 
gset xlabel 'Spostamento'; gset ylabel 'log(I)';
gplot 'Fenditure.dat' with linespoint 1 title'','Fenditura.dat' with \
    linespoint 1 title'';
				# Fine


