ffmpeg -r 60 -f image2 -s 960x540 -i %04d.png -vcodec libx264 -crf 25  test.mp4
#ffmpeg -framerate 1/25 -i %04d.png -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4
