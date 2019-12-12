#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
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
library(tripack)
library('corrplot') #package corrplot
library(Matrix)


## advList <- read.csv("raw/advComplete.csv",sep="\t")
## varList <- c("advertiser","property","content","format","AdvertiserName","Publisher","Site","Channel","cat")
## varLoopIn <- c(1,1,1,5,5,5,9,9,9)
## varLoopOut<- c(6,7,8,6,7,8,6,7,8)

advList <- read.csv("raw/adv2015short.csv",sep=",",stringsAsFactor=FALSE)
advList$subcat <- unlist(lapply(strsplit(advList$cat,split="|"),"[[",1))
advList$Imps <- as.numeric(advList$Imps)
advList$Click <- as.numeric(advList$Click)


varList <- c("AdvertiserName","cat","subcat","Section","Channel","Site","Publisher","DeviceType","Size")
varLoopIn <- NULL#c(1,1,1,1,1,1,8,8,8,8,8,8)
varLoopOut<- NULL#c(2,3,4,5,6,7,2,3,4,5,6,7)
for(i in 1:(length(varList)-1)){
    for(j in (i+1):length(varList)){
    varLoopIn <- c(varLoopIn,i)
    varLoopOut <- c(varLoopOut,j)
    }
}

advCor <- matrix(ncol=length(varList),nrow=length(varList),data=0)
colnames(advCor) <- varList
rownames(advCor) <- varList

1000000/40000

k <- 1
comm_prob = 0.60
for(k in 1:length(varLoopIn)){
    iN <- varLoopIn[k]
    oN <- varLoopOut[k]
    print(paste("aggregate",varList[iN],varList[oN]))
    aggr1 <- ddply(advList,c(varList[iN],varList[oN]),summarise,imps = sum(Imps,na.rm=TRUE),click = sum(Click,na.rm=TRUE))
    impsSum <- as.matrix(xtabs(paste("imps ~",varList[iN],"+",varList[oN]),data=aggr1))
    ##impsSum <- acast(aggr1,paste(varList[iN],"~",varList[oN]),value.var="imps")
    clickSum <- as.matrix(xtabs(paste("click ~",varList[iN],"+",varList[oN]),aggr1))
    ctrSum <- as.matrix(clickSum / impsSum)
    ctrSum[is.na(ctrSum)] <- 0
    ctrSum[is.infinite(ctrSum)] <- 0
    write.csv(impsSum,paste("out/train/advCorrImps",varList[iN],varList[oN],".csv",sep=""),sep="\t")
    write.csv(ctrSum,paste("out/train/advCorrCtr",varList[iN],varList[oN],".csv",sep=""),sep="\t")

    print(paste("correlation",varList[iN],varList[oN]))
    rSum = sort(rowSums(impsSum),decreasing=TRUE)
    lim = quantile(rSum, probs=comm_prob)
    lim = 0
    x1 <- c(impsSum[rowSums(impsSum)>lim,colSums(impsSum)>lim])
    x2 <- c(clickSum[rowSums(impsSum)>lim,colSums(impsSum)>lim])
    #advCor[varList[iN],varList[oN]] <- cor(x1,x2,method="spearman")
    advCor[iN,oN] <- cor(x1,x2,method="kendall")
    advCor[oN,iN] <- advCor[iN,oN]

    impsSum = t(impsSum) %*% impsSum
    ctrSum = t(ctrSum) %*% ctrSum
    ctrSum[is.nan(ctrSum)] <- 0
    ctrSum[is.infinite(ctrSum)] <- 0
    write.csv(impsSum,paste("out/train/advAdjaImps",varList[iN],varList[oN],".csv",sep=""),sep="\t")
    write.csv(ctrSum,paste("out/train/advAdjaCtr",varList[iN],varList[oN],".csv",sep=""),sep="\t")
}

write.csv(advCor,paste("out/train/advCorr",".csv",sep=""))

fName <- paste("fig/corr","Adv",".png",sep="")
png(fName,width=pngWidth,height=pngHeight)
corrplot.mixed(advCor,lower="pie",upper="number")
dev.off()

## plot(x1,x2)
## abline(lm(x1~x2))
## advSerie <- data.frame(x1 = x1, x2 = x2)
## pairs(advSerie)

prop <- c("http://www.amando.it/","http://www.barzellette.net/","http://www.casafacile.it/","http://www.comingsoon.it/","http://www.donnamoderna.com/","http://www.edonna.it/","http://www.giraitalia.it/","http://www.grandefratello.mediaset.it/","http://www.ilvicolodellenews.it/","http://www.ilgiornale.it/","http://www.misya.info/","http://www.newsued.com/","http://www.oroscopo.it/","http://www.sorrisi.com/","http://www.meteo.it/","http://www.unadonna.it/","http://www.gnamgnam.it/","http://www.lospicchiodaglio.it/","http://www.salepepe.it/","http://www.panorama.it/","http://www.panorama-auto.it/","http://www.patentati.it/","http://www.r101.it/","http://www.radioitalia.it/","http://www.rockol.it/","http://www.mariadefilippi.mediaset.it/","http://www.mammenellarete.nostrofiglio.it","http://www.nostrofiglio.it/","http://www.sportmediaset.mediaset.it/","http://www.sportube.tv/","http://www.starbene.it/","http://www.tgcom24.mediaset.it/")
