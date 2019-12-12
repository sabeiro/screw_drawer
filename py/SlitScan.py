from PIL import Image, ImageFile, ImageDraw
import glob
#from array import array
Img = Image.open("Frames/image-00001.jpg")
print Img.size, Img.mode, Img.format
Nw = Img.size[0]
Nh = Img.size[1]
NFileIn = 0
for infile in glob.glob("Frames/image-*"):
    NFileIn += 1
NFileOut = NFileIn-Img.size[0]
ImgList = []
for f in range(NFileOut):
    ImgList.append(Img)


for f in range(NFileIn):
    FName = "Frames/image-" + "%05d" % (f+1) + ".jpg"
    ImgIn = Image.open(FName)
    pixelsIn = ImgIn.load()
    Nw = min(f,Img.size[0])
    print "%d/%d " % (f,NFileIn) + FName
    if f < NFileOut:
        ImgList[f] = ImgIn
    for w in range(Nw):
        f1 = f - w
        if (f1 >= NFileOut):
            continue
        #print f,f1,w
        pixels = ImgList[f1].load()
        for h in range(Nh):
            #pix = ImgIn.getpixel((w,h))
            pix = pixelsIn[w,h]
            #pix = (w,h,5*f1)
            #ImgList[f1].putpixel((w,h),pix)
            pixels[w,h] = pix

for f1 in range(NFileOut):
    FName = "Out/image-" + "%05d" % (f1 + 1) + ".jpg"
    ImgList[f1].save(FName)
