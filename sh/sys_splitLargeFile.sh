#awk -vc=1 'NR%200000==0{++c}{print $0 > c".txt"}' MP07_SM_Teaser.csv
split -l 200000 $1
#gawk 'BEGIN {n_seq=0;} /^>/ {if(n_seq%1000==0){file=sprintf("myseq%d.fa",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < sequences.fa
#gawk 'NR=1000 {print $0}' $1
#head -1000 $i | awk '{print $0}' > maxSample.csv
#gawk -F "\t" '{FS="\t";x=$7;gsub("^[^;]*","",x);print $1, x, $11}' $1 
gawk -F "\t" '{OFS="\t";print $29, $10, $11}' $1 
#gawk -F "\t" '{OFS="\t";x=$7;y=gsub("(^[^;]*)(.+)(\\?.*)","\\2",x);gsub("\\?.*","",y);print $1, x, $11}' $1
recode -f UTF-7 parta*
