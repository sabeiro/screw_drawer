cd ~/Boccolo/             
disp("Definizione delle costanti \n");
RadBlu = [0.037,0.075,0.113,0.150,0.188];
RadAzzurra =[0.038,0.077,0.116,0.155,0.194];
RadVerde =[0.041,0.082,0.122,0.164,0.206];
RadRossa =[0.052,0.104,0.156,0.208,0.266];
Passo = 12650;ErrPasso = 50;
Calibr = [1.669,1.670,1.669,1.669,1.670,1.751,1.752,1.751,1.751,1.752];
Centro = 1.71043;
Differenze = [Centro - Calibr(1),Centro - Calibr(2),Centro - Calibr(3),Centro - Calibr(4),Centro - Calibr(5),Calibr(6) - Centro,Calibr(7) - Centro,Calibr(8) - Centro,Calibr(9) - Centro,Calibr(10) - Centro];
Scarto = std(Differenze);
ErrRY = sqrt( (sin(Scarto)./ sin(Differenze)).**2 + (ErrPasso/Passo)**2 );
Theta1 = 1.40;Theta2 = 2.45;DeltaTheta = Theta2 - Theta1;
Alpha = pi - DeltaTheta;
ThMinG1(2) = 113;ThMinG1(4) = 112;ThMinG1(1) = 113;ThMinG1(3) = 112;
ThMinM1(2) = .26;ThMinM1(4) = .38;ThMinM1(1) = .54;ThMinM1(3) = .56;
Th0G1(2)   = 162;Th0G1(4)   = 162;Th0G1(1)   = 161;Th0G1(3)   = 162;
Th0M1(2)   = .24;Th0M1(4)   = .08;Th0M1(1)   = .38;Th0M1(3)   = .36;
ThMinG2(2) = 279;ThMinG2(4) = 281;ThMinG2(3) = 284;ThMinG2(1) = 280;
ThMinM2(2) = .12;ThMinM2(4) = .10;ThMinM2(3) = .56;ThMinM2(1) = .24;
Th0G2(2)   = 330;Th0G2(4)   = 333;Th0G2(3)   = 335;Th0G2(1)   = 331;
Th0M2(2)   = .12;Th0M2(4)   = .06;Th0M2(3)   = .36;Th0M2(1)   = .42;
ThMin1 = (ThMinG1 .- ThMinM1/.6)/360*2*pi;
Th01   = (Th0G1 .- Th0M1/.6)/360*2*pi;
ThMin2 = (ThMinG2 .- ThMinM2/.6)/360*2*pi;
Th02   = (Th0G2 .- Th0M2/.6)/360*2*pi;
Delta1 = Th01 .- ThMin1;
Delta2 = Th02 .- ThMin2;
Delta = (Delta1 + Delta2)/2
Ordine = [1:5];
Colore = ["Blu";"Azzurro";"Verde";"Rosso"];
d = 12.65; Errd = 0.05;
n = sin((Alpha + Delta2)/2) / sin(Alpha/2);
Errn = sqrt( ( Scarto./(tan((Alpha + Delta)/2))).**2 + \
	     ( Scarto*(1/(2*sin(Alpha/2)**2) + \
		     1./(2*tan((Alpha+Delta)/2))).**2) ).*n; 
Lambda = [473.5,489.61,516.72,663.47];
disp("Definizione delle funzioni dei parametri della retta interpolante \n");
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
Peso = sum(1 ./ (Errx.**2));
Media = sum(x ./ Errx.**2) / Peso;
Err = sqrt(1 / Peso);
endfunction;
function [ErrR] = ErrRInd(a,b,Sa,Sb,r);
ErrR = sqrt( (Sa/a)**2 + (Sb/b)**2 - 2*r*Sa*Sb/(a*b));
endfunction;
disp("Interpolandi: \n");
Fr.a = [1:5]; A.a = sin(RadBlu)*Passo;
Fr.b = [1:5]; A.b = sin(RadAzzurra)*Passo;
Fr.c = [1:5]; A.c = sin(RadVerde)*Passo;
Fr.d = [1:5]; A.d = sin(RadRossa)*Passo;
Fr.e = (Lambda).**(-2); A.e = n';
disp("Valori da interpolare \n");
FrI.a = Fr.a; AI.a = A.a;
FrI.b = Fr.b; AI.b = A.b; 
FrI.c = Fr.c; AI.c = A.c;
FrI.d = Fr.d; AI.d = A.d; 
FrI.e = Fr.e; AI.e = A.e; 
disp("ValoriDelleRetteInterpolanti \n");
x = ["a","b","c","d","e","f"]; i = 1;
disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(FrI.a, AI.a);  
i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(FrI.b, AI.b);  
i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(FrI.c, AI.c);  
i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(FrI.d, AI.d);  
i++; disp(i);
[m(i),q(i),Sy(i),Sigmam(i),Sigmaq(i),r(i)] = Interpolazione(FrI.e, AI.e); 
i = 1;
IA.a = FrI.a * m(i) + q(i);                 i++;
IA.b = FrI.b * m(i) + q(i);                 i++;
IA.c = FrI.c * m(i) + q(i);                 i++;
IA.d = FrI.d * m(i) + q(i);                 i++;
IA.e = FrI.e * m(i) + q(i);                 i++;
disp("ValoriIndiretti \n");
i = 1;
l(i)= m(i);Errl(i)= Sigmam(i);
i++;
l(i)= m(i);Errl(i)= Sigmam(i);
i++;
l(i)= m(i);Errl(i)= Sigmam(i);
i++;
l(i)= m(i);Errl(i)= Sigmam(i);
i++;
lB = sin(RadBlu) .* Passo ./ Ordine;      ErrlB = Errl(1)./l(1) * lB;
lA = sin(RadAzzurra) .* Passo ./ Ordine;  ErrlA = Errl(2)./l(2) * lB;
lV = sin(RadVerde) .* Passo ./ Ordine;    ErrlV = Errl(3)./l(3) * lB;
lR = sin(RadRossa) .* Passo ./ Ordine;    ErrlR = Errl(4)./l(4) * lB;
[lBMedia,ErrlBMedia] = MediaPes(lB,ErrlB);
[lAMedia,ErrlAMedia] = MediaPes(lA,ErrlA);
[lVMedia,ErrlVMedia] = MediaPes(lV,ErrlV);
[lRMedia,ErrlRMedia] = MediaPes(lR,ErrlR);
disp("Relazione \n");
Relazione = fopen("Relazione12.tex","w");
				# Chiacchere
fprintf (Relazione," \\chapter{Dispersione} Il seguente esperimento tratter\\`a lo studio di fenomeni di diffrazione e dispersione attraverso un reticolo ed un cristallo. Nel primo caso  si mostrer\\`a la dipendenza tra deviazione angolare e lunghezza  d'onda e nel secondo dalla dipendenza dell'indice di rifrazione  dalla lunghezza d'onda. Anche il secondo caso richieder\\`a quindi  la misura di una deviazione angolare. \\\\ In questo caso abbiamo  utilizzato una lanterna, sorgente di una luce composita di tre  lunghezze d'onda relative ad una zona iniziale (rosso $\\lambda = 656.3 nm$)  al centrale (giallo $\\lambda = 589.3 nm$) e finale (blu $\\lambda =  486.1$) dello spettro. La luce della lanterna veniva dimensionata  a piacere di modo da essere visualizzata al meglio da un  cannocchiale posto sulla ghiera esterna di un supporto mobile.  Questo consisteva in un disco ed una corona esterna che potevano ruotare tra loro secondo un angolo misurato da una scala graduta provvista di nonio. Il  reticolo ed il prisma sono stati posizionati sul disco centrale e  fissati una volta stabilita l'ottimale posizione centrale.  Per  il reticolo abbiamo controllato che i due massimi, distanti tra loro, fossero alla stessa disanza angolare dal centro di  emissione preso come riferimento, per il prisma abbiamo invece abbassato la struttura per mantenere come riferimento il raggio non deflesso. La differenza tra i valori  degli angoli misurati rispetto al centro ci dar\\`a una stima  dell'errore. La misurazione si completa con la rilevazione degli  angoli per tutti i masssimi delle rispettive lunghezze d'onda. \\\\ Presentiamo inizialmente i dati raccolti in gradi sesgesimali utilizzando successivamente i radianti per comodit\\`a di calcolo.\\\\ Il primo campione di dati mostra la differenza angolare di due massimi rispetto al centro, la rilevazione \\`e stata ripetuta cinque volte per calcolare una stima dell'errore quadratico medio");
				# Tabella
fprintf (Relazione,"\\begin{center} \n \\begin{tabular}{r @{$^o$} l | r @{$^o$} l} \n \
95&36' & 100&02' \\\\ 95&4' & 100&22' \\\\ 95&38 & 100&2' \\\\ 95&38' & 100&2' \\\\ 95&4' & 100&22' \n \\end{tabular} \n \\end{center} \n");
fprintf (Relazione,"Che ,rispetto al dato centrale di $97^o60$ fornisce uno scarto di 0,407 mrad \\\\ \n I seguenti dati raggruppano le rilevazioni di cinque massimi per lato dati dalla diffrazione del fascio incidente. \\\\ Da tabella:");
				# Tabella
fprintf (Relazione,"\\begin{center} Blu \\\\ \n \\begin{tabular}{c | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | c } \n \
Ordine & \\multicolumn{2}{c}{$\\phi_{+}$} & \\multicolumn{2}{c}{$\\phi_+ -\\phi_0$} & \\multicolumn{2}{c}{$\\phi_{-}$} & \\multicolumn{2}{c}{$\\phi_0 -\\phi_-$} & \\multicolumn{2}{c}{Media} & rad \\\\ \n \
1 & 100&08 & 2&08 & 95&54 & 2&06 & 2&07 & 0,037  \\\\ \n \
2 & 102&18 & 4&18 & 93&42 & 4&18 & 4&18 & 0,075  \\\\ \n \
3 & 104&26 & 6&26 & 91&32 & 6&28 & 6&27 & 0,113  \\\\ \n \
4 & 106&38 & 8&38 & 89&2  & 8&40 & 8&37 & 0,150  \\\\ \n \
5 & 108&46 & 10&46 & 87&1 & 10&50 & 10&48 & 0,188 \\\\ \n \\end{tabular} \n \\end{center} \n")
fprintf (Relazione,"\\begin{center} Azzurro \\\\ \n \\begin{tabular}{c | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | c } \n \
Ordine & \\multicolumn{2}{c}{$\\phi_{+}$} & \\multicolumn{2}{c}{$\\phi_+ -\\phi_0$} & \\multicolumn{2}{c}{$\\phi_{-}$} & \\multicolumn{2}{c}{$\\phi_0 -\\phi_-$} & \\multicolumn{2}{c}{Media} & rad \\\\ \n \
1 & 100&08 & 2&08 & 95&46 & 2&14 & 2&11 & 0,038 \\\\ \n \
2 & 102&26 & 4&26 & 93&34 & 4&26 & 4&26 & 0,077 \\\\ \n \
3 & 104&4 & 6&40 & 91&2 & 6&40 & 6&4 & 0,116 \\\\ \n \
4 & 106&5 & 8&50 & 89&06 & 8&54 & 8&52 & 0,155 \\\\ \n \
5 & 109&06 & 1&06 & 86&54 & 1&06 & 1&06 & 0,194 \\\\ \n \
\\end{tabular} \n \\end{center} \n");
fprintf (Relazione,"\\begin{center} Verde \\\\ \n \\begin{tabular}{c | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | c } \n \
Ordine & \\multicolumn{2}{c}{$\\phi_{+}$} & \\multicolumn{2}{c}{$\\phi_+ -\\phi_0$} & \\multicolumn{2}{c}{$\\phi_{-}$} & \\multicolumn{2}{c}{$\\phi_0 -\\phi_-$} &\\multicolumn{2}{c}{Media} & rad \\\\ \n \
1 & 100&2 & 2&20 & 95&38 & 2&22 & 2&21 & 0,041 \\\\ \n \
2 & 102&4 & 4&40 & 93&18 & 4&42 & 4&41 & 0,082 \\\\ \n \
3 & 105&0 & 7&0	 & 90&58 & 7&02 & 7&01 & 0,122 \\\\ \n \
4 & 107&22& 9&22 & 88&32 & 9&28	& 9&25 & 0,164 \\\\ \n \
5 & 109&48 & 1&48 & 86&14 & 1&46 & 1&47 & 0,206 \n \\end{tabular} \n \\end{center} \n");
fprintf (Relazione,"\\begin{center} Rosso \\\\ \n \\begin{tabular}{c | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | r @{$^o$} l | c } \n \
Ordine & \\multicolumn{2}{c}{$\\phi_{+}$} & \\multicolumn{2}{c}{$\\phi_+ -\\phi_0$} & \\multicolumn{2}{c}{$\\phi_{-}$} & \\multicolumn{2}{c}{$\\phi_0 -\\phi_-$} & \\multicolumn{2}{c}{Media} & rad \\\\ \n \
1 & 100&56 & 2&56 & 95&00  & 2&60 & 2&58 &  0,052 \\\\ \n \
2 & 103&54 & 5&54 & 92&02  & 5&58 & 5&56 & 0,104 \\\\ \n \
3 & 106&52 & 8&52 & 89&02 & 8&58 & 8&56 & 0,156 \\\\ \n \
4 & 109&56 & 1&56 & 86&04 & 1&56 & 1&56 & 0,208 \\\\ \n \
5 & 113&18 & 1&18 & 82&44 & 1&16 & 1&17 & 0,267 \n \\end{tabular} \n \\end{center} \n");
				# Chiacchere
fprintf (Relazione,"Possiamo ora stabilire la lunghezza d'onda calcolando sia tramite l'interpolazione lineare delle serie suddivise per colori che per la media pesata di tutti i valori indiretti. \\\\ \n Otteniamo per l'interpolazione i seguenti valori della retta interpolante. \n \\begin{center}\\begin{tabular}{c c c c c c c} \n Colore & $m$ & $\\sigma_m$ & $q$ & $\\sigma_q$ & $\\breve\\sigma$ & $r$ \\\\ \n");
				# Dati

for i = 1:4
fprintf(Relazione ,"%s &%3.2f &%3.3f &%3.2f &%3.3f &%3.4f &%3.3f \\\\ \n",Colore(i,1:7), m(i),Sigmam(i),q(i),Sigmaq(i),Sy(i),r(i));
endfor
fprintf(Relazione,"\\end{tabular}\\end{center}");
				# Figura
fprintf (Relazione,"\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{Lambda12}\n \
\\caption{Lunghezza d'Onda}\\label{Black} \n \
\\end{figure} \n \\end{center}\n");
fprintf(Relazione,"Mentre i valori ottenuti per i diversi colori sono: \\begin{center}\\begin{tabular}{c c c c}\n $\\lambda_{blu}$&$\\lambda_{azzurro}$&$\\lambda_{verde}$&$\\lambda_{rosso}$ \\\\ \n");
i = 1;
for i = 1:5
fprintf(Relazione,"%3.0f $\\pm$ %3.2f & %3.0f $\\pm$ %3.2f & %3.0f $\\pm$ %3.2f & %3.0f $\\pm$ %3.2f \\\\ \n",lB(i),ErrlB(i),lA(i),ErrlA(i),lV(i),ErrlV(i),lR(i),ErrlR(i));
endfor 
fprintf(Relazione,"\\end{tabular}\\end{center} \n");
fprintf(Relazione,"Di questi dati presentiamo una media pesata e verifichiamo la compatibilit\\`a con i valori precedentemente ricavati. \\\\ La loro media:\n \\begin{displaymath} \\lambda_{blu} = %3.2f \\pm %3.3f nm \\qquad \\lambda_{azzurro} = %3.2f \\pm %3.3f nm \\end{displaymath}\\begin{displaymath} \\lambda_{blu} = %3.2f \\pm %3.3f nm \\qquad \\lambda_{azzurro} = %3.2f \\pm %3.3f nm \\end{displaymath}",lBMedia,ErrlBMedia,lAMedia,ErrlAMedia,lVMedia,ErrlVMedia,lRMedia,ErrlRMedia);
fprintf(Relazione,"e la compatibilit\\`a:");
fprintf(Relazione,"\\begin{center}Blu %3.3f \\end{center}",sqrt((lBMedia - l(1))**2)/sqrt(ErrlBMedia**2 + Errl(1)**2));
fprintf(Relazione,"\\begin{center}Azzurro %3.3f \\end{center}",sqrt((lAMedia - l(2))**2)/sqrt(ErrlAMedia**2 + Errl(2)**2));
fprintf(Relazione,"\\begin{center}Verde %3.3f \\end{center}",sqrt((lVMedia - l(3))**2)/sqrt(ErrlVMedia**2 + Errl(3)**2));
fprintf(Relazione,"\\begin{center}Rosso %3.3f \\end{center}",sqrt((lRMedia - l(4))**2)/sqrt(ErrlRMedia**2 + Errl(4)**2));
fprintf(Relazione,"\\begin{center}\\begin{tabular}{r @{$^o$} l r \
						   @{$^o$} l c} \n \\\multicolumn{2}{c}{$\\theta_{min}$}&\\multicolumn{2}{c}{$\\theta_{mas}$}\\\\ \n") 
for i=1:4;
fprintf(Relazione,"%3.0f&%2.0f & %3.0f&%2.0f & %4.3f  \\\\ \n",ThMinG1(i),ThMinM1(i),Th0G1(i),Th0M1(i)*100,Delta(i)); 
endfor
fprintf(Relazione,"\\end{tabular}\\end{center}");
fprintf(Relazione,"Ricaviamo cos\\`i i valori di n \
    \\begin{center}\\begin{tabular}{c c } \n");
for i = 1:4;
fprintf(Relazione,"%4.4f & %4.5f \\\\ \n",n(i),Errn(i));
endfor
fprintf(Relazione,"\\end{tabular}\\end{center}");
fprintf(Relazione,"Verifichiamo ora la relazione di Cauchy\\begin{displaymath}n(\\lambda) = A + \\frac{B}{\\lambda^2}\\end{displaymath} che fornisce i seguenti valori dell'interpolazione lineare \n ");
h = 5;
fprintf(Relazione,"\\begin{center} \n \
\\rule{0pt}{3ex} $y_{\nu} = m \\cdot x + q$ \\\\ \n \
m = %4.2f $\\pm$ %4.3f \\\\ \n \
q = %4.2f $\\pm$ %4.3f \\\\ \n \
r = %4.3f $\\sigma_y$ = %4.3f \\\\ \n \
\\end{center} \n",m(h),Sigmam(h),q(h),Sigmaq(h),r(h),Sy(h));
fprintf (Relazione,"Quindi:\\begin{center} A = %4.2f $\\pm$ %4.3f \
	\\end{center} \n \\begin{center} B = %4.0f $\\pm$ %4.0f\\end{center}");
				# Figura
fprintf (Relazione,"\\begin{center} \n \
\\begin{figure}[!h] \n \
\\input{Cauchy12}\n \
\\caption{Lunghezza d'Onda} \n \
\\end{figure} \n \\end{center}\n");
				# Commenti
fprintf(Relazione,"\\end{center}\\begin{section}{Commenti} Il reticolo di \
    diffrazione ha mostrato una buona linearit\\`a tra deviazione e \
    lunghezza d'onda permettendo di ricavare valori della lunghezza \
    d'onda consistenti con quelli attesi con piccolo errore. Viceversa \
    la relazione di Cauchy \\`e poco verificata perch\\'e i punti si \
    dispongono male sulla retta. L'errore sembra quindi essere \
    attribuito alla misurazione degli angoli nel prisma per cui il \
    campione di dati non rappresenta la relazione. \\`E stato preso \
    anche un altro campione il cui andamento \\`e ancora peggiore. \
    Dalla mancata verifica della legge di Cauchy esistono dubbi \
    sull'attendibilit\\`a dei valori di n. In sostanza le singole \
    misure di deviazione senza ulteriore controllo da parte di altre \
    serie hanno mostrato una inefficienza sperimentale anche per \
    malaccortezza degli sperimentatori\\end{section}\n");
fclose(Relazione);
				# Grafici
disp("Salva i grafici \n");
gset term latex;
gset data style points;
disp("Lambda \n");
h = 1;
GrfA.a = [Fr.a', A.a',(ErrRY(1:5) .*A.a)']; 
GrfA.b = [Fr.b', A.b',(ErrRY(1:5) .*A.b)'];
GrfA.c = [Fr.c', A.c',(ErrRY(6:10) .*A.c)']; 
GrfA.d = [Fr.d', A.d',(ErrRY(6:10) .*A.d)'];
GrfAI.a = [FrI.a', IA.a']; 
GrfAI.b = [FrI.b', IA.b'];
GrfAI.c = [FrI.c', IA.c']; 
GrfAI.d = [FrI.d', IA.d'];
gset output 'Lambda12.tex'; 
gset xlabel '$n \\lambda / a$'; gset ylabel '$\\sin\\theta$';
gplot [0:6] GrfA.a with yerrorbars title '', GrfAI.a with lines title 'Blu', GrfA.b with yerrorbars title '', GrfAI.b with lines title 'Azzurro', GrfA.c with yerrorbars title '', GrfAI.c with lines title 'Verde', GrfA.d with yerrorbars title '', GrfAI.d with lines title 'Rosso';
gset term x11;
replot;
kbhit();
disp("Bu li stes! \n");
gset term latex;
gset output 'Cauchy12.tex'
GrfA.e = [Fr.e', A.e']; GrfAI.e = [FrI.e', IA.e']; 
gplot GrfA.e with point title'',GrfAI.e with lines title'';
gset term x11;
replot
				# Fine

