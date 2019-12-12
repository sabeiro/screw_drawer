#rsync -urltv --delete -e ssh /src.dir othermachine:/src.dir
if (($# < 1)); then echo "che cartella?"; exit ; fi
cd
DIRLIST=(Audio dauvi lav Music Pictures share sketchbook VideoProd workspace)
for i in ${DIRLIST[@]}
do
#	echo $i
	rsync -avz --delete $i $1/$i
done
