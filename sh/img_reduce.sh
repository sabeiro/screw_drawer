for i in *.jpg *.JPG ;
do
	convert -adaptive-resize 700 $i Small$i
	mv $i Normal$i
done
