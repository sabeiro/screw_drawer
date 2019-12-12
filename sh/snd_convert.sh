for i in *.ogg
do
	sox $i tmp.wav
	lame -b 128 -q 2 $i ${i/ogg/mp3}
	tm tmp.wav
done
