ffmpeg -i ../titoliCoda.MOV -an -qscale 1 %06d.jpg
#ffmpeg -i ../titoliCoda.MOV -vn -ac 2 audio.wav
#sox -V audio.wav backwards.wav reverse

#cat $(ls -t *jpg) | ffmpeg -f image2pipe -vcodec mjpeg -r 25 -i - -i backwards.wav -vcodec libx264 -crf 20 -threads 0 -acodec flac output.MOV

#cat $(ls -t *jpg) | ffmpeg  -f image2pipe -i - -pix_fmt yuv420p -r 24 output.mp4

nFrame=$(ls *jpg | wc | awk '{print $1}')
init=0
for i in *jpg
do
	init=$((init + 1))	
	initS=$(printf "%06d\n" $((nFrame - init)) )
	mv $i render_$initS.jpg
done
ffmpeg  -i render_%6d.jpg -pix_fmt yuv420p -r 24 output.mp4




cat $(ls -t *jpg) | ffmpeg -f image2pipe -vcodec mjpeg -r 25 -i - -i backwards.wav -vcodec libx264 -vpre slow -crf 20 -threads 0 -acodec flac output.MOV
mencoder input.dv -of rawvideo -ofps 50 -ovc raw -vf yadif=3,format=i420 -nosound -really-quiet -o - | ffmpeg -vsync 0 -f rawvideo -s 720x576 -r 50 -pix_fmt yuv420p -i - -vcodec libx264 -vpre slow -crf 20 -threads 0 video.mkv
