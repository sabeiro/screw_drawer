#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('~/lav/media/')
source('src/R/graphEnv.R')

pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x + 1),origin="1970-01-01"))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x - 1),origin="1970-01-01" ))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x + 2),origin="1970-01-01" ))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x - 2),origin="1970-01-01" ))

imprSeq <- read.csv("raw/impressionDelivered.csv",header=TRUE,sep=",")
imprSeq$imps <- imprSeq$imps/1000000
head(imprSeq)
imprSeq$date <- as.Date(imprSeq$date)##,format="%d/%m/%Y",origin="1970-01-01")
imprSeq$year <- substring(imprSeq$date,first=1,last=4)
imprSeq$month <- substring(imprSeq$date,first=6,last=7)
imprSeq$week <- format(imprSeq$date,"%W")
imprSeq$day <- substring(imprSeq$date,first=9,last=10)
imprSeq$settimana <- 0
set <- grep("Sunday",imprSeq$Giorni.della.Settimana)
imprSeq[set,"settimana"] <- ddply(imprSeq,.(year,week),summarise,imps=sum(imps,na.rm=TRUE))$imps[1:length(set)]
imprSeq$Giorni.della.Settimana <- gsub(" ","",imprSeq$Giorni.della.Settimana)
head(imprSeq)
tail(imprSeq)


gLabel = c("date","impression daily (Mio)",paste("evoluzione bacino video"),"section")
p <- ggplot(imprSeq,aes(x=year,y=imps,color=year)) +
    geom_boxplot(size=1.5) +
    geom_jitter(alpha=0.5) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("figPredict/boxTime_","year",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
melted <- imprSeq[,c("month","imps")]
melted <- rbind(melted,data.frame(month="festeInv",imps=imprSeq[na.omit(match(imprSeq$date,festeInv)),]$imps))
melted <- rbind(melted,data.frame(month="festeEst",imps=imprSeq[na.omit(match(imprSeq$date,festeEst)),]$imps))
melted <- rbind(melted,data.frame(month="pasqua",imps=imprSeq[na.omit(match(imprSeq$date,pasqua)),]$imps))
print("storico mensile")
ddply(imprSeq,.(month),summarise,av=mean(imps)*7,sd=sd(imps)*7)

gLabel = c("date","impression (Mio)",paste("evoluzione bacino video"),"section")
p <- ggplot(melted,aes(x=month,y=imps,fill=month)) +
    geom_boxplot() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("figPredict/boxTime_","month",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

gLabel = c("date","impression (Mio)",paste("evoluzione bacino video"),"section")
p <- ggplot(imprSeq,aes(x=day,y=imps,fill=day)) +
    geom_boxplot() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p



gLabel = c("date","impression (Mio)",paste("evoluzione bacino video"),"section")
melted <- ddply(imprSeq,.(year,week),summarise,imps=sum(imps))
p <- ggplot(melted,aes(x=week,y=imps)) +
    geom_boxplot(aes(fill=week)) +
    geom_line(aes(color=year,group=year),size=1.5,alpha=.5) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p


fName <- paste("figPredict/boxTime_","day",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
imprSeq$Giorni.della.Settimana <- factor(imprSeq$Giorni.della.Settimana,levels=unique(imprSeq$Giorni.della.Settimana))
p <- ggplot(imprSeq,aes(x=Giorni.della.Settimana,y=imps,fill=Giorni.della.Settimana)) +
    geom_boxplot() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("figPredict/boxTime_","weekday",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

##week

weekSeq <- data.frame(day=imprSeq[!is.na(imprSeq$settimana),"date"])
weekSeq$impression <- imprSeq[!is.na(imprSeq$settimana),"settimana"]
weekSeq <- weekSeq[-c(1,2,120),]


ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
p <- ggplot(data=weekSeq,aes(x=day,y=impression)) +
    geom_line() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("figPredict/timeSeq","",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

monthAv = ddply(weekSeq,~substring(day,first=1,last=7),summarise,mean=mean(impression))
colnames(monthAv) <- c("month","impression")


