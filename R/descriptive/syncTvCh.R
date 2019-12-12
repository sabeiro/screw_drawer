#!/usr/bin/env Rscript
setwd('C:/Users/giovanni.marelli.PUBMI2/lav/media/')
source('script/graphEnv.R')
require('forecast')
library(splines)

deriv <- function(x, y) diff(y) / diff(x)

fList <- list.files(path="raw/")
fMeasure <- fList[grep("chEv",fList)]

decayL <- NULL
corL <- NULL
lagL <- NULL
perL <- NULL
nameL <- NULL
isPlot <- TRUE
k <- 2
for(k in 1:length(fMeasure)){
    fName <- paste('raw/',fMeasure[k],sep="")
    print(fName)
    nameL <- c(nameL,fName)
    fs1 <- read.csv(fName,stringsAsFactors=FALSE,sep=";")
    set <- grepl("/",fs1[,1])
    date1 <- as.Date(gsub('[[:alpha:]]',"",fs1[set,1]),format="%d/%m/%Y")
    date2 <- as.Date(fs1[!set,1])
    fs1[,1] <- c(date1,date2)
    fs1[,6] <- as.numeric(gsub("[[:punct:]]","",fs1[,6]))
    fs1[,7] <- as.numeric(gsub("[[:punct:]]","",fs1[,7]))
    fs1 <- fs1[,c(1,6,7)]
    colnames(fs1) <- c("date","tv","tv1")
    Knots <- seq(1,nrow(fs1))[!is.na(fs1$tv)]
    fs1[is.na(fs1$tv),"tv"] <- 0
    fs1$tv <- fs1$tv/sum(fs1$tv,na.rm=TRUE)
    fs1$tv1 <- fs1$tv1/sum(fs1$tv1,na.rm=TRUE)
    rg <- diff(range(fs1$tv))
    head(fs1)
    fs <- fs1

    melted <- melt(fs,id="date")
    gLabel = c("data","impression (normalizzate)",paste("evoluzione bacino video"),"-")
    p <- ggplot(data=melted,aes(x=date,y=value,fill=variable)) +
        geom_bar(stat="identity",position="dodge",size=1) +
        theme(
            axis.text.x = element_text(angle = 30, hjust = 1),
            legend.position="bottom", legend.box = "horizontal",
            panel.background = element_blank()
        ) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
    p
    ggsave(paste('figPredict/forecast',gsub("csv","png",fMeasure[k]),sep=""),p,width=gWidth,height=gHeight)

    impr = ts(fs[,"tv"], frequency=7, start=1)
    dog <- stl(impr,"per")
    plot(dog)

    cor(fs$tv,fs$tv1)

    foreI <- data.frame(date=seq(fs[nrow(fs),"date"]-13,fs[nrow(fs),"date"], "day"))
    fit <- auto.arima(ts(fs[,"tv"], frequency=7, start=1))
    foreI <-  cbind(foreI,as.data.frame(forecast(fit, 14)))
    ##fit <- ets(impr)
    fit <- auto.arima(ts(fs[,"tv1"], frequency=7, start=1))
    hw <- HoltWinters(ts(fs[,"tv1"], frequency=7, start=1))
    foreL <- predict(hw, n.ahead = 14, prediction.interval = T, level = 0.95)
    foreI <- cbind(foreI,as.data.frame(foreL))
    if(isPlot){##----------------------forecast--------------------
        plot(hw,foreL)
    }
    plot(foreI)
    str(foreI)
    colnames(foreI) <- c("date","fit","low1","low2","high1","high2")
    gLabel = c("data","impression (normalizzate)",paste("evoluzione bacino video"),"-")
    p <- ggplot(data=fs,aes(x=date)) +
        ##geom_ribbon(data=foreI,aes(ymin=lwr_web,ymax=upr_web),size=.2,alpha=.25,fill=gCol1[10]) +
        geom_bar(aes(y=tv,fill="tv"),stat="identity",alpha=.5) +
        geom_bar(data=foreI,aes(x=date,y=fit,fill="prediction tv"),stat="identity",alpha=.5) +
        scale_x_discrete(name="data") +
        xlim(fs[nrow(fs),"date"]-20,fs[nrow(fs),"date"]) +
        theme(
            axis.text.x = element_text(angle = 30, hjust = 1),
            legend.position="bottom", legend.box = "horizontal",
            panel.background = element_blank()
        ) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
    p
    ggsave(paste('figPredict/forecast',gsub("csv","png",fMeasure[k]),sep=""),p,width=gWidth,height=gHeight)


}
