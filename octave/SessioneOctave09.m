				# SessioneOctave09.m
cd ~/Boccolo/             
disp("Definizione delle costanti \n");
TMezzia       = [4.2, 3.5, 7.1, 5.9, 5.4, 5, 4.9, 4.8, 4.7, 4.65, 4.6, 4.5, 4.45, 4.4, 4.3, 4.2, 4.1, 4.05, 3.9, 5.5, 2.6, 3.4];
ScalaTMezzi   = [10, 5, 2, 2, 2, 2, 2, 2, 2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,1 ,2 ,1];
TMezzi        = TMezzia .* ScalaTMezzi;
VEntrataa     =  [3.8, 3.8 ,3.8 ,3.8 ,3.8 ,3.7 ,3.7 ,3.65 ,3.6 ,3.6 ,3.5 ,3.4 , 3.3, 3.3, 3.3, 3.3, 3.3, 3.4, 3.5, 3.8, 3.8, 3.9];
ScalaVEntrata = 0.2;
VEntrata      = VEntrataa * ScalaVEntrata;
VUscitaa      = [1.75, 2.2, 2.55, 3.3, 2.1, 2.5, 2.7, 2.95, 3.3, 3.5, 1.9, 2.1, 2.25, 2.3, 2.3, 2.3, 2.3, 2, 3.2, 2.3, 2.5, 3];
ScalaVUscita  = [0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 0.2, 0.2, 0.2, 0.05];
VUscita       = VUscitaa .* ScalaVUscita;
DeltaTa       = [0.3, 0.6, 0.6, 0.7, 1, 1.25, 1.4, 1.55, 1.8, 2, 2.5 ,2.7, 3, 1.75, 1.9, 2.2, 2.5, 2.8, 3, 5.4, 2.5, 3.25];
ScalaDeltaT   = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2 , 2, 2, 1, 2, 1];
DeltaT        = DeltaTa .* ScalaDeltaT;
Fr            = 1 ./ (2 * TMezzi) * 1000;
A             = VUscita ./ VEntrata;
An            = DeltaT ./ TMezzi * 360;
RCostr        = 180; ErrRCostr = RCostr * 0.05;
R             = 176.5;ErrR = 0.6 * R + 0.3;
LCostr = 0.0047; ErrLCostr = 0.1 * LCostr;
RL = 45.6;
CPost = 1.54*10**(-9); ErrCPost = 4.307*10**(-12);
QFStima       = 1 / RCostr * sqrt(LCostr / CPost);
VMass         = QFStima * VUscita(1);
VMassRil      = max(VUscita); AMassRil = max(A);
ValoreEfficace = AMassRil / sqrt(2);
QFRil         = VMassRil / VUscita(1);
NuCostr       = 1 / (2 * pi * sqrt(CPost * LCostr));
ErrNuCostr    = sqrt( (ErrCPost/CPost)**2/2 + (ErrLCostr/LCostr)**2/2)*NuCostr;
AnMax = max(An) / max(A);
RL = 45.6;ErrRL = RL * 0.006 + 0.03;
				# RettaInterpolante
function[m,q,Sigmay,Sigmam,Sigmaq,r,nRes,Cov,n,xbarra,ybarra] = Interpolazione(x,y);
n = length(x);
xbarra = mean(x);
ybarra = mean(y);
Delta = n * sum(x .** 2) - sum(x)**2;
q = (sum(x .** 2) * sum(y) - sum(x) * sum(x .* y)) / Delta;
m = (n * sum(x .* y) - sum(x) * sum(y)) / Delta;
Res = (q + m * x) .- y;
Sigmay = sqrt(sum( Res .** 2)/(n - 2));
Sigmam = Sigmay * sqrt(n / Delta);
Sigmaq = Sigmay * sqrt(sum(x .** 2) / Delta);
Cov = sum(x .* y)/n - xbarra*ybarra;
#Cov = (sum(x - xbarra) * sum(y - ybarra))/n;
Varx = sum((x - xbarra).**2)/ (n -1);
Vary = sum((y - ybarra).**2)/ (n -1);
r = Cov / sqrt (Varx * Vary) ;
l = 1;
nRes = 0;
do
if (Res(l)>0 &&  Res(l+1)<0)
nRes++; l++;
elseif (Res(l)<0 && Res(l+1)>0)
nRes++; l++;
else l++;
endif
until (l = n-1);
endfunction;
function[Cov] = Cov(x,y);
xbarra = mean(x);
ybarra = mean(y);
n = length(n);
Cov = sum(x .* y)/n - xbarra*ybarra;
endfunction;
function [Media,Err] = MediaPes(x,Errx);
n = length(x);
Peso  = sum(1 ./ (Errx.**2));
Media = sum(x ./  Errx.**2 ) / Peso;
Err   = sqrt(1 / Peso);
endfunction;
function [ErrR] = ErrRInd(a,b,Sa,Sb,r);
ErrR = sqrt( (Sa/a)**2 + (Sb/b)**2 - 2*r*Sa*Sb/(a*b));
endfunction;
				# Interpolandi
disp("ValoriDelleRetteInterpolanti \n");
x = ["a","b","c","d","e","f"]; i = 1; disp(i);
disp("Interpolandi: \n");
				# (Fr,A) (Fr,An) (Fr,A)
X.a = Fr; Y.a = A;
X.b = Fr; Y.b = A;
X.c = Fr; Y.c = An;
#X.d = ; Y.d = ;
#X.e = ; Y.e = ;
disp("Valori da interpolare \n");
XI.a = X.a(7:14); YI.a = Y.a(7:14);
XI.b = X.b(17:19); YI.b = Y.b(17:19); 
XI.c = X.c(6:19); YI.c = Y.c(6:19);
#XI.d = X.d(); YI.d = Y.d(); 
#XI.e = X.e(); YI.e = Y.e();
				# Valori della RettaInterpolante
disp("ValoriDelleRetteInterpolanti \n");
x = ["a","b","c","d","e","f"]; i = 1;
disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i),nRes(i)] = Interpolazione(XI.a, YI.a);  
i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i),nRes(i)] = Interpolazione(XI.b, YI.b);
i++; i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i),nRes(i)] = Interpolazione(XI.c, YI.c);
#i++; disp(i);
#[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i),nRes(i)] = Interpolazione(XI.d, YI.d);
#i++; disp(i);
#[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i),nRes(i)] = Interpolazione(XI.e, YI.e);
i = 1;
IY.a  = X.a * m(i) + q(i);
Res.a = XI.a * m(i) + q(i) .- YI.a;       i++;
IY.b  = X.b * m(i) + q(i);
Res.b = XI.b * m(i) + q(i) .- YI.b;       i++;i++;
IY.c  = X.c * m(i) + q(i);
Res.c = XI.c * m(i) + q(i) .- YI.c;       i++;
#IY.d  = X.d * m(i) + q(i);
#Res.d = XI.d * m(i) + q(i) .- YI.d;       i++;
#IY.e  = X.e * m(i) + q(i);
#Res.e = XI.e * m(i) + q(i) .- YI.e;       i++;
				# Valori Indiretti
disp("ValoriIndiretti \n");
Nu(1) = -(q(1) - q(2))/(m(1) - m(2));
Nu(2) = (ValoreEfficace - q(1))/(m(1));
Nu(3) = (ValoreEfficace - q(2))/(m(2));
Nu(4) = (90 - q(4))/(m(4));
ErrRm(1)  = Sigmam(1) / (m(1) - m(2));
ErrRm(2)  = Sigmam(2) / (m(1) - m(2));
ErrRq(1)  = Sigmaq(1) / (- q(1) + q(2));
ErrRq(2)  = Sigmaq(2) / (- q(1) + q(2));
ErrRm1a.x(1) = Sigmam(1) /  m(1);
ErrRm1a.x(2) = -Sigmam(2) /  m(2);
ErrRq1a.x(1) = -Sigmaq(1) / (q(1) - ValoreEfficace);
ErrRq1a.x(2) = Sigmaq(2) / (q(2) - ValoreEfficace);
ErrR(1)    = sqrt((ErrRm(1))**2 + (ErrRm(2))**2 + (ErrRq(1))**2 + \
		    ErrRq(2)**2 + \
		sqrt((2*r(1)/(m(1)*q(1))*Sigmam(1)*Sigmaq(1))**2) + \
		sqrt((2*r(2)/(m(2)*q(2))*Sigmam(2)*Sigmaq(2))**2) );
ErrR(2)    = sqrt( (ErrRm1a.x(1))**2 + (ErrRq1a.x(1))**2 + \
		    sqrt( (2*r(1)/(m(1)*q(1))*Sigmam(1)*Sigmaq(1))**2));
ErrR(3)    = sqrt((ErrRm1a.x(2))**2 + (ErrRq1a.x(2))**2 + \
		    sqrt((2*r(2)/(m(2)*q(2))*Sigmam(2)*Sigmaq(2))**2));
ErrR(4)    = sqrt((Sigmam(4) / m(4))**2 + (Sigmaq(4)/(90 - \
						q(4)))**2 + \
		    sqrt((2*r(1)/(m(1)*q(1))*Sigmam(1)*Sigmaq(1))**2));
#ErrNu = Nu .* ErrR;
ErrNu(1) = 1/m(1)*sqrt(Sigmaq(1)**2 + (Nu(2) *Sigmam(1))**2 + \
		       2*r(1)*Nu(2)*Sigmam(1)*Sigmaq(1));
ErrNu(2) = -1/m(2)*sqrt(Sigmaq(2)**2 + (Nu(3) *Sigmam(2))**2 + \
		       2*r(2)*Nu(3)*Sigmam(2)*Sigmaq(2));
ErrNu(3) = -1/(m(2) - m(1))*sqrt(Sigmaq(1)**2 + (Nu(3)*Sigmam(1))**2 + \
				2*r(1)*Nu(3)*Sigmam(1)*Sigmaq(1) + \
                             Sigmaq(2)**2 + (Nu(3)*Sigmam(2))**2 + \
				2*r(2)*Nu(3)*Sigmam(2)*Sigmaq(2));
ErrNu(4) = 1/m(4)*sqrt(Sigmaq(4)**2 + (Nu(4) *Sigmam(4))**2 + \
		       2*r(4)*Nu(4)*Sigmam(4)*Sigmaq(4));
[NuMedia,ErrNuMedia] = MediaPes(Nu,ErrNu);
QF = NuMedia / (Nu(3) - Nu(2));
ErrRQF = sqrt( (ErrNu(1)/Nu(1))^2 + (ErrNu(2)/ (Nu(3) - Nu(2)) )^2 + (ErrNu(3)/ (Nu(3) - Nu(2)) )^2);
ErrQF = QF * ErrRQF;
QF1 = QF;
ErrQF1 = ErrQF;
Delta = (Nu(3) - Nu(2))/2;ErrDelta = sqrt( (ErrNu(3)/Nu(3))**2 + (ErrNu(2)/Nu(2))**2)*Delta;
L = (2 * pi**2 * NuMedia**2 * CPost)^(-1);
ErrL = sqrt( (2*ErrNuMedia/NuMedia)**2 + (ErrCPost/CPost)**2 + \
	    0.01**2)*L;
RTot = 2*Delta*L*1000;ErrRTot = sqrt( (ErrDelta/Delta)**2 + (ErrL/L)**2 )*RTot;
RP = RTot - RL; ErrRP = sqrt( (ErrRTot/RTot)**2 + (ErrRL/RL)**2 )*RP
				# Controllo
i=1;
do;
j = 1;
a(j) = Nu(i);      Ris(i,j) = a(j);  j++;      
a(j) = ErrNu(i);   Ris(i,j) = a(j);  j++;     
a(j) = m(i);       Ris(i,j) = a(j);  j++;     
a(j) = Sigmam(i);  Ris(i,j) = a(j);  j++;     
a(j) = q(i);       Ris(i,j) = a(j);  j++;      
a(j) = Sigmaq(i);  Ris(i,j) = a(j);  j++;     
a(j) = Sy(i);      Ris(i,j) = a(j);  j++;      
a(j) = r(i);       Ris(i,j) = a(j);  j++;
a(j) = r(i)**2;    Ris(i,j) = a(j);  j++; 
a(j) = nRes(i);    Ris(i,j) = a(j);  j++; 
i++;
until (i == 4);
Ris(i,1) = NuMedia; Ris(i,2) = ErrNuMedia; Ris(i,3) = length(Fr);
				# Relazione
disp("Relazione \n");
Relazione = fopen("Relazione09.tex","w");
fprintf (Relazione," \\chapter{Caratteristiche dei Componenti Passivi \
			       di un Circuito} Nel seguente \
    esperimento ci siamo avvalsi di una basetta di montaggio su cui \
    abbiamo costruito un semplice circuito induttore e condensatore in \
    serie. Icircuito \\`e stato pilotato da un generatore di funzioni \
    in onda sinusoidale. Il segnale in uscita è stato prelevato \
    tramite dei cavi coassiali perch\\'e venisse visualizzato \
    dall'oscilloscopio per la determinazioni dei valori di tensione e \
    sfasamento rispetto all'onda in ingresso, prelevata anch'essa \
    tramite un cavo coassiale dal generatore di funzioni. Definiamo \
    ora la nomenclatura che utilizzeremo in seguito mostrano \
    l'equazione differenziale che descrive il circuito. \
    \n\\begin{displaymath}\\ddot Q - \\frac{R}{L}\\dot Q + Q \
    \\frac{1}{RC} = \\mathrm{i}(\\omega t) \\end{displaymath} Dove \
    $\\nu_0 = 1 / (2\\pi \\sqrt{RC})$ \\\\ \n");
	 fprintf(Relazione, " I dati raccolti sono riassunti nella \
    seguente tabella da cui abbiamo calcolato i valori della frequenza \
    $\\nu = 1 / T$, del guadagno $A = V_{entrata}/V_{Uscita}$ e \
    dell'angolo di sfasamento $\\phi = \\Delta T/T \\cdot 360$.\n");
fprintf(Relazione,"E Forniamo il valore delle componenti passive \
    utilizzate nel circuito. \n \\begin{displaymath}R = %4.0f \\pm %4.0f \\Omega \\quad C = %3.0G \\pm %3.0G F\\quad L = %3.0G \\pm %3.0G H \\end{displaymath}\n \\begin{displaymath} \\nu_{ris} = %3.2f \\pm %3.2f KHz \\end{displaymath} \n\\begin{center} \n \\begin{tabular}{c c c c c c} \n Frequenza & Guadagno & Angolo & $V_{Uscita}$ & $\\Delta T$ & $\\frac{T}{2}$ \\\\ \n",RCostr,ErrRCostr,CPost,ErrCPost,LCostr,ErrLCostr,NuCostr/1000,ErrNuCostr/1000);
for i = 1:22;
fprintf (Relazione,"%3.0f & %1.3f & %3.0f & %4.2f & %4.2f & %4.1f \\\\ \n ",Fr(i),A(i),An(i),VUscita(i),DeltaT(i),TMezzi(i));
endfor
fprintf (Relazione,"KHz&&grad&Volt&s&s\\end{tabular} \n \
\\end{center} \n \
Disponendo i punti in grafico possiamo notare che con il crescere della frequenza aumenta l'angolo di sfasamento mentre il guadagno raggiunge un massimo intorno ai 60 KHz e cala nuovamente. \n \
\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{Risonanza9}\\\\ \n \
\\caption{Funzionamento in Frequenza}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n \
Nel grafico il valore dell'angolo non corrisponde poich\\'e \\`e stato rapportato con il guadagno per permetterne la visualizzazione. Da questi dati abbiamo potuto ricavare la frequenza relativa al massimo, ovvero la costante di tempo del circuito, il fattore di merito e la larghezza corrispondente a $1/\\sqrt{2}$ di altezza rispetto al massimo. I valori sono stati ottenuti interpolando i dati in un intorno in cui le curve potevano essere approssimate a funzioni lineari.\\\\ Otteniamo cos\\`i i risultati delle due interpolazioni, una rispetto a $(ln(\\nu) ,A)$ e l'altra rispetto a $(ln(\\nu) ,\\phi )$. La seconda \\`e comprensiva dei dati: \n \
\\begin{center}  \n \
\\begin{tabular}{c c}  \n Frequenza(KHz)&Angolo \\\\ \n");
for i = 5:14;
fprintf (Relazione,"%3.0f & %1.3f \\\\ \n ",Fr(i),An(i));
endfor
h = 4;
fprintf(Relazione,"\\end{tabular} \n \\end{center} \n \
che mi permetteranno di calcolare i seguenti parametri dell'interpolazione lineare.\\begin{center} \n \
\\rule{0pt}{3ex} $y_{\nu} = m \\cdot x + q$ \\\\ \n \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sigmam(h),q(h),Sigmaq(h),r(h),Sy(h));
fprintf(Relazione,"Consideriamo ora la dipendenza del guadagno rispetto allo sfasamento. Dal grafico possiamo notare una curva a forma di campana che cresce nell'intorno della frequenza di taglio. Dividiamo questa in due fronti, uno di salita (a sinistra) e uno di discesa (a destra) e conduciamo separatamente le interpolazioni \\\\ \n Interpolando i dati del fronte di salita \\begin{center}\n\\begin{tabular}{c c} \n Frequenza(KHz) & Guadagno \\\\ \n");
for i = 6:14;
fprintf (Relazione,"%3.0f & %1.3f \\\\ \n ",Fr(i),A(i));
endfor
h = 1;
fprintf(Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf("Otteniamo \\begin{center} \n \
\\rule{0pt}{3ex} $y_{\\nu} = m \\cdot x + q$ \\\\ \n \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sigmam(h),q(h),Sigmaq(h),r(h),Sy(h));
fprintf(Relazione,"Mentre per il fronte di discesa: \\begin{center}\n \\begin{tabular}{c c}\n Frequenza(KHz)&Guadagno\\\\ \n");
for i = 17:19;
fprintf (Relazione,"%3.0f & %1.3f \\\\ \n ",Fr(i),A(i));
endfor
h = 2;
fprintf(Relazione,"\\end{tabular} \n \\end{center} \n");
fprintf(Relazione,"\\begin{center} \n \
\\rule{0pt}{3ex} $y_{\\nu} = m \\cdot x + q$ \\\\ \n \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sigmam(h),q(h),Sigmaq(h),r(h),Sy(h));
fprintf(Relazione,"Ora possiamo determinare gli altri parametri caratteristici della risonanza ovvero il fattore di merito ($Q_F$) e la larghezza della campana ($\\Delta = \\omega_2 - \\omega_1$). La larghezza della campana la determiniamo ricavando i valori di $\\nu_1$ e $\\nu_2$ per $A = A_{risonanza} / \\sqrt{2}$.");
fprintf(Relazione,"\\begin{center} $\\nu_1 = %4.2f \\pm %4.3f $\\\\ \n $\\nu_2 = %4.2f \\pm %4.3f $ \n",Nu(2),ErrNu(2),Nu(3),ErrNu(3));
fprintf(Relazione," \\end{center} \n \
Il fattore di merito possiamo ricavarlo dividendo la frequenza di risonanza per la larghezza della campana, \n \
\\begin{center} \n");
fprintf(Relazione,"$\\nu_{risonanza}/(\\nu_2-\\nu_1)$ $ = Q_F = %4.2f \\pm$ %4.3f \n",QF,ErrQF);
fprintf(Relazione,"\\end{center} \n");
fprintf(Relazione,"Da questo, nota la capacit\\`a dal \
    precedente esperimento, ricaviamo il valore dell'induttanza dalla \
    relazione \n \\begin{displaymath} Q_F = \
    \\frac{1}{R\\sqrt{L/R}}\\end{displaymath} ovvero \
    \\begin{displaymath} L = %4.2G \\pm %4.3G mH\
\\end{displaymath} \n",L*1000,ErrL*1000);
fprintf(Relazione,"Ricaviamo infine il valore del fattore di \
	smorzamento che tramite la larghezza della campana fornisce il \
	valore dela resistenza serie dell'induttanza. \
	\n \\begin{displaymath} R = 2 \\delta L\\end{displaymath} \
	\n \\begin{displaymath} R = %3.3f \\pm %3.4f \
\\end{displaymath} \
\n ",RTot,ErrRTot);
fprintf(Relazione,"Il valore della resistenza \\`e per\\`o maggiore di \
	quella misurata indipendentemente dl multimetro. Possiamo \
	quindi stabilire il valore della resistenza parassita del \
	circuito in serie alla resistenza sottraendo il valore appena \
	ricavato a quello noto dell'induttanza. \
    \\begin{displaymath}R_p = R_{Tot} - R_L  = %4.2f \\pm \
%4.3f\\end{displaymath} ",RP, ErrRP);
fprintf(Relazione,"\\begin{section}{Commenti} I valori ottenuti del guadagno mostrano un pesante difetto nella campana di risonanza. I valori del massimo sono stati troncati e ben cinque dati assumono lo stesso valore. Il valore in questione della tensione in uscita \\`e di $4.6V$ ed evidentemente supera la portata massima dell'oscilloscopio anche se durante la presa dei dati non si era osservata alcuna deformazione della sinusoide. \\\\In questa condizione i dati al di sotto del valore limite non subiscono alterazioni e l'analisi dei parametri della curva di risonanza sarebbe tuttora possibile essendo il troncamento nella parte finale della curva. I dati rimasti sono per\\`o pochi come per esempio l'interpolazione del fronte di discesa consistente di soli tre punti. La determinazione della frequenza di taglio \\`e infatti incompatibile con quella ricavata dai valori di sfasamento che mostrano migliori risultati dall'interpolazione lineare: per il numero di dati, per il coefficiente di correlazione lineare, il numero di variazione di segno sui residui... Sar\\`a quindi quest'ultimo valore quello utile per ricavare la frequenza di taglio mentre il Q fattore ottiene un valore completamente falsato anche se l'errore non \\`e troppo grande.\\end{section}\n");
fclose(Relazione);
				# Tabelle
Tabelle = fopen("Tabelle09.tex","w");
fprintf(Tabelle,"\\appendix \n Mostriamo le tabelle relative \
    ai valori ottenuti dall'oscilloscopio nell'esperimento della \
    configurazione Passa Banda\
    \\begin{center}\\begin{tabular}{c c c c c c c c} \n $V_{in}$ & Scala$V_{in}$ & $V_{out}$ &  Scala$V_{out}$ & $\\Delta T$ & Scala$\\Delta T$ & $T/2$ & Scala$t/2$ \\\\ \n");
for i = 1:22;
  fprintf(Tabelle,"%3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f\\\\ \n ",VEntrataa(i),0.2,VUscitaa(i),ScalaVUscita(i),DeltaTa(i),ScalaDeltaT(i),TMezzi(i),ScalaTMezzi(i));
endfor
fprintf(Tabelle,"V & V & V & V & $\\mu s$ & $\\mu s$ & $\\mu s$ & $\\mu s$ \\end{tabular}\n\\end{center}\n");
fclose(Tabelle);
				# Grafici
disp("Salva i grafici \n");
gset term latex;
gset data style points;
gset function style lines;
gset linestyle 1 lt 1 lw 1 pt 1 ps 2;
gset linestyle 2 lt 1 lw 1 pt 1 ps 2;
gset linestyle 3 lt 1 lw 1 pt 1 ps 2;
gset linestyle 4 lt 1 lw 1 pt 1 ps 2;
gset linestyle 5 lt 1 lw 1 pt 1 ps 2;
gset linestyle 6 lt 1 lw 1 pt 1 ps 2;
gset size 1,1.2
disp("AngoloGuadagno \n");
h = 1;
GrfA.a = [X.a', Y.a']; GrfA.c = [X.c', (Y.c/AnMax)'];
GrfAI.a = [X.a', IY.a']; GrfAI.b = [X.b', IY.b'];GrfAI.c = [X.c',(IY.c/AnMax)'];
gset output 'Risonanza9.tex'; 
gset xlabel 'ln(Frequenza)'; gset ylabel '$A, \\phi$';
gset arrow from 53.8,4.92 to 0,4.92;
gset arrow from 53.8,4.92 to 62,4.92;
gset arrow from 62.8,4.92 to 53.8,4.92;
#gset arrow from 60,10  to 60,0;
gset arrow from 53.8,1.77 to 53.8,0;
gplot  [0:100] [0:10] GrfA.a with linespoint title 'Guadagno', GrfAI.a \
    with lines title '',GrfA.c with linespoint title'Angolo', GrfAI.b with lines title '', GrfAI.c with lines title '';
gset term x11;
replot;
disp("Va la be'?");
kbhit()
disp("Bu li stes! \n");
                    #Angolo
gset term latex;
gset noarrow
h = 3;
GrfA.c = [X.c',Y.c']; 
GrfIA.c = [X.c', IY.c']; 
gset output 'Angolo9.tex'; 
gset xlabel '$ln(\\nu)$'; gset ylabel '$\\phi$';
gplot [20:100][0:400] GrfA.c title'Angolo' with linesp, GrfIA.c with lines title'';
gset term x1;
replot;
				# Fine






