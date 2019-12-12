#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('src/R/graphEnv.R')
library(gtools)
library("forecast")
comprob <- .98

##source("script/inventoryLoad.R")
aggrAll <- read.csv("out/invVideoTimeSeq.csv")

melted <- melt(aggrAll[,!names(aggrAll)%in%c("X")])
melted$Data <- rep(aggrAll$X,length(names(aggrAll))-1)
melted$Data <- as.Date(melted$Data)
melted$Week <- paste(format(melted$Data,"%y"),format(melted$Data,"%m"),sep="-")
melted$variable <- as.character(melted$variable)
melted$group <- NA
melted<- melted[!grepl("total",melted$variable),]
##melted <- melted[!grepl("Test",melted$variable),]
meltedW <- ddply(melted,.(Week,variable),summarise,value=sum(value,na.rm=TRUE))

videoGrp <- read.csv("node/json/taxonomy_video.csv")
for(i in 1:nrow(videoGrp)){
    meltedW[grepl(videoGrp[i,"section"],meltedW$variable),"group"] <- videoGrp[i,"group"]
}

meltedW <- ddply(meltedW,.(Week,group),summarise,value=sum(value,na.rm=TRUE))
gLabel = c("month","impressions (Mio)",paste("impression evolution by group"),"group")
p <- ggplot(meltedW,aes(x=Week,y=value,color=group,group=group)) +
    geom_boxplot(size=2) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4]) +
    geom_line(size=1)
p
fName <- paste("figPredict/timeEvSections_","month",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)


sectList <- colnames(aggrAll)[-1]##unique(aggrAll$Section)
aggrAll$Data <- as.Date(aggrAll$X)
sl <- sectList[11]
for(sl in groups){
    x <-  as.data.frame(aggrAll[,colnames(aggrAll) %in% c("Data",sl)])
    names(x)[names(x)==sl] <- "imps"
    x$week <- paste(as.numeric(format(x$Data, "%y")),format(x$Data, "%m"),calWeek(x$Data),sep="-")
    w <- ddply(x,.(week),summarise,imps=sum(imps,na.rm=TRUE))
    x$month <- paste(as.numeric(format(x$Data, "%y")),format(x$Data, "%m"),sep="-")
    m <- ddply(x,.(month),summarise,imps=sum(imps,na.rm=TRUE))
    ## plot(x$imps,t="l")
    ## plot(w$imps,t="l")
    ## plot(m$imps,t="l")
    sectSer.ts <- ts(w$imps, frequency=52, start=c(2012,7), end=c(2016,2))
    ## plot.ts(sectSer.ts)
    sectSer.fore <- HoltWinters(sectSer.ts, beta=FALSE, gamma=FALSE,l.start=m$imps[1])
    sectSer.fore2 <- forecast.HoltWinters(sectSer.fore,h=19)
    png(paste('figPredict/sectFore_',sl,'.png',sep=""),pngWidth,pngHeight)
    plot.forecast(sectSer.fore2)
    dev.off()
    sectSer.fore$fitted
    sectSer.fore$SSE
    png(paste('figPredict/sectResidual_',sl,'.png',sep=""),pngWidth,pngHeight)
    sectSer.acf <- acf(sectSer.fore2$residuals, lag.max=20)
    dev.off()
    Box.test(sectSer.fore2$residuals, lag=20, type="Ljung-Box")
    ##plot.ts(sectSer.fore2$residuals)
    png(paste('figPredict/sect_',sl,'.png',sep=""),pngWidth,pngHeight)
    ##plot(sectSer.fore)
    plot.forecast(sectSer.fore2)
    dev.off()
    sectSer.arima <- arima(w$imps,order=c(0,1,1))
    sectSer.foreA <- forecast.Arima(sectSer.arima,h=5)
    png(paste('figPredict/sect_',sl,'.png',sep=""),pngWidth,pngHeight)
    plot(sectSer.foreA)
    dev.off()
    acf(sectSer.foreA$residuals, lag.max=20)
    Box.test(sectSer.foreA$residuals, lag=20, type="Ljung-Box")
    ##plotForecastErrors(sectSer.foreA$residuals)
}


fs <- read.csv('raw/impressionVideoHist.csv')
fs$Data <- as.Date(fs$Data)
head(fs)
fs$week <- paste(format(fs$Data,"%y"),calWeek(fs$Data),sep="-")
fs$month <- paste(format(fs$Data,"%y"),format(fs$Data,"%m"))

disWeek <- ddply(fs,.(week),summarise,imps=sum(Totale.inventory,na.rm=TRUE),impsSd = sd(Totale.inventory,na.rm=TRUE))
p <- ggplot(disWeek,aes(x=week,y=imps,group=1)) +
    geom_line() +
    geom_errorbar(aes(ymin=imps-impsSd,ymax=imps+impsSd))
p
rownames(disWeek) <- disWeek$week
disWeek <- as.matrix(disWeek[,-1])


disWeek <- ddply(fs,.(month),summarise,imps=sum(Totale.inventory,na.rm=TRUE),impsSd = sd(Totale.inventory,na.rm=TRUE))
disWeek$imps <- as.numeric(disWeek$imps)
p <- ggplot(disWeek,aes(x=month,y=imps,group=1)) +
    geom_line() +
    geom_errorbar(aes(ymin=imps-impsSd,ymax=imps+impsSd))
p
## rownames(disWeek) <- disWeek$month
## disWeek <- as.matrix(disWeek[,-1])
disWeek$chi <- disWeek$impsSd^2/disWeek$imps
chi2 <- sd(disWeek$imps)^2/mean(disWeek$imps)
nFree <- length(disWeek$imps) - 1

#?arima


hist(disWeek$chi)
cumprob <- 0.96
lim <- quantile(disWeek$chi,cumprob)
disWeek[disWeek$chi > lim,"month"]




