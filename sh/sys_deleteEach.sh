OGNI=$1;
if [ -z $1 ]
then
	echo "Ogni quanti?"
	exit
fi
NFILE=$(ls output0* | wc | gawk '{print $1}');
for ((i=0;i<$NFILE;i+=$OGNI)) do
	FILE=$(ls output0* | head -n $(($i+$OGNI)) | tail -n $OGNI)
#	echo $FILE;
	ElPoly --Shift .0 .0 .5 --core $FILE;
#	ElPoly --Stalk $FILE;
	STRING=$(printf "%07d" $i)
#	mv Stalk.xvl Stalk${STRING}.xvl
	mv Core.xvl CoreLower${STRING}.xvl
done
