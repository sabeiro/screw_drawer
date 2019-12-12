#ffmpeg -f image2 -i %*.png out.avi
ffmpeg  -i render%2d.png -pix_fmt yuv420p -r 25 output.mp4

