#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')
require('forecast')
library(splines)

deriv <- function(x, y) diff(y) / diff(x)

fList <- list.files(path="raw/")
fMeasure <- fList[grep("sync",fList)]

decayL <- NULL
corL <- NULL
lagL <- NULL
perL <- NULL
nameL <- NULL
isPlot <- TRUE
k <- 1
for(k in 1:length(fMeasure)){
    fName <- paste('raw/',fMeasure[k],sep="")
    if(any(grep("syncCePostaPerTe2",fName))){next}
    if(any(grep("Segreto2",fName))){next}
    if(any(grep("Igt",fName))){next}
    print(fName)
    nameL <- c(nameL,fName)
    fs1 <- read.csv(fName,stringsAsFactors=FALSE)
    fs1[,1] <- as.Date(gsub('[[:alpha:]]',"",fs1[,1]),format="%d/%m/%y")
    fs1[,3] <- as.numeric(gsub("[[:punct:]]","",fs1[,3]))
    fs1 <- fs1[,1:3]
    colnames(fs1) <- c("date","web","tv")
    fs1$n <- 1:nrow(fs1)
    Knots <- seq(1,nrow(fs1))[!is.na(fs1$tv)]
    fs1[is.na(fs1$tv),"tv"] <- 0
    fs1$tv <- fs1$tv/sum(fs1$tv,na.rm=TRUE)
    fs1$web <- fs1$web/sum(fs1$web)
    rg <- diff(range(fs1$tv))
    fs <- fs1

    ##----------------------spikes-----------------------------
    der <- deriv(fs$n,fs$web)
    threshold <- 0.01
    set <- which(der>threshold) + 1
    spikes <- vector()
    spikes <- rep(0,length(set))
    j <- 1
    for(i in 1:nrow(fs)){
        if(any(i==set)){j <- j + 1}
        spikes[j] <- spikes[j] + fs[i,"web"]
    }
    fs <- cbind(fs,spikes)
    if(isPlot){
        plot(fs[,"spikes"],type="l")
        lines(deriv(fs$n,fs$web))
        lines(fs[,"web"])
    }
    if(isPlot){
        png(paste('figPredict/initial',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        plot(fs[,"tv"],type="l",col="red",xlab="day",ylab="rel imps")
        lines(fs[,"web"],col="blue")
        legend("top",inset=-.05,cex=1,title="",c("tv","web"),horiz=TRUE,lty=c(1,1),lwd=c(2,2),col=c("red","blue"))
        dev.off()
        ## plot(fs[,"tv"],type="l")
        ## lines(filter(fs[,"tv"],filter=rep(1/7,7),method="recursive"),sides=1,circular=TRUE) ##kind of running average
        ## lines(filter(fs[,"tv"],filter=rep(1/7,7),method="convolution")) ##kind of running average
    }

    impr = ts(fs[,"web"], frequency=7, start=1)
    dog <- stl(impr,"per")
    seasonal <- dog$time.series[,1]
    trend <- dog$time.series[,2]
    if(isPlot){##----------------------decomposition-autocorr--------------------
        png(paste('figPredict/decomp',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        plot(dog)
        dev.off()
        png(paste('figPredict/roots',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        y <- auto.arima(ts(fs[,"web"], frequency=7, start=1))
        plot(y)
        dev.off()
        png(paste('figPredict/autoRaw',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        acf(fs[,"web"])
        dev.off()
        png(paste('figPredict/autoSeas',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        acf(seasonal)
        dev.off()
    }
    y <- as.numeric(acf(seasonal,plot=FALSE)$acf)[1:5]
    fit <- lm(y ~ log(n),data.frame(x=y,n=1:length(y)))
    decV <- exp(fit$coefficients[2]*(1:14))
    decayL <- c(decayL,-1/fit$coefficients[2])
    if(isPlot){##----------------------decomposition-autocorr--------------------
        ##png(paste('figPredict/decay',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        plot(y,type="l",col="red",xlab="day",ylab="autocorr")
        lines(predict(fit,data.frame(x=y,n=1:length(y),interval='predict')),col="blue")
        legend("top",inset=-.05,cex=1,title="",c("autocorrelation","fit"),horiz=TRUE,lty=c(1,1),lwd=c(2,2),col=c("red","blue"))
        ##dev.off()
    }
    decays <- fs[,"tv"]
    for(i in Knots){
        lim <- 14
        if(i+lim > length(decays)){lim = length(decays)}
        decays[(i+1):(i+lim)] = decays[(i+1):(i+lim)] + decays[i]*decV[1:lim]
    }
    decays <- decays[1:nrow(fs)]
    fs <- cbind(fs,decays)
    if(isPlot){##----------------------decomposition-autocorr--------------------
        ggplot(data.frame(day=1:nrow(fs),tv=fs[,"tv"],z=decays,t=fs[,"web"]),aes(x=day))+
            geom_bar(aes(y=tv),fill=gCol1[2],stat="identity",size=1,alpha=0.5) +
            geom_line(aes(y=z),color=gCol1[3],size=1.2)
        ##geom_line(aes(y=t),color=gCol1[5],size=1.2)
        ggplot(data.frame(day=1:nrow(fs),y=seasonal,z=decays,t=fs[,"web"]),aes(x=day))+
            geom_line(aes(y=y),color=gCol1[5],size=1.2) +
            geom_line(aes(y=z),color=gCol1[3],size=1.2) +
            geom_line(aes(y=t),color=gCol1[1],size=1.2)
    }
    corL <- c(corL,cor(decays,fs[,"web"]))
    if(isPlot){##----------------------decomposition-autocorr--------------------
        png(paste('figPredict/crossCorr',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        ccf(decays,fs[,"web"])
        dev.off()
    }
    xcor <- ccf(decays,fs[,"web"],plot=FALSE)
    corF <- xcor$acf[,,1]
    lag <- xcor$lag[,,1]
    corF <- corF[(length(corF)/2):length(corF)]
    reslm <- lm(corF ~ poly(n,5),data.frame(n=1:length(corF),corF=corF))
    if(isPlot){##----------------------decomposition-autocorr--------------------
        plot(x=1:length(corF),corF,type="l",col="red",xlab="lag",ylab="cross correlation")
        lines(predict(reslm,data.frame(n=1:length(corF),corF=corF)),col="blue")
        lines(rep(0,length(corF)))

        legend("top",inset=-.05,cex=1,title="",c("x corr","fit"),horiz=TRUE,lty=c(1,1),lwd=c(2,2),col=c("red","blue"))
    }
    lagL <- c(lagL,Re(polyroot(reslm$coefficients[2:6])[1]))

    ## plot(x=fs$n,fs$tv,type="l")
    ## lines(fs$fit)
    ## lines(as.numeric(ma(impr,order=7,centre=T)))
    ## qqnorm(x)
    ## hist(diff(log(x)),type="l")

    ssp <- spectrum(fs[,"web"],plot=FALSE)
    if(isPlot){##----------------------decomposition-autocorr--------------------
        png(paste('figPredict/spe',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        spectrum(fs[,"web"])
        dev.off()
    }
    per <- 2*pi*ssp$freq[ssp$spec==max(ssp$spec)]
    per2 <- 2*pi*ssp$freq[ssp$spec==max(ssp$spec[14:length(ssp$freq)])]
    reslm <- lm(web ~ sin(per*n)+cos(per*n)+ sin(per2*n)+cos(per2*n),data=fs)
    reslm <- lm(web ~ sin(per*n)+ sin(per2*n),data=fs)
    fs <- cbind(fs,predict(reslm,fs,interval='prediction')) #
    if(isPlot){##----------------------decomposition-autocorr--------------------
        png(paste('figPredict/spe',gsub("csv","png",fMeasure[k]),sep=""),width=pngWidth,height=pngHeight,units="px")
        sinInt <- as.data.frame(predict(reslm,fs,interval='prediction'))
        plot(fs[,"web"],type="l",col="red",xlab="day",ylab="imps")
        lines(sinInt$fit,type="l",col="blue")
        legend("top",inset=-.05,cex=1,title="",c("signal","fit"),horiz=TRUE,lty=c(1,1),lwd=c(2,2),col=c("red","blue"))

        dev.off()
    }
    perL <- c(perL,reslm$coefficients[3]/reslm$coefficients[2])

    foreI <- data.frame(date=seq(fs[nrow(fs),"date"],fs[nrow(fs),"date"]+13, "day"))
    fit <- auto.arima(ts(fs[,"tv"], frequency=7, start=1))
    foreI <-  cbind(foreI,as.data.frame(forecast(fit, 14)))
    ##fit <- ets(impr)
    ##fit <- auto.arima(ts(fs[,"web"], frequency=7, start=1))
    hw <- HoltWinters(ts(fs[,"web"],frequency=7,start=1))
    foreL <- predict(hw,n.ahead=14,prediction.interval=T,level=0.95)
    foreI <- cbind(foreI,as.data.frame(foreL))
    if(isPlot){##----------------------forecast--------------------
        plot(hw,foreL)
    }
    colnames(foreI) <- c("date","fit_tv","lwr_tv","upr_tv","lwr_tv2","upr_tv2","fit_web","lwr_web","upr_web")
    gLabel = c("data","impression (normalizzate)",paste("evoluzione bacino video"),"-")
    p <- ggplot(data=fs,aes(x=date)) +
        geom_line(aes(y=decays,colour="decays"),stat="identity",size=1) +
        geom_line(aes(y=fit,colour="fit web"),stat="identity",,size=1) +
        geom_bar(data=foreI,aes(y=fit_tv,fill="prediction tv"),stat="identity",alpha=.5) +
        geom_line(data=foreI,aes(y=fit_web,colour="prediction web"),stat="identity",size=1.4) +
        geom_ribbon(data=foreI,aes(ymin=lwr_web,ymax=upr_web),size=.2,alpha=.25,fill=gCol1[10]) +
        geom_line(aes(y=web,colour="web"),stat="identity",size=1.4) + #
        geom_bar(aes(y=tv,fill="tv"),stat="identity",alpha=.5) +
        annotate("text",x=foreI[7,"date"], y = max(fs$tv), label = "prediction",color="red") +
        annotate("rect",xmin=foreI[1,"date"],xmax=foreI[14,"date"],y=0.05,ymin=max(fs$tv),ymax=max(fs$tv),fill="red",size=1.5,alpha=.1) +
        scale_colour_manual("",breaks=c("fit web","prediction web","decays","web"),values=c(gCol1[4],gCol1[9],gCol1[6],gCol1[9]) ) +
        scale_fill_manual("",values=c(gCol1[8],gCol1[7]),breaks=c("prediction tv","tv")) +
        scale_x_discrete(name="data") +
        theme(
            axis.text.x = element_text(angle = 30, hjust = 1),
            legend.position="bottom", legend.box = "horizontal",
            panel.background = element_blank()
        ) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
    p
    ggsave(paste('figPredict/forecast',gsub("csv","png",fMeasure[k]),sep=""),p,width=gWidth,height=gHeight)

}

nameL <- gsub("raw/sync","",nameL)
nameL <- gsub("\\.csv","",nameL)

chComp <- data.frame(name=nameL,cor=corL,lag=lagL,per=perL)
chComp <- chComp[order(-chComp$per),]
chComp$name <- factor(chComp$name,levels=chComp$name)
gLabel = c("sito","persistance",paste("metrica per sito"),"-")
ggplot(chComp,aes(x=name)) +
    geom_bar(aes(y=per),stat="identity",fill=gCol[1]) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])


##write.csv(chComp,"out/chComp.csv")

chComp <- read.csv("out/chComp.csv")


library('corrplot') #package corrplot

chComp <- data.frame(cor=corL,lag=lagL,per=perL)
chComp[is.na(chComp)] <- 0
chComp <- chComp[-c(6,7,8,9,11),]
iCorr <- cor(t(chComp))
corrplot.mixed(iCorr,lower="pie",upper="number")


##
