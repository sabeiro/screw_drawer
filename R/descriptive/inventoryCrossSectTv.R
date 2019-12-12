#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('~/lav/media')

source('src/R/graphEnv.R')
library(gtools)
library("forecast")
library(stringi)
library(wordcloud)
library(RColorBrewer)
library(igraph)
library(ggplot2)
library(tm)
library(cluster)
##library(FactoMineR)
library(plyr)
library(reshape)
library(deldir)
library('corrplot') #package corrplot
library(tripack)
comprob <- .98

##install.packages('seewave')
##library(seewave)
##install.packages('signal')
##library(signal)

##frequenza (giornalieri, settimanali, bisettimanali)/gruppo

fs <- read.csv("raw/telAmici.csv",stringsAsFactors=FALSE)[,c(1,2,6,7)]
fs <- rbind(fs,read.csv("raw/telColorado.csv",stringsAsFactors=FALSE)[,c(1,2,7,8)])
fs <- rbind(fs,read.csv("raw/telPosta.csv",stringsAsFactors=FALSE)[,c(1,2,6,7)])
fs <- rbind(fs,read.csv("raw/telUominiEDonne.csv",stringsAsFactors=FALSE)[,c(1,2,7,8)])
fs <- rbind(fs,read.csv("raw/telSegreto.csv",stringsAsFactors=FALSE)[,c(1,2,6,7)])
fs <- rbind(fs,read.csv("raw/telIene.csv",stringsAsFactors=FALSE)[,c(1,2,6,7)])
fs$Date <- as.Date(fs$Date,format="%d/%m/%Y")
fs <- fs[order(fs$Date),]
colnames(fs) <- c("date","desc","tot","tot2")
fs$period <- "giornaliero"
set <- FALSE
set <- set | grepl("ASPETTANDO STASERA",fs$desc)
set <- set | grepl("IL MEGLIO DI",fs$desc)
set <- set | grepl("IN PASSERELLA",fs$desc)
set <- set | grepl("SPECIALE",fs$desc)
fs[set,"period"] <- "occasionale"
set <- FALSE
set <- set | grepl("FASE SERALE",fs$desc)
set <- set | grepl("COLORADO",fs$desc)
set <- set | grepl("CE POSTA PER TE",fs$desc)
set <- set | grepl("LE IENE",fs$desc)
fs[set,"period"] <- "settimanale"
table(fs$period)

fs$desc <- gsub("[[:digit:]]","",fs$desc)
fs$desc <- gsub("[[:punct:]]","",fs$desc)
fs$desc <- gsub("Real Time ","",fs$desc)
fs$desc <- gsub("Canale ","",fs$desc)
fs$desc <- gsub(" DI MARIA","",fs$desc)
fs$desc <- gsub(" DE FILIPPI","",fs$desc)
fs$desc <- gsub(" E POI","",fs$desc)
fs$desc <- gsub(" CASTING","",fs$desc)
fs$desc <- gsub(" OLTRE","",fs$desc)
fs$desc <- gsub(" SHOW","",fs$desc)
fs$desc <- gsub(" SPECIALE","",fs$desc)
fs$desc <- gsub("IL MEGLIO DI","",fs$desc)
fs$desc <- gsub(" FASE SERALE","",fs$desc)
fs$desc <- gsub("IN PASSERELLA","",fs$desc)
fs$desc <- gsub("ASPETTANDO STASERA","VERSO IL SERALE",fs$desc)
fs$desc <- gsub("VERSO IL SERALE","",fs$desc)
fs$desc <- gsub("FINALE","",fs$desc)
fs$desc <- gsub(" var","",fs$desc)
fs$desc <- gsub(" soap","",fs$desc)
fs$desc <- gsub(" $","",fs$desc)
fs$desc <- gsub("^ ","",fs$desc)
fs$desc <- gsub("^ ","",fs$desc)
table(fs$desc)
head(fs)

##fs <- merge(x=fs,y=timeRef,by="date",all=TRUE)
##fs <- fs[,c(1,2,3)]
##fs[is.na(fs)] <- 0
write.csv(fs,"raw/telComplessivo.csv")

aggrAll <- as.data.frame.matrix(t(xtabs("tot ~ desc + date",data=fs[fs$period=="giornaliero",])))
aggrAll <- as.data.frame.matrix(t(xtabs("tot ~ desc + date",data=fs)))
aggrM1 <- aggrAll

i <- 2
plot(aggrAll[,i],type="l")
print(colnames(aggrAll)[i])

timeD <- min(fs$date):max(fs$date)-as.numeric(min(fs$date))
timeD <- fs$date[1]:fs$date[nrow(fs)]-as.numeric(min(fs$date))
timeRef <- data.frame(date=as.Date(timeD,format="%Y-%m-%d",origin=min(fs$date)),day=1)
weekY <- unique(format(timeRef[format(timeRef$date,"%Y")==2016,"date"],"%W"))
dateL <- data.frame(date=as.Date(rownames(aggrAll)))
dateL$W <- as.numeric(format(dateL$date,"%W"))
dateL$Y <- as.numeric(format(dateL$date,"%y"))

NLevel <- 9
NCluster <- 7

melted <- fs#melt(aggrM1,id="X")
gLabel = c("data","reach",paste("evoluzione pubblico tv"),"canale")
p <- ggplot(melted,aes(x=date,y=tot,group=desc)) +
    geom_bar(aes(fill=desc),stat="identity",alpha=0.3) +
    ##geom_text(aes(fill=value,label=formatC(value*100,digit=0,format="f")),colour="white",size=4) +
    ##scale_fill_gradient(low="white",high="steelblue") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    ##scale_x_date(date_breaks = "1 week", date_labels = "%W") +
    ##xlim(melted$date[300], melted$date[600]) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

##-----------------------------characteristic-parameters--------------------
aggrSpe <- NULL##data.frame(X=aggrM1$X)
aggrSea <- NULL##data.frame(X=aggrM1$X)
aggrRes <- NULL##data.frame(X=aggrM1$X)
aggrAut <- NULL##data.frame(X=aggrM1$X)
aggrTre <- NULL##data.frame(X=aggrM1$X)
densBreak <- seq(-200,200,by=1)
i <- 1
##3
NSet <- ncol(aggrAll)
cName <- colnames(aggrAll)
for(i in 1:ncol(aggrAll) ){
    print(cName[i])
    impr = ts(aggrAll[,i], frequency=7)##, start=c(2012,07,01), end=c(2016,07,03))
    impr2 = window(impr)##, start=c(2013,10), end=c(2015, 12))
    dog = stl(impr2, s.window="periodic")
    ##plot(dog)
    aggrSpe <- cbind(aggrSpe,stats::spectrum(aggrAll[,i],plot=FALSE)$spec)
    ##aggrSpe <- cbind(aggrSpe,stats::spectrum(dog$time.series[,1],plot=FALSE)$spec)
    aggrSea <- cbind(aggrSea,dog$time.series[,1])
    aggrTre <- cbind(aggrTre,dog$time.series[,2])
    aggrRes <- cbind(aggrRes,density(dog$time.series[,3]/sum(abs(dog$time.series[,3])),n=200,from=-0.005,to=0.005)$y)
    ##plot(density(dog$time.series[,3]/sum(abs(dog$time.series[,3])),n=200,from=-0.01,to=0.01))
    aggrAut <- cbind(aggrAut,acf(impr2, plot=FALSE)$acf)
    fit <- auto.arima(impr2)
    foreI <- data.frame(date=seq(fs[nrow(fs),"date"],fs[nrow(fs),"date"]+13, "day"))
    foreI <-  cbind(foreI,as.data.frame(forecast(fit, 14)))
    colnames(foreI) <- c("date","fore","80m","80M","95m","95M")
    p <- ggplot(data.frame(date=as.Date(rownames(aggrAll)),imps=aggrAll[,i]),aes(x=date,y=imps,group=1)) +
        geom_line(aes(color=gCol1[1])) +
        geom_line(data=foreI,aes(x=date,y=fore),color=gCol[3])
}

aggrSpe <- as.data.frame(aggrSpe)
colnames(aggrSpe) <- colnames(aggrAll)
aggrSpe$X <- 1:nrow(aggrSpe)
aggrSea <- as.data.frame(aggrSea)
colnames(aggrSea) <- colnames(aggrAll)
aggrSea$X <-  1:nrow(aggrSea)
aggrRes <- as.data.frame(aggrRes)
colnames(aggrRes) <- colnames(aggrAll)
aggrRes$X <-  1:nrow(aggrRes)
aggrAut <- as.data.frame(aggrAut)
colnames(aggrAut) <- colnames(aggrAll)
aggrAut$X <-  1:nrow(aggrAut)
aggrTre <- as.data.frame(aggrTre)
colnames(aggrTre) <- colnames(aggrAll)
aggrTre$X <-  1:nrow(aggrTre)

gLabel = c("frequency","amplitude",paste("power spectrum"),"channel")
p <- ggplot(melt(aggrSpe,id="X"),aes(x=X,y=value,group=variable)) +
    geom_line(aes(color=variable),size=1.5) +
    scale_x_log10() + scale_y_log10() + annotation_logticks() +
    theme(
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
gLabel = c("days","amplitude",paste("seasonality"),"channel")
p <- ggplot(melt(aggrSea,id="X"),aes(x=X,y=value,group=variable)) +
    geom_line(aes(color=variable),size=1.5) +
    xlim(0,28) +
    theme(
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
gLabel = c("deviation","amplitude",paste("remainder distribution"),"channel")
set <- !(grepl("SPECIALE",colnames(aggrRes)))
p <- ggplot(melt(aggrRes[,set],id="X"),aes(x=X-nrow(aggrRes)/2,y=value,group=variable)) +
    geom_line(aes(color=variable),size=1.5) +
    ##scale_y_log10() + annotation_logticks() +
    theme(
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file="fig/invTvRemainder.jpg",plot=p,width=gWidth,height=gHeight)
gLabel = c("days","amplitude",paste("auto correlation"),"channel")
p <- ggplot(melt(aggrAut,id="X"),aes(x=X,y=value,group=variable)) +
    geom_line(aes(color=variable),size=1.5) +
    ## scale_x_log10() + scale_y_log10() + annotation_logticks() +
    theme(
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file="fig/invTvSpectrum.jpg",plot=p,width=gWidth,height=gHeight)
gLabel = c("day","imps",paste("trend"),"channel")
p <- ggplot(melt(aggrTre,id="X"),aes(x=X,y=value,group=variable)) +
    geom_line(aes(color=variable),size=1.5) +
    ## scale_x_log10() + scale_y_log10() + annotation_logticks() +
    theme(
        legend.position="bottom", legend.box = "horizontal",
        panel.background = element_blank()
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p


corM <- cor(aggrAll)
diag(corM) <- 0
corSpe <- cor(aggrSpe[-ncol(aggrSpe)])
diag(corSpe) <- 0
corSea <- cor(aggrSea[-ncol(aggrSea)])
diag(corSea) <- 0
corRes <- cor(aggrRes[-ncol(aggrRes)])
diag(corRes) <- 0
corAut <- cor(aggrAut[-ncol(aggrAut)])
diag(corAut) <- 0
corTot <- corM + corSpe + corSea + corRes + corAut
jpeg("intertino/fig/invTvCor.jpg",width=pngWidth,height=pngHeight)
corrplot.mixed(corTot,lower="square",upper="number",is.corr = FALSE)
dev.off()

##------------------------------prediction-errors-----------------------------------
if(FALSE){##obsolete

i <- 1
plot(aggrAll[,i],type="l")
print(cName[i])
w <- 5
predDiff <- NULL
cName <- colnames(aggrAll)
for(i in 1:ncol(aggrAll) ){
    print(cName[i])
    for(w in weekY[-length(weekY)]){
        set <- TRUE
        set <- set & !(dateL$Y==16 & dateL$W >= w)
        aggrAll[,i]
        impr = ts(aggrAll[set,i], frequency=7,start=1)##, start=c(2012,07,01), end=c(2016,07,03))
        impr2 = window(impr)##, start=c(2013,10), end=c(2015, 12))
        fit <- auto.arima(impr2)
        ##fit <- arima(impr2,order=c(0, 2, 1),seasonal=list(order=c(0, 0, 1),period=7),xreg=as.numeric (seq (mydata) == 48))
        ##fit <- HoltWinters(impr2)
        ##foreL <- predict(fit, n.ahead = 14, prediction.interval = T, level = 0.95)
        dateFore <- max(dateL[set,"date"])
        foreI <- data.frame(date=seq(dateFore+1,dateFore+7,"day"))
        foreI <-  cbind(foreI,as.data.frame(forecast(fit,7)))
        colnames(foreI) <- c("date","fore","80m","80M","95m","95M")
        set <- TRUE
        set <- set & !(dateL$Y==16 & dateL$W > w)
        serD <- data.frame(date=dateL$date[set],imps=aggrAll[set,i])
        if(FALSE){
            p <- ggplot(serD,aes(x=date,y=imps,group=1)) +
                geom_line(color=gCol1[1],size=1.5) +
                xlim(dateFore-108,dateFore+7) +
                geom_line(data=foreI,aes(x=date,y=fore),color=gCol[3],size=1.5)
            p
        }
        predTmp <- merge(foreI,serD,by="date",all.x=TRUE)
        predTmp$channel <- cName[i]
        predDiff <- rbind(predDiff,predTmp)
    }
}
head(predDiff)
predDiff$imps[is.na(predDiff$imps)] <- 0
predDiff$ratio <- (predDiff$fore - predDiff$imps)/(predDiff$imps + predDiff$fore)
predDiff$ratio[is.na(predDiff$ratio)] <- 0
predDiff$ratio[predDiff$ratio==1] <- 0


plot(density(predDiff$ratio[!predDiff$ratio==1]))

write.csv(predDiff,"out/predictionRollingArimaDaily.csv")
head(predDiff)
melted <- melt(predDiff[,c(1,2,7,8,9)],id=="date")
gLabel = c("data","devizione relativa",paste("rapporto tra previsione e storico"),"canale")
p <- ggplot(predDiff,aes(x=date,group=channel,color=channel)) +
    ## geom_line(aes(y=imps),size=1.5) +
    ## geom_line(aes(y=fore),size=1.5) +
    geom_line(aes(y=ratio),size=1.5) +
    ##scale_color_discrete(breaks=gCol1) +
    xlim(dateFore-108,dateFore+7) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

}


