#sudo modprobe snd-aloop
arecord -f cd -t raw | oggenc - -r -o file.ogg
hw:CARD=Loopback,DEV=1
arecord -f S16_LE -r 44100 --device="hw:1,0" plik.wav   
arecord -f S16_LE -r 44100 --device="plughw:CARD=Loopback,DEV=0" plik.wav
arecord -d 10 -f cd -t wav -D copy foobar.wav
arecord -f S32_LE -r 44100 -D ploop plik.wav
arecord -t wav --max-file-time 30 mon.wav
arecord -f cd -t wav --max-file-time 3600 --use-strftime  %Y/%m/%d/lis‐ten-%H-%M-%v.wav



