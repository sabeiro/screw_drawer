				# SessioneOctave08.m
#cd ~/Boccolo/             
disp("Definizione delle costanti \n");
VEntrataa = [3.9,3.9,3.9,3.9,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.8,3.9,3.8,3.8,3.8];
VEntrata = VEntrataa * 0.2;
VUscitaa = [1.55,1.60,1.70,1.85,3.30,2.25,2.60,3.00,1.65,2.00,2.20,2.40,2.60,2.70,2.80,3.00,3.00,3.20,3.50,3.80,4.10,4.10,4.10];
ScalaVUscita = [0.05,0.05,0.05,0.05,0.05,0.1,0.1,0.1,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2];
VUscita = VUscitaa .* ScalaVUscita;
DeltaTa = [4.80,2.00,2.10,2.30,2.40,2.70,1.55,1.70,1.80,2.10,2.30,2.50,2.65,2.70,2.80,2.90,1.20,1.25,1.30,1.40,0.40,0.40,0.10];
ScalaDeltaT = [0.2,0.5,0.5,0.5,1,1,2,2,2,2,2,2,2,2,2,2,5,5,5,5,20,20,50];
DeltaT = DeltaTa .* ScalaDeltaT;
TMezzi = [4.3,2.2,2.4,5,2.8,3.3,3.85,4.5,2,2.45,3,3.3,3.8,4.15,4.4,5.1,5.2,3.45,3.9,3,2.2,2.8,3.4];
ScalaTMezzi = [0.5,1,1,.5,2,2,2,2,5,5,5,5,5,5,5,5,5,10,10,20,100,100,200];
TMezzi = 2 * TMezzi .* ScalaTMezzi;
Frequenza = 1 ./ TMezzi *  1000;
An = DeltaT ./ TMezzi * 360;
AVolt = VUscita ./ VEntrata;
ErrFrequenza = 0.02 * Frequenza;
ErrFr = log(ErrFrequenza);
ErrAn = sqrt( 0.02^2 + 0.02^2 )*An;
ErrA =  sqrt( 0.02^2 + 0.02^2 )*AVolt;
RNom = 4700;ErrRNom = 4700 * 0.05;
CNom = 1.5 * 10**(-9); ErrCNom = 0.06 * CNom;
NuNom = 1/2/3.14/RNom/CNom/1000; ErrNuNom = sqrt((ErrRNom/RNom)**2 + \
						 (ErrCNom/CNom)**2) * \
    NuNom;
AnMax = max(An);
ASemiLarg = max(AVolt)/sqrt(2);
				# Funzione Interpolazione
disp("Definizione delle funzioni dei parametri della retta \
    interpolante \n");
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
Fr.a = log(Frequenza); A.a = AVolt;
Fr.b = log(Frequenza); A.b = An;
Fr.c = log(Frequenza); A.c = log(AVolt);
Fr.d = Frequenza.**2 ;     A.d = AVolt .**(-2);
Fr.e = Frequenza;      A.e = tan(An * pi/180);
disp("Valori da interpolare \n");
				# Valori Da Interpolare
FrI.a = Fr.a(5:18); AI.a = A.a(5:18);    
FrI.b = Fr.b(5:18); AI.b = A.b(5:18); 
FrI.c = Fr.c(5:12); AI.c = A.c(5:12);
FrI.d = Fr.d(6:23); AI.d = A.d(6:23); 
FrI.e = Fr.e(5:23); AI.e = A.e(5:23);
disp("ValoriDelleRetteInterpolanti \n");
				# Valori Delle Rette Interpolanti
x = ["a","b","c","d","e","f"]; 
i = 1;
[m(i),q(i),Sy(i),Sm(i),Sq(i),r(i)] = Interpolazione(FrI.a, AI.a);
i = 2; 
[m(i),q(i),Sy(i),Sm(i),Sq(i),r(i)] = Interpolazione(FrI.b, AI.b);
i = 3; 
[m(i),q(i),Sy(i),Sm(i),Sq(i),r(i)] = Interpolazione(FrI.c, AI.c);
i = 5; 
[m(i),q(i),Sy(i),Sm(i),Sq(i),r(i)] = Interpolazione(FrI.d, AI.d);
i = 6; 
[m(i),q(i),Sy(i),Sm(i),Sq(i),r(i)] = Interpolazione(FrI.e, AI.e);
i = 1;
IA.a  = Fr.a * m(i) + q(i);
Res.a = FrI.a * m(i) + q(i) .- AI.a;       i++;
IA.b  = Fr.b * m(i) + q(i);
Res.b = FrI.b * m(i) + q(i) .- AI.b;       i++;
IA.c  = Fr.c * m(i) + q(i);
Res.c = FrI.c * m(i) + q(i) .- AI.c;       i++;i++;
IA.d  = Fr.d * m(i) + q(i);
Res.d = FrI.d * m(i) + q(i) .- AI.d;       i++;
IA.e  = Fr.e * m(i) + q(i);
Res.e = FrI.e * m(i) + q(i) .- AI.e;       i++;
				# Valori Indiretti
disp("ValoriIndiretti \n");
i = 1;
Nu(i) = exp( -( q(i) - ASemiLarg)/m(i) ); 
ErrNu(i) = sqrt((Sq(i)/m(i))**2 + \
             (Sm(i)*(q(i) - 1/sqrt(2))/m(i)**2) **2  - \
 		    2*r(i)*Sm(i)*Sq(i)/(m(i)*q(i)));
i = 2;
Nu(i) = exp( -(q(i) - 45)/m(i) ); 
ErrNu(i) = sqrt( (Sq(i)/m(i))**2 + \
             (Sm(i)*(q(i) - 45) / m(i)**2) **2 - \
 		    2*r(i)*Sm(i)*Sq(i)/(m(i)*q(i)));
i = 3;
Nu(i) = exp(q(i));
ErrNu(i) = Sq(i)/q(i)*Nu(i);
i = 4;
Nu(i) = exp(-q(3)/m(3));
ErrNu(i) =  sqrt( (Sq(3)/q(3))**2 + \
		       (Sm(3)/m(3))**2 + \
		    2*r(3)*Sm(3)*Sq(3)/(m(3)*q(3)) )*Nu(i);
i = 5;
Nu(i) = sqrt(1/m(i));
ErrNu(i) = Sm(i)/2/m(i)*Nu(i);
i = 6;
Nu(i) = 1/m(i);
ErrNu(i) = Sm(i)/m(i)*Nu(i);
NuMedio = (Nu(1) + Nu(2))/2; ErrNuMedio = sqrt(ErrNu(1)**2 + \
						   ErrNu(2)**2);
NuBuono = [Nu(1),Nu(2),Nu(5),Nu(6)];
ErrNuBuono = [ErrNu(1),ErrNu(2),ErrNu(5),ErrNu(6)];
[NuMedia,ErrNuMedia] = MediaPes(NuBuono,ErrNuBuono);
#[NuMedia,ErrNuMedia] = MediaPes([Nu(1:2),Nu(5:6)],[ErrNu(1:2),ErrNu(5:6)]);
CPost = 1 / (2*3.14*RNom*NuMedia*1000); 
ErrCPost = ErrNuMedia / NuMedia * CPost;
				# Controllo
i=1;
do;
j = 1;
a(j) = Nu(i);      Ris(i,j) = a(j);  j++;      
a(j) = ErrNu(i);   Ris(i,j) = a(j);  j++;     
a(j) = m(i);       Ris(i,j) = a(j);  j++;     
a(j) = Sm(i);      Ris(i,j) = a(j);  j++;     
a(j) = q(i);       Ris(i,j) = a(j);  j++;      
a(j) = Sq(i);      Ris(i,j) = a(j);  j++;     
a(j) = Sy(i);      Ris(i,j) = a(j);  j++;      
a(j) = r(i);       Ris(i,j) = a(j);  j++;
a(j) = r(i)**2;    Ris(i,j) = a(j);  j++; 
i++;
until (i == 7);
Ris(i,1) = NuMedia; Ris(i,2) = ErrNuMedia; Ris(i,3) = length(Frequenza);
				# Relazione
disp("Relazione \n");
Relazione = fopen("Relazione08.tex","w");
fprintf (Relazione,"\\chapter{Caratteristiche dei Componenti di un Circuito}La seguente esperienza tratter\\`a del comportamento di un circuito RC in risposta ad un segnale sinusoidale a frequenza variabile creato da un generatore di funzioni. Un oscilloscopio permetter\\`a di visualizzare la tensione in uscita dal circuito su uno schermo. Questo schermo tramite la differenza di potenziale tra le piastre rappresenta sull'asse delle ordinate la tensione del segnale prelevato  ed il tempo sull'asse delle ascisse. Nell'intorno della frequenza di taglio propria del circuito abbiamo rilevato una ventina di punti che riportassero chiaramente l'andamento in frequenza della tensione in uscita. \n \\begin{center}\\setlength{\\unitlength}{3cm}\\begin{picture}(0,1)\\linethickness{0.075mm}\\newsavebox{\\Res}\\savebox{\\Res}(0,0){\\multiput(0,0)(.2,0){2}{\\line(1,1){.1}}\\multiput(.1,0)(.2,0){3}{\\line(1,-1){.1}}}\\newsavebox{\\Con}\\savebox{\\Con}(0,0){\\multiput(-.1,-.2)(0,.2){2}{\\line(1,0){.2}}}\\put(0,1){\\circle*{.05}}\\put(0,1){\\line(1,0){.1}}\\put(.3,1){\\usebox{\\Res}}\\put(.50,1){\\line(1,0){.5}}\\put(1,1){\\circle*{.05}}\\put(.7,1){\\circle*{.05}}\\put(.7,.6){\\line(0,1){.3}}\\put(.7,.5){\\usebox{\\Con}}\\put(.7,0){\\line(0,1){.4}}\\put(.7,0){\\circle*{.05}}\\put(0,0){\\circle*{.05}}\\put(0,0){\\line(1,0){1}}\\put(1,0){\\circle*{.05}}\\put(.61,.42){$C$}\\put(.22,.92){$R$}\\put(-.05,.1){\\line(1,0){.1}}\\put(0,.4){\\vector(0,-1){.3}}\\put(-.2,.5){$V_{in}$}\\put(0,.6){\\vector(0,1){.3}}\\put(-.05,.9){\\line(1,0){.1}}\\put(.95,.1){\\line(1,0){.1}}\\put(1,.4){\\vector(0,-1){.3}}\\put(.85,.5){$V_{out}$}\\put(1,.6){\\vector(0,1){.3}}\\put(.95,.9){\\line(1,0){.1}}\\end{picture}\\end{center} \n");
fprintf(Relazione,"Riportiamo inoltre i valori nominali delle componenti passive \\begin{displaymath}R = %4.0f \\quad \\sigma_R = %4.0f \\Omega \\qquad C = %4.2G \\quad \\Delta_C = %4.2G F\\end{displaymath} Ed il valore della frequenza nominale \\begin{center} $\\nu = %3.1f \\quad \\Delta_\\nu = %3.2f KHz $\\end{center}", RNom, ErrRNom,CNom,ErrCNom,NuNom, ErrNuNom);
fprintf(Relazione,"\\begin{center} \n \
\\begin{tabular}{c c c c c c} \n Frequenza & Guadagno & Angolo & $V_{Uscita}$ & $\\Delta T$ & $\\frac{T}{2}$ \\\\ \n");
for i = 1:23;
fprintf (Relazione,"%3.0f & %1.3f & %2.1f & %4.2f & %4.2f & %4.1f \\\\ \n ",Frequenza(i),AVolt(i),An(i),VUscita(i),DeltaT(i),TMezzi(i));
endfor
fprintf (Relazione,"KHz&&rad&Volt&s&s\\end{tabular} \n \
\\end{center} \n \
Da questi dati abbiamo ricavato il guadagno $A =V_{entrata}/V_{uscita}$ e l'angolo di sfasamento $\\phi = \\Delta T/T*360$ e ricavato questo grafico: \n \
\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{AAn8} \n \
\\caption{Andamento in Frequenza}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n");
fprintf(Relazione,"Dove l'asse delle ascisse \\`e espresso in scala logaritmica. La scala dell'angolo \\`e stata normalizzata per la riuscita del grafico Dalla teoria, ovvero dalla stessa definizione della frequenza di taglio, sappiamo che il suo valore corrisponde a $A/\\sqrt{2}$  o ad un angolo di $45$ . Interpolando in un intorno approssimabile ad una retta otteniamo rispetto all'angolo. \n \\begin{center} \n $y_{ln(\\nu)} = m_{\\frac{ln(\\nu)}{rad}} \\cdot x_{rad} + q_{ln(\\nu)}$ \\\\ \n \\end{center} \n");
h = 2;
fprintf(Relazione,"\\begin{center} \n \\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sm(h),q(h),Sq(h),r(h),Sy(h));
fprintf(Relazione,"e rispetto ad A: \n");
h = 1;
fprintf(Relazione,"\\begin{center} \n \\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3G $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sm(h),q(h),Sq(h),r(h),Sy(h));
fprintf(Relazione,"Che permette di ricavare due determinazioni della frequenza di taglio \n \\begin{center} \n");
fprintf(Relazione,"$\\nu_{t}$ = %4.2f$\\pm %4.3f$\\\\ $\\nu_{t}$ = %4.2f$\\pm %4.3f$ \n",Nu(1),ErrNu(1),Nu(2),ErrNu(2));
fprintf(Relazione," \\end{center} \n \
e la loro media \n \
\\begin{center} \n");
fprintf(Relazione,"$\\nu_{t}$ = %4.2f $\\pm$ %4.3f \n",NuMedio,ErrNuMedio);
fprintf(Relazione,"\\end{center} \n \
potendo ora ricavare un valore pi\\`u affidabile della capacit\\`a ( che dalle specifiche del costruttore ha un errore del 20 per cento) dal valore della costante di tempo e delle resistenza di minore errore. \n \
\\begin{center} \n");
fprintf(Relazione,"$C$ = %2.2G $\\pm$ %2.4G  \n",CPost,ErrCPost);
fprintf(Relazione," \\end{center} \n \
Un metodo alternativo consiste nell'esplicitare frequenza ed A in valore logaritmico disegnando cosi` il grafico di Bode. \n \ 
\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{Bode8} \n \
  \\caption{DatiOscilloscopio}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n \
L'andamento atteso per questa rappresentazione \\`e che la pendenza \n \
della retta interpolante valga 1 nell'intervallo di linearit\\`a. \n \
\\begin{center} \n \
\\begin{tabular}{c c} \n \
$ln(\\nu)$&$ln(A)$\\\\ \n ");
for i = 1:9
fprintf(Relazione,"%4.2f & %4.3f \\\\ \n",Fr.c(i),A.c(i));
endfor
fprintf(Relazione,"\\end{tabular} \n \
\\end{center} \n \
questo e` di fatto confermato dai risultati \n \
\\begin{center} \n");
h = 3;
fprintf(Relazione,"\\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sm(h),q(h),Sq(h),r(h),Sy(h));
fprintf(Relazione,"escluso ovviamente il valore poco attendibile molto al di sopra della retta. L'ultimo metodo consiste nel ricavare la frequenza di taglio interpolando le variabili $(\\nu , A^{-2})$ e le variabili $(\\nu , tan(\\phi)$. La prima interpolazione fornisce: \n \
\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{A8} \n \
\\caption{Andamento in Frequenza}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n \
\\begin{center} \n");
h = 5;
fprintf(Relazione,"\\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n Mentre la seconda \n \
\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{An8} \n \
\\caption{Andamento in Frequenza}\\label{Black} \n \
\\end{figure} \n \
\\end{center} \n",m(h),Sm(h),q(h),Sq(h),r(h),Sy(h));
h = 6;
fprintf(Relazione,"\\begin{center} \n \\rule{0pt}{3ex} \
m = %4.2g $\\pm$ %4.3g \\\\ \n \
q = %4.2g $\\pm$ %4.3g \\\\ \n \
r = %4.3g $\\sigma_y$ = %4.3g \\\\ \n \
\\end{center} \n",m(h),Sm(h),q(h),Sq(h),r(h),Sy(h));
fprintf(Relazione,"Possiamo quindi confrontare tutti i risultati ottenuti valutandone la compatibilit\\`a per mostrare come determinazioni indipendenti (voltaggio, frequenza e sfasamento) portino tutte allo stesso risultato. Potremo in tal caso escludere l'influenza di errori sistematici rilevanti. \\\\ \n Questi valori vengono qu\\`i riassunti e ne viene presentata la media. \n \
\\begin{center} \n \
\\begin{tabular}{c c} \n");
for i = 1:6
fprintf(Relazione,"$\\nu_%i $ = %4.2f & $ \\pm $ %4.3f \\\\ \n",i,Nu(i),ErrNu(i));
endfor
fprintf(Relazione,"$\\bar\\nu$ = %4.2f &$\\pm %4.3f$ \\\\ \n",NuMedia,ErrNuMedia);
fprintf(Relazione,"\\end{tabular} \n \
\\end{center} \n");
                                # Compatibilit`a
fprintf (Relazione, "Mostriamo ora la tavola compatibilit\\`a anche se il numero di dati da cui sono state ricavate le frequenze non giustifica tale strumento, il loro uso servir\\`a solo per dare un idea dell'insieme dei valori indiretti ricavati da analisi indipendenti \\begin{center} \n Compatibilit\\'a tra i valori \\\\ \n \\begin{tabular}{c c} \n Serie & Compatibilit\\`a \\\\ \n");
h = 1;
i = 1;
do
j = (i + 1);
do
Comp1(h) = sqrt((Nu(i)-Nu(j))**2) / sqrt( ErrNu(i)**2 + ErrNu(j)**2);
fprintf (Relazione, "%d - %d &  %4.3f \\\\ \n", i,j,Comp1(h));
h++;
j++;
until (j == 7)
i++;
until (i == 6)
fprintf(Relazione, "\\end{tabular} \n \\end{center} \n");
fprintf(Relazione,"Ottenuto un valore affidabile della cerchiamo il valore delle componenti passive confrontando i risultati con quelli nominali. Possiamo cos\\'i stabilire la presenza di impedenze parassite nel circuito o nella connessione \n \\\\ Abbiamo ottenuto il seguente valore a posteriori della capacit\\`a  \\begin{displaymath} C_{post} = %3.3g \\pm %3.4g F \\end{displaymath}",CPost,ErrCPost);
fprintf(Relazione,"\\par{\\Large Commenti} \\\\ Nella seguente \
																											  esperienza abbiamo utilizzato metodi diversi per ricavare la frequenza di taglio di un circuito RC in configurazione passa basso. ");
fprintf(Relazione,"\\begin{section}{Commenti} Nella seguenta esperienza abbiamo utilizzato diversi metodi di analisi per determinare sei valori della frequenza di taglio che mostrano valori generalmente compatibili ma con errori molto diversi. Pur essendo l'interpolazione lo strumento di analisi utilizzato, alcune relazioni sono pi\\`u corrette in approssimazioni di rette o verificano meglio la proporzionalit\\`a tra le due grandezze. Il grafico di Bode ha l'andamento atteso anche se la pendenza della retta si discosta da -1 ed il corrispettivo valore della frequenza di taglio  assume un valore poco attendibile oltre ad un alto errore. Generalmente possiamo vedere che le determinazioni attraverso l'asse dei tempi sono pi\\`u precise forse perch\\'e si poteva disporre del righello in ogni punto o perch\\'e il passaggio dell'asse era pi\\`u netto. Stabilita cos\\`i la frequenza di taglio abbiamo ricavato un valore pi\\`u preciso della capacita che useremo nella prossima esperienza.\\end{section}\n");
fclose(Relazione);
Tabelle = fopen("Tabelle08.tex","w");
fprintf(Tabelle,"\\appendix \n Mostriamo le tabelle relative \
    ai valori ottenuti dall'oscilloscopio nell'esperimento della \
    configurazione Passa Basso\
    \\begin{center}\\begin{tabular}{c c c c c c c c} \n $V_{in}$ & Scala$V_{in}$ & $V_{out}$ &  Scala$V_{out}$ & $\\Delta T$ & Scala$\\Delta T$ & $T/2$ & Scala$t/2$ \\\\ \n");
for i = 1:20;
  fprintf(Tabelle,"%3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f & %3.1f\\\\ \n ",VEntrataa(i),0.2,VUscitaa(i),ScalaVUscita(i),DeltaTa(i),ScalaDeltaT(i),TMezzi(i),ScalaTMezzi(i));
endfor
fprintf(Tabelle,"V & V & V & V & $\\mu s$ & $\\mu s$ & $\\mu s$ & $\\mu s$ \\end{tabular}\n\\end{center}\n");
fclose(Tabelle);
				# Grafici
disp("Salva i grafici \n");
gset term latex;
gset data style linespoint;
gset  linestyle 1 lt 1 lw 1 ps 2;
gset  linestyle 2 lt 1 lw 1 ps 2;
gset size 1,1.2
h = 1;
GrfA.a = [Fr.a',A.a',ErrA']; GrfA.b = [Fr.b', (A.b / AnMax)',(ErrAn /AnMax)'];
GrfIA.a = [Fr.a', IA.a']; GrfIA.b = [Fr.b', (IA.b / AnMax)'];
gset output 'AAn8.tex'; 
gset xlabel 'Ln(Frequenza)'; gset ylabel '$A$ \\\\ $\\Delta\\phi$';
gplot [1:6] [0:1.4] GrfA.a with yerrorbars title '$A$' , GrfIA.a with lines \
    title '', GrfA.b with yerrorbars title '' , GrfIA.b with lines \
    title 'Sfasamento',GrfA.a with lines 3,GrfA.b with lines 3;
gset term x11;
gset noarrow;
replot;
kbhit()

				# Bode
gset term latex;
h = 3;
GrfA.c = [Fr.c',A.c']; 
GrfIA.c = [Fr.c', IA.c']; 
gset output 'Bode8.tex'; 
gset xlabel '$\\log\\nu$'; gset ylabel '$\\log A$';
gplot [1:6] [-2.5:0] GrfA.c with linesp title '', GrfIA.c with lines \
    title '';
gset term x1;
replot;
kbhit()

				# RelazioneBaruffa
gset term latex;
h = 5;
GrfA.d = [Fr.d(6:23)', A.d(6:23)']; 
GrfIA.d = [Fr.d(6:23)', IA.d(6:23)']; 
gset output 'A8.tex'; 
gset nologscale;
gset xlabel '$\\nu$'; gset ylabel '$A^{-2}$';
gplot GrfA.d with linesp title '', GrfIA.d with lines title '';
gset term x11;
replot;
kbhit()
				# RelazioniBaruffe
gset term latex;
h = 6;
GrfA.e = [Fr.e(5:23)', A.e(5:23)']; 
GrfIA.e = [Fr.e(5:23)', IA.e(5:23)']; 
gset output 'An8.tex'; 
gset xlabel '$1/\\nu$'; gset ylabel 'tg(Angolo)';
gplot GrfA.e title '' with linesp, GrfIA.e title '' with lines;
gset term x11;
replot;
				#Fine
