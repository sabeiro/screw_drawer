#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('/home/sabeiro/lav/media/')

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
library(psych)
library(GPArotation)
library(MASS)
library(MBESS)
library(parallel)
install.packages('MBESS')
set.seed(42)

## advList <- read.csv("raw/advComplete.csv",sep="\t")
## varList <- c("advertiser","property","content","format","AdvertiserName","Publisher","Site","Channel","cat")
## varLoopIn <- c(1,1,1,5,5,5,9,9,9)
## varLoopOut<- c(6,7,8,6,7,8,6,7,8)

varList <- c("AdvertiserName","cat","subcat","Section","Channel","Site","Publisher","DeviceType","Size")
k=6;j=9
k=6;j=9
for(k in 1:length(varList)){
    for(j in k:length(varList)){
        print(paste(varList[k],varList[j]))
        impsSum = read.csv(paste("out/train/advAdjaImps",varList[k],varList[j],".csv",sep=""),sep=",",row.names=1)
        ctrSum = read.csv(paste("out/train/advAdjaCtr",varList[k],varList[j],".csv",sep=""),sep=",",row.names=1)
        cIdx = colSums(impsSum) > quantile(colSums(impsSum),.5)
        cIdx = colSums(impsSum) > 0
        cIdx = TRUE
        impsSum = as.matrix(impsSum[cIdx,cIdx])
        alpha(impsSum,na.rm=TRUE,title='myscale',n.iter=1000) #item response analysis of congeneric measures
        MBESS::ci.reliability(impsSum, interval.type="bca", B=1000, type = "omega") 

        summary(a4)
        psych:omega(impsSum)##,n.iter = 7, p = 0.05, nfactors = 3)
        psych:schmid(impsSum)##,n.iter = 7, p = 0.05, nfactors = 3)
        psych:?alpha(Thurstone, title = "9 variables from Thurstone")
        
    }
}





## plot(x1,x2)
## abline(lm(x1~x2))
## advSerie <- data.frame(x1 = x1, x2 = x2)
## pairs(advSerie)
