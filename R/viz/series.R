setwd('~/lav/media')
source('src/R/graphEnv.R')
library('rjson')
library('corrplot') #package corrplot

##plotD = {"type":"line","x":"lag","y":"amplitude","tit":"auto correlation","leg_line":"channel","leg_area":"channel","fig_name":"intertino/fig/serChAut.jpg","smooth":True,"point":False,"log":False,"leg_pos":"down","melt":True,"seq_x":True,"order":"val"}

fOpt <- rjson::fromJSON(file="tmp/tmp.json")
fs <- read.csv("tmp/tmp.csv",stringsAsFactor=F)

if(fOpt$type == "bar"){
    fs <- read.csv("tmp/tmp.csv",stringsAsFactor=F,header=F)
}
if(fOpt$type == "cor"){
    fs <- read.csv("tmp/tmp.csv",stringsAsFactor=F,row.names=1)
    jpeg(fOpt$fig_name,width=pngWidth,height=pngHeight)
    corrplot.mixed(as.matrix(fs),lower="pie",upper="number")
    dev.off()
    #quit()
}
if(fOpt$seq_x){fs$X = seq(nrow(fs))}
if(!fOpt$melt){
    melted = fs
    colnames(melted) <- c("X","value")
    melted$variable = melted$X
}else{
    melted <- melt(fs,id="X")
}
if(fOpt$smooth){
    smooth = data.frame(X=seq(nrow(fs)*10)/10)
    for(i in colnames(fs)[-1]){smooth[i] = spline(fs[i],n=nrow(fs)*10)[2]}
    melted <- melt(smooth,id="X")
}
if(fOpt$order=="val"){
    melted = melted[rev(order(melted$val)),]
    melted$X = factor(melted$X,levels=melted$X)
}else{
    melted = melted[order(melted$X,melted$variable),]
}
gLabel = c(fOpt$x,fOpt$y,fOpt$tit,fOpt$leg_line,fOpt$leg_area)
p <- ggplot(melted,aes(x=X,y=value,group=variable)) + 
    theme(panel.background=element_blank()) +
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
if(fOpt$type == "line"){p = p + geom_line(aes(color=variable),position="identity",size=1.2,alpha=0.5)}
if(fOpt$type == "stack_line"){p = p + geom_line(aes(color=variable),position="stack",size=1.2,alpha=0.7)}
if(fOpt$type == "bar"){p = p + geom_bar(aes(fill=variable),stat="identity",position="identity",size=1.2,alpha=0.5)}
if(fOpt$point){p = p + geom_point()}
if(fOpt$log){p = p + scale_x_log10() + scale_y_log10() + annotation_logticks()}
if(fOpt$leg_pos=="down"){p = p + theme(legend.position="bottom", legend.box = "horizontal")}

p
ggsave(file=fOpt$fig_name,plot=p,width=gWidth,height=gHeight)

