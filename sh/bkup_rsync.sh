#rsync -urltv --delete -e ssh /src.dir othermachine:/src.dir
if(($# < 1)) 
then 
	echo "che cartella?"
	exit
fi
rsync -avz ./$1 sabeiro@dauvi.org:/var/www/$1
