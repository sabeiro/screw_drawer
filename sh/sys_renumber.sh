init=0
for i in *png
do
	mv $i render$init.png
	init=$(($init + 1))
done

