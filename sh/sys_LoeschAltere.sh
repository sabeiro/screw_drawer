if [ !(-e $i) ] then;
	echo "Geben bitte eine Datei zu vergleichen"
	exit 
fi
for i in *.dat;
	if [ $i -ot $1 ] then;
		rm $i
	fi
done;
echo "Die Dateien alter als $1 sind geloescht worden"

