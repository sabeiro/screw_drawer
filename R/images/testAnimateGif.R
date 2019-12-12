setwd('~/lav/media')
source('src/R/graphEnv.R')

fs <- read.csv('src/py/tmp.csv')
fs$X = as.Date(fs$X)
fs1 <- read.csv('src/py/tmp1.csv')
fs1$X = as.Date(fs1$X)
fs2 <- read.csv('src/py/tmp2.csv')
fs2$X = as.Date(fs2$X)
fs2$y = fs2$y*mean(fs$y)
fs3 <- read.csv('src/py/tmp3.csv')
fs3$y = fs3$y*mean(fs$y)
fs3$X = as.Date(fs3$X)

fs4 = merge(fs1,fs2,all.x=T)

labL = c("daily series","rolling average","trend","de-trend","history month","history week","history spline","history spline","history correction","periodic least square","prediction period+trend","prediction + trend","prediction")
gLabel = c("day","iventory (M)",paste(""),"type")
i = 1
p = ggplot(fs,aes(x=X)) +
    geom_line(aes(y=y,color="series",group=1),stat="identity",size=1.5,color=gCol1[1]) +
    theme(legend.position=c(.1,.75)) +
    scale_x_date(date_breaks="1 week",labels=date_format("%y-%m-%d"),limits=c(as.Date("2017-01-01"),as.Date("2017-04-01"))) + ##, date_labels = "%W") +
    scale_y_continuous(limits=c(-2,4.5)) + 
    scale_color_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
for(i in 1:length(labL)){
    p2 = p + annotate("text",x=as.Date('2017-01-30'),y=-2,label=paste(i,"-",labL[i]),size=10)
    if(i==1){p1 = p2}
    if(i==2){
        p1 = p2 + geom_line(aes(y=roll,color="roll",group=1),stat="identity",size=1.5,color=gCol1[7])
    }
    if(i==3){
        p1 = p2 + geom_line(aes(y=roll,color="roll",group=1),stat="identity",size=1.5,color=gCol1[7]) + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i==4){
        p1 = p2 + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2]) + geom_line(data=fs4,aes(y=y-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i==5){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1])
    }
    if(i==6){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1]) + geom_bar(data=fs2,aes(y=y,fill="hist week",group=1),stat="identity",alpha=.3,fill=gCol1[3])
    }
    if(i==7){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1]) + geom_bar(data=fs2,aes(y=y,fill="hist week",group=1),stat="identity",alpha=.3,fill=gCol1[3]) + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3])
    }
    if(i==8){
        p1 = p2 + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3]) + geom_line(data=fs4,aes(y=y-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i == 9){
        p1 = p2 + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3]) + geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i == 10){
        p1 = p2 + geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2]) + geom_line(data=fs1,aes(y=lsq,color="lsq",group=1),stat="identity",size=1.5,color=gCol1[4])
    }
    if(i == 11){
        p1 = p2 + geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2]) + geom_line(data=fs1,aes(y=lsq,color="lsq",group=1),stat="identity",size=1.5,color=gCol1[4]) + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i == 12){
        p1 = p2  + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2]) +  geom_line(data=fs1,aes(y=pred,color="prediction",group=1),stat="identity",size=1.5,color=gCol1[5])
    }
    if(i == 13){
        p1 = p2 + geom_line(data=fs1,aes(y=pred,color="prediction",group=1),stat="identity",size=1.5,color=gCol1[5])
    }
    if(i == 14){
        p1 = p2 + geom_line(data=fs1,aes(y=pred,color="prediction",group=1),stat="identity",size=1.5,color=gCol1[5])
    }
    ggsave(file=paste("fig/tmp/serEv",sprintf("%02d",i),".jpg",sep=""),plot=p1,width=gWidth,height=gHeight)
}

    



