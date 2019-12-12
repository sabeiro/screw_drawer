rm Frames/*
avconv -i ../Gargnano3.AVI  Frames/image-%05d.jpg -threads 3
