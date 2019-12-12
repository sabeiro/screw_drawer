if [ -z $1 ]; then echo "input var missing"; exit; fi
mkdir frames
ffmpeg -i input -vf scale=320:-1:flags=lanczos,fps=10 frames/ffout%03d.png	
convert -loop 0 frames/ffout*.png output.gif

#ffmpeg -y -ss 30 -t 3 -i $1 -vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png
#ffmpeg -ss 30 -t 3 -i $1 -i palette.png -filter_complex "fps=10,scale=320:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif

#ffmpeg -i animated.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" video.mp4

#ffmpeg -i your_gif.gif -c:v libvpx -crf 12 -b:v 500K output.mp4

