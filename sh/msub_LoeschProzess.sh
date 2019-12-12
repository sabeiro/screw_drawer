DIR=$(pwd | sed 's/\//\n/g' | tail -1)
#DIRLEN=$(echo `expr length $DIR)
DIRLEN=${#DIR}
if [ $DIRLEN -gt 8 ];then
	LOESCH=${DIR:0:8}
else
        LOESCH=$DIR
fi
echo "Ich loesche den Prozess $LOESCH"
qstat -u $USER | grep $LOESCH | sed 's/\./\n/' | sed q | xargs qdel



