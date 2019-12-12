month=Mar
for i in *svg
do
	convert $i figure/$month/${i/svg/png}
done
