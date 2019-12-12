#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x + 1) ))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x - 1) ))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x + 2) ))
pasqua <- c(pasqua,as.Date(sapply(pasqua,function(x) x - 2) ))

imprSeq <- read.table("raw/impressionDelivered.csv",header=TRUE,sep=",")
names(imprSeq)
imprSeq$Data <- as.Date(imprSeq$Data,format="%m/%d/%Y")
imprSeq$year <- substring(imprSeq$Data,first=1,last=4)
imprSeq$month <- substring(imprSeq$Data,first=6,last=7)
imprSeq$week <- format(imprSeq$Data,"%W")
imprSeq$day <- substring(imprSeq$Data,first=9,last=10)

p <- ggplot(imprSeq,aes(x=year,y=Impression,fill=year)) +  geom_boxplot()
fName <- paste("figPredict/boxTime_","year",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
melted <- imprSeq[,c("month","Impression")]
melted <- rbind(melted,data.frame(month="festeInv",Impression=imprSeq[na.omit(match(imprSeq$Data,festeInv)),]$Impression))
melted <- rbind(melted,data.frame(month="festeEst",Impression=imprSeq[na.omit(match(imprSeq$Data,festeEst)),]$Impression))
melted <- rbind(melted,data.frame(month="pasqua",Impression=imprSeq[na.omit(match(imprSeq$Data,pasqua)),]$Impression))
p <- ggplot(melted,aes(x=month,y=Impression,fill=month)) +  geom_boxplot()
mMean <- ddply(melted,.(month),summarise,imps = mean(Impression,na.rm=TRUE))
2*(mMean[4,"imps"]-mMean[15,"imps"])/(mMean[15,"imps"]+mMean[4,"imps"])
fName <- paste("figPredict/boxTime_","month",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
melted <- imprSeq[,c("week","Impression")]
melted <- rbind(melted,data.frame(week="festeInv",Impression=imprSeq[na.omit(match(imprSeq$Data,festeInv)),]$Impression))
melted <- rbind(melted,data.frame(week="festeEst",Impression=imprSeq[na.omit(match(imprSeq$Data,festeEst)),]$Impression))
melted <- rbind(melted,data.frame(week="pasqua",Impression=imprSeq[na.omit(match(imprSeq$Data,pasqua)),]$Impression))
p <- ggplot(melted,aes(x=week,y=Impression,fill=week)) +  geom_boxplot()
fName <- paste("figPredict/boxTime_","week",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
p <- ggplot(imprSeq,aes(x=day,y=Impression,fill=day)) +  geom_boxplot()
fName <- paste("figPredict/boxTime_","day",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
p <- ggplot(imprSeq,aes(x=Giorni.della.Settimana,y=Impression,fill=Giorni.della.Settimana)) +  geom_boxplot()
fName <- paste("figPredict/boxTime_","weekday",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

##week

weekSeq <- data.frame(day=imprSeq[!is.na(imprSeq$settimana),"Data"])
weekSeq$impression <- imprSeq[!is.na(imprSeq$settimana),"settimana"]
weekSeq <- weekSeq[-c(1,2,120),]


p <- ggplot(data=weekSeq,aes(x=day,y=impression)) + geom_line()
fName <- paste("figPredict/timeSeq","",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

monthAv = ddply(weekSeq,~substring(day,first=1,last=7),summarise,mean=mean(impression))
colnames(monthAv) <- c("month","impression")

impr.ts = ts(monthAv$impression, frequency=12, start=c(2013,10), end=c(2015,12))
impr2 = window(impr.ts, start=c(2013,10), end=c(2015, 12))
fit = stl(impr2, s.window="periodic")
png('figPredict/trendSerie.png',pngWidth,pngHeight)
plot(fit)
dev.off()
impr3 <- decompose(impr.ts)
png('figPredict/decomposeSerie.png',pngWidth,pngHeight)
plot(impr3)
dev.off()

fit <- arima(impr2,order=c(1,0,0),list(oder=c(2,1,0),period=12))

fit <- arima(impr.ts, order=c(1,0,0))
fore <- predict(fit, n.ahead=3)
U <- fore$pred + 2*fore$se
L <- fore$pred - 2*fore$se
png('figPredict/trendSerie.png',pngWidth,pngHeight)
plot(impr2)
ts.plot(impr.ts, fore$pred, U, L, col=c(1,2,4,4), lty = c(1,1,2,2))
legend("topleft", c("Actual", "Forecast", "Error Bounds (95% Confidence)"), col=c(1,2,4), lty=c(1,1,2))
dev.off()

