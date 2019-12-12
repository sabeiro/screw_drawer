ExecLine(){
	line="$@"
	echo $line
	scp $rocks:~/Stability/$line/outputNano.dat .
	Visualizza outputNano.dat
}
FILE="ListaNano.txt"
if [ ! -f $FILE ]; then
   	echo "$FILE : does not exist"
 	exit 1
elif [ ! -r $FILE ]; then
	echo "$FILE: can not be read"
 	exit 2
fi
BAKIFS=$IFS
IFS=$(echo -en "\n\b")
exec 3<&0
exec 0<"$FILE"
while read -r line
do
	ExecLine $line
done
exec 0<&3
# restore $IFS which was used to determine what the field separators are
IFS=$BAKIFS
exit 0
