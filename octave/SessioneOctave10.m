cd ~/Boccolo/             
disp("Definizione delle costanti \n");
Lente   = [25.7,  25.8,  25.9,  26.3,  26.6,  26.7,  26.9,  27.15, 27.3   27.65, 27.8,  27.9,  28.55, 29.25, 29.7,  30,    30.15, 31.4,  32.8,  34.45, 36.2, 37, 38.5, 39.6, 40.6, 42.95, 45.5, 48.175, 53.675, 63.875, 73.95, 84, 104.15, 109.2, 114.15, 134.3];
Schermo = [140,  109.55, 90.03, 61.4,  54.95, 52.5,  50,    48,    47,    46,    45,    44 ,   43 ,   42,    41,    40,    40,    41,    42,    43,    44,   45, 46 ,  47, 48, 50, 52.5, 55, 60, 70, 80, 90, 110, 115, 120, 140];
pCon       = [5.7,    5.8,   5.9,   6.3,   6.6,   6.7,   6.9,   7.15,  7.3,   7.65,  7.8,   7.9,   8.55,  9.25,  9.7,  10,    10.15, 11.4,  12.8,  14.45, 16.2, 17, 18.5, 19.6, 20.6, 22.95, 25.5, 28.175, 33.675, 43.875, 53.95, 64, 84.15 ,89.2, 94.15, 114.3];
qCon       = [114.3, 83.75, 64.13, 35.1,  28.35, 25.8,  23.1,  20.85, 19.7,  18.35, 17.2,  16.1,  14.45, 12.75, 11.3,  10,     9.85,  9.6,   9.2,   8.55,  7.8, 8 ,  7.5,  7.4, 7.4, 7.05, 7, 6.825 ,6.325, 6.125, 6.05, 6, 5.85, 5.8, 5.85, 5.7];
pB1     = [26.95, 26.95, 26.90, 26.80, 26.85, 26.90, 26.85, 26.90, 26.80, 26.95, 26.90, 26.95, 26.90, 26.90, 26.88, 26.93, 26.93, 26.90, 26.93, 26.85]; 
qB1     = [43.90, 43.85, 43.95, 43.85, 43.85, 43.80, 44.00, 43.70, 43.90, 43.80, 44.00, 43.80, 43.73, 43.85, 43.80, 43.83, 43.85, 43.78, 43.83, 43.83]; 
pB2     = [25.90, 25.95, 25.90, 25.95, 25.90, 25.90, 25.95, 25.90, 25.90, 25.95, 25.90, 25.93, 25.93, 25.95, 25.90, 25.90, 25.93, 25.90, 25.90, 25.93];
qB2     = [79.85, 79.90, 79.90, 79.80, 79.90, 79.85, 79.90, 79.95, 79.85, 79.80, 79.83, 79.80, 80.00, 79.83, 79.83, 79.98, 79.83, 79.95, 79.93, 79.78]; 
Convergente = [7.870,7.870,7.870,7.370,7.370,7.370,7.370,7.120,7.120,7.120,6.850,6.778,6.690,6.738,6.522];
Divergente = [16.81,16.31,16.02,19.17,18.55,18.2,17.95,21.09,20.58,20.13,24.95,24.95,24.95,24.95,30];
qTot = [50,60,70,50,60,70,80,50,60,70,50,60,80,70,60];
DistanzaInternaPost = [3.748,4.000,4.848,3.779,4.763,5.703,5,4.938,5.186,6.507,4.632,6.331,9.269,7.714,6.985];
DistanzaInterna = 0.45;
SchermoB1 = 50; SorgenteB1 = 30;
SchermoB2 = 85; SorgenteB2 = 65;
pRec = 1 ./pCon;
qRec = 1 ./qCon;
fRec = pRec .+ qRec;
SB1 = qB1 .- pB1;
SB2 = qB2 .- pB2;
LB1 = qB1 .+ pB1 - 40;
LB2 = qB2 .+ pB2 - 40;
f1  = 1 ./ fRec;
LB.x(1) = mean(LB1); ErrLB.x(1) = std(LB1);
LB.x(2) = mean(LB2); ErrLB.x(2) = std(LB2);
SB.x(1) = mean(SB1); ErrSB.x(1) = std(SB1);
SB.x(2) = mean(SB2); ErrSB.x(2) = std(SB2);
hh = Divergente .- Convergente;
fCon = 5.35;
Spessore = 1;
DDueFori = 4; # mm
ErrDDueFori = 0.01; #mm
Ing = DistanzaInternaPost / DDueFori;
qConv = (fCon*Convergente) ./ (Convergente - fCon);
pDiv  = qConv .- hh;
Positive = qConv .- Divergente;
qDiv = qTot .- Divergente;
fDiv = (pDiv .* qDiv) ./ (pDiv .+ qDiv);
fTot = (pDiv .* qDiv) ./ (pDiv .+ qDiv);
fDiv2a = ((Ing * fCon) ./ (fCon*(1+Ing).-Ing));
fDiv2b =  (fCon./(fCon-hh));
fDiv2 = fDiv2a .* fDiv2b;
Spessore = 10.10; #mm
Spigolo = 2.60; #mm
n = 1.5168;
PPC = (Spessore * 56 * 4 * (n - 1) + Spessore) / (4 * n * 56 + Spessore);
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
#Chi = sum(Res**2 / (y**2 + (m*x**2)));
endfunction;
function [Media,Err] = MediaPes(x,Errx);
n = length(x);
Peso  = sum(1 ./ (Errx.**2));
Media = sum(x ./  Errx.**2 ) / Peso;
Err   = sqrt(1 / Peso);
endfunction;
disp("Interpolandi: \n");
X.a = 1 ./ pCon; Y.a = 1 ./ qCon;
X.b = hh / fCon; Y.b = (Ing.**2 - 1) ./ (Ing.*qTot);
X.c = 1 ./ qTot; Y.c = (fCon + Convergente) ./ (fCon*Convergente.*hh .- fCon*Convergente);
X.d = (1 + Ing)./ Ing; Y.d = (- hh + fCon) / fCon;
X.e = - 1 ./ pDiv; Y.e = 1./ qDiv;
X.f = Ing; Y.f = qDiv ./ pDiv;
X.g = [X.f(2:10),X.f(12:14)];Y.g = [Y.f(2:10),Y.f(12:14)];
disp("Valori da interpolare \n");
#XI.a = X.a; YI.a = Y.a;
XI.a =[X.a(1:18),X.a(21:35)]; YI.a = [Y.a(1:18),Y.a(21:35)]; 
XI.b = X.b; YI.b = Y.b;
XI.c = X.c; YI.c = Y.c;
XI.d = X.d; YI.d = Y.d;
XI.e = X.e(1:13); YI.e = Y.e(1:13);
XI.f = X.f; YI.f = Y.f;
XI.g = X.g; YI.g = Y.g;
disp("ValoriDelleRetteInterpolanti \n");
x = ["a","b","c","d","e","f"]; i = 1;
disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.a, YI.a);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.b, YI.b);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.c, YI.c);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.d, YI.d);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.e, YI.e);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.f, YI.f);  
i++; disp(i);
[m(i),q(i),Sigmay(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(XI.g, YI.g);  
i++; disp(i);
i = 1;
IY.a  = X.a * m(i) + q(i);
Res.a = XI.a * m(i) + q(i) .- YI.a;       i++;
IY.b  = X.b * m(i) + q(i);
Res.b = XI.b * m(i) + q(i) .- YI.b;       i++;
IY.c  = X.c * m(i) + q(i);
Res.c = XI.c * m(i) + q(i) .- YI.c;       i++;
IY.d  = X.d * m(i) + q(i);
Res.d = XI.d * m(i) + q(i) .- YI.d;       i++;
IY.e  = X.e * m(i) + q(i);
Res.e = XI.e * m(i) + q(i) .- YI.e;       i++;
disp("ValoriIndiretti \n");
#f = zeros(1,10);ErrR = zeros(1,10);Err = zeros(1,10);fD = zeros(1,10);ErrfD = zeros(1,10);
f(1) = 10 /(m(1) + q(1) * 10 + 1);
f(2) = 1 / q(1);
f(3) = - m(1) / q(1);
f(4) = (LB.x(1)^2 - SB.x(1)^2) / 4 ./ LB.x(1);
f(5) = (LB.x(2)^2 - SB.x(2)^2) / 4 ./ LB.x(2);
fBMedio = (f(2) + f(3)) / 2;
ErrRfBMedio = 1;
ErrR(1) = sqrt( ( Sigmam(1) / (m(1) + q(1) * 10 + 1) )^2 + ( Sigmaq(1) / (m(1) + q(1) * 10 + 1) )^2);
ErrR(2) = - Sigmam(1) / m(1);
ErrR(3) = sqrt( (Sigmaq(1)/q(1))^2 + (Sigmam(1)/m(1))^2 - \
		 2*r(1)/(m(1)*q(1))*Sigmaq(1)*Sigmam(1) );
ErrRfMedio = sqrt(ErrR(2)**2 + ErrR(3)**2);
ErrR(4) = sqrt( (ErrSB.x(1)/SB.x(1))**2 + (ErrLB.x(1)/LB.x(1))**2 )*f(4);
ErrR(5) = sqrt( (ErrSB.x(2)/SB.x(2))**2 + (ErrLB.x(2)/LB.x(2))**2 )*f(5)
#ErrRfBMedio = sqrt(ErrR(4)**2 + ErrR(5)**2);
Errf(1)  = ErrR(1) * f(1);
Errf(2)  = ErrR(2) * f(2);
Errf(3)  = ErrR(3) * f(3);
fConiu = [f(1),f(2),f(4),f(3)];
ErrfConiu = [Errf(1),Errf(2),f(4),Errf(3)];
[fMedio,ErrfMedio] = MediaPes(fConiu,ErrfConiu);
Errf(4)  = ErrR(4) * f(4);
Errf(5)  = ErrR(5) * f(5);
ErrfBMedio = ErrRfBMedio * fBMedio;
[fMedia,ErrfMedia] = MediaPes(f,Errf);
				# Divergente
ErrpDiv = pDiv * ErrfMedia / fMedia;
fD(1) = 1 / q(5);               ErrfD(1) = Sigmaq(5)/q(5)*fD(1);
fD(2) = -1/m(2);           ErrfD(2) = Sigmaq(5)/q(5)*fD(2);
fD(3) = mean(fDiv);             ErrfD(3) = std(fDiv);
fD(4) = - 1/q(3);  ErrfD(4) = Sigmam(2)/q(2)*fD(4);
fDBuono = [fDiv(2:10),fDiv(12:14)];
fD(5) = mean(fDBuono);          ErrfD(5) = std(fDBuono);
#fDBuono = [f(1),f(2),f(3)];
#PesofD = sum(1 ./ (ErrfD.**2));
#fDMedia = sum(fD ./ (ErrfD.**2)) / PesofD;
#ErrfDMedia = sqrt(1 / PesofD);
PPD = mean(Convergente) - Spessore/2 + mean(Divergente) + mean(hh) - 2 \
    * mean(fDBuono);
				# Relazione
disp("Relazione \n");
Relazione = fopen("Relazione10.tex","w");
            #Chiacchere
fprintf (Relazione,"\\chapter{Studio Sulle Caratteristiche delle Lenti} Nella seguente esercitazione abbiamo misurato la distanza focale delle lenti convergenti e divergenti. La determinazione di questi valori ci \\`e stata permessa dall'impiego di un supporto  fisso lungo 120 cm su cui potevano essere bloccati lungo la guida dei cavalieri portalenti tramite una vite. Un ulteriore vite micrometrica permetteva una regolazione pi\\`u fine spostando lungo la direzione della guida un supporto mobile del cavaliere. Le immagini venivano in seguito proiettate su uno schermo di vetro opaco dotato di una griglia per la misurazione dell'ingrandimento della sorgente. La luce di una lanterna ad intensit\\`a variabile veniva selezionata per un breve intervallo di lunghezze d'onda da un filtro monocromatico. Il fascio di luce veniva inoltre ridotto da un diaframma da 0.5 mm. Un ulteriore diaframma veniva posto a monte della lente per selezionare la zona parassiale della lente. In questo modo si \\`e potuto evitare di considerare rilevanti fenomeni di aberrazione senza apportare un rilevante errore sistematico sulla misura. \\begin{center} Caratteristiche della lente $n^o$ 14 \\end{center} \\begin{center} Spessore = 10.10mm Spigolo = 2.60mm n = 1.5168 PP = %1.2fmm \\end{center} Il primo metodo sfrutta l'equazione delle lenti sottili $1/p + 1/q = 1/f$ dove $p$ \\`e la distanza della lente dalla sorgente, $q$ della lente dallo schermo e $f$ ovviamente il fuoco. Abbiamo cos\\`i misurato diversi valori di $p$ e di $q$ quando l'mmagine era a fuoco, calcolato i reciproci di tali valori per poter trovare la retta interpolante che descriveva la relazione lineare sopradetta. Dalla relazione notiamo che la retta dovrebbe avere pendenza $-1$ e come intercetta il reciproco del fuoco. I dati raccolti si dispongono infatti approssimativamente su tale linea come mostrato dal grafico.\\\\",PPC);
				# Figura
fprintf (Relazione,"\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{Coniugati10} \n \
  \\caption{}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n");          
				# Chiacchere
fprintf (Relazione,"I dati sono stati quindi interpolati (esclusi quelli al centro considerata la difficolt\\`a di determinare il punto preciso per la messa a fuoco essendo la distanza tra la sorgente e la lente prossima alla distanza dal fuoco) ed \\`e stato ricavato il valore del fuoco. Il primo calcolando il reciproco dell'intercetta");
				# Risultati
h = 1;
fprintf(Relazione,"\\begin{center} \n \\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sigmam(h),q(h),Sigmaq(h),r(h),Sigmay(h));
fprintf (Relazione,"\\begin{center} \n \
 $f_1  = %4.2f \\pm %4.4f $ \n \
\\end{center} \n \
ed il secondo per il valore dell'intersezione della retta \n \
coll'asse delle x. \n \
\\begin{center} \n \
$f_2  = %4.2f \\pm %4.4f$ \n \
\\end{center} \n \
Ed un terzo calcolando il rispettivo valore di $f$ al centro della retta interpolante. \\begin{displaymath}f_2  = %4.2f \\pm %4.4f \\end{displaymath} \n \
ricavandone cos\\`i il valore medio \n \
\\begin{center} \n \
$\\bar{f} = %4.2f \\pm %4.4f $ \n \
\\end{center} \n",f(2),Errf(2),f(3),Errf(3),f(1),Errf(2),fMedio,ErrfMedio);
                            #Chiacchere
fprintf (Relazione,"La determinazione della distanza focale si pu\\`o alternativamente determinare tramite il metodo di Bessel che consiste nel determinare le due posizioni possibili per la lente ad ogni data distanza tra lente e schermo. La differenza tra questi due valori verr\\`a utilizzata con la distanza lente-sorgente nella relazione \\begin{displaymath} f = \\frac{(p + q)^2+(p - q)^2}{4 \\cdot (p + q)} \\end{displaymath} per la determinazione del fuoco. Abbiamo quindi misurato venti coppie di valori a 50 cm centimetri di distanza tra sorgente e schermo ed altre venti alla distanza di 85 cm. I valori del fuoco ricavati hanno fornito i seguenti valori:");
fprintf (Relazione," \\begin{center}\\begin{tabular}{c c} \n \
$f = %4.2f$ & $\\pm %4.3f$ \\\\ \n \
$f = %4.2f$ & $\\pm %4.3f$ \\\\ \n \
$f = %4.2f$ & $\\pm %4.3f$ \\\\ \n \
$f = %4.2f$ & $\\pm %4.3f$ \\\\ \n \
$f = %4.2f$ & $\\pm %4.3f$ \\\\ \n \
$\\bar{f} = %4.2f$ & $\\pm %4.3f$ \\\\ \n \\end{tabular} \\end{center}\n",f(1),Errf(1),f(2),Errf(2),f(3),Errf(3),f(4),Errf(5),f(4),Errf(5),fMedia,ErrfMedia);
fprintf (Relazione, "Otteniamo infine il valore finale dato dalla media aritmetica e la tavola che mostra le comtabilit\\`a tra tutti i valori \n"); 

                                # CompInt
fprintf (Relazione, "\\begin{center} \n Compatibilit\\'a tra i valori \\\\ \n \\begin{tabular}{c c} \n Serie & Compatibilit\\`a \\\\ \n");
h = 1;
i = 1;
do
j = (i + 1);
do
Comp1(h) = sqrt((f(i) - f(j))**2) / sqrt( Errf(i)**2 + Errf(j)**2);
fprintf (Relazione, "%d - %d &  %4.2f \\\\ \n", i,j,Comp1(h));
h++;
j++;
until (j == 6)
i++;
until (i == 5)
fprintf(Relazione, "\\end{tabular}\\end{center}\n");
fprintf (Relazione,"Nel caso delle lenti divergenti la misurazione \
    della distanza focale risulta pi\\`u complessa poich\\'e il \
    punto di messa a fuoco \\`e dalla stessa parte di quello della \
    sorgente. Non si pu\\`o quindi posizionare lo schermo a valle \
    della lente perch\\'e coprirebbe la sorgente. Abbiamo quindi \
    deciso di posizionare l'immagine della sorgente tramite la lente \
    convergente precedentemente studiata e rilevare i sucessivi valori \
    di messa a fuoco e ingrandimento dell'immagine prodotta. Otteniamo \
    quindi una serie di valori compresi nella distanza focale della \
    lente divergente per cui il fuoco viene portato oltre la lente \
    sullo schermo. Ottenendo cos\\`i un valore di $f_{div} = %2.3f \
\\pm %2.4f$. Osserviamo per\\`o che tre sorgenti vengono poste oltre \
la lente divergente e scartando quei valori il valore della focale \
    viene $f_{div} = %2.3f \\pm %2.4f$, valore con lo stesso errore \
del precedente ma pi\\`u attenbibile visto che non dobbiamo considerare la deviazione del raggio da parte della lente.",-fD(3),ErrfD(3),-fD(5),ErrfD(5));
fprintf(Relazione,"\\begin{section}{Commenti} Sulla misura della \
    focale della lente convergente le cinque determinazioni portano a \
    risultati compatibili pur essendo i metodi di analisi \
    completemente diversi. Nel primo caso abbiamo utilizzato \
    l'interpolazione lineare mischiando valori provenienti da ogni \
    punto della scala confidando sulla linearit\\`a di questa mentre \
    nel secondo abbiamo considerato, in intervalli fissi, distanze \
    relative. La determinazione della focale della lente divergente \
    \\`e pi\\`u soggetta ad errore perch\\`e si avvale di pi\\`u \
    misure che contribuiscono all'errore nonch\\`e della nostra \
    determinazione della focale della lente divergente. Il risultato \
    \\`e comunque attendibile.\\end{section}");
fclose(Relazione);
				# Tabelle
Tabelle = fopen("Tabelle10.tex","w");
fprintf(Tabelle,"\\appendix \n Mostriamo le tabelle relative \
    all'esperimento sulle lenti mettendo in colonna i valori riferiti \
    ad $p$ e $q$ del metodo dei punti coniugati e del metodo di Bessel \
    \\begin{center}\\begin{tabular}{c c c c} \n Lente & Schermo & $p$ & $q$ \ 
    \\\\ \n");
for i = 1:33;
fprintf(Tabelle,"%3.1f & %3.1f & %3.1f & %3.1f   \\\\ \n ",Lente(i), Schermo(i),pCon(i),qCon(i));
endfor
fprintf(Tabelle,"\\end{tabular}\n\\end{center}\n");
fprintf(Relazione,"\\begin{center}\\begin{tabular}{c c c c} \n $p_{1B}$ &  $q_{1B}$ & $p_{2B}$ & $q_{2B}$ \\\\ \n");
for i = 1:20;
fprintf(Tabelle,"%3.1f & %3.1f & %3.1f & %3.1f  \\\\ \n ",pB1(i),qB1(i),pB2(i),qB2(i));
endfor
fprintf(Tabelle,"\\end{tabular}\n\\end{center}\n");
fprintf(Tabelle,"Presentiamo ora i valori rilevati nella \
    determinazione del punto focale della lente divergente.\n \
    \\begin{center}\\begin{tabular}{c c c c} Lente1 & Lente2 & \
    Schermo& I \\\\ \n");
for i = 1:15;
fprintf(Tabelle,"%3.3f & %3.3f & %3.3f  \\\\ \n ",Divergente(i),Convergente(i),qTot(i),Ing(i));
endfor
fprintf(Tabelle,"\\end{tabular}\n\\end{center}\n");
fclose(Tabelle);
				# Grafici
gset term latex;
gset data style points;
gset size 1,1.2;
gset pointsize 2;
h = 1;
GrfY.a = [X.a', Y.a']; 
GrfIY.a = [X.a', IY.a']; 
gset output 'Coniugati10.tex'; 
gset xlabel '1/p'; gset ylabel '1/q';
gplot GrfY.a with points, GrfIY.a with lines;
gset term x11;
replot;
kbhit();
				# Metodo Brutale
gset term latex
h = 1;
GrfY.e = [X.e', Y.e'];  
GrfIY.e = [X.e', IY.e']; 
gset output 'Brutale10.tex'; 
gset xlabel '1/p'; gset ylabel '1/q';
gplot GrfY.e with points 1, GrfIY.e with lines;
gset term x11;
replot;
kbhit();
				# Divergente1
gset term latex
h = 1;
GrfY.b = [X.b', Y.b'];  
GrfIY.b = [X.b', IY.b']; 
gset output 'Divergente10.tex'; 
gset xlabel ''; gset ylabel '';
gplot GrfY.b with points 1, GrfIY.b with lines;
gset term x11;
replot;
kbhit();
				# Divergente2

				# Ingrandimento

