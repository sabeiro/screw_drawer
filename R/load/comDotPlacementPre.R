#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
rm(list=ls())

source('script/graphEnv.R')

monthL <- c("January","February","March","April","May")

month <- monthL[5]
for(month in monthL){
    print(month)
    fs <- read.csv(paste("raw/priceSection",month,".csv",sep=""))
    head(fs)
    str(fs)

    metricN <- "Size"
    cs <- ddply(fs,metricN,summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob = 0.8
    lim = quantile(cs$imps,cumprob)
    metricF <- cs[cs$imps>lim,metricN]
    fs <- fs[fs[,metricN] %in% metricF,]

    metricN <- "Publisher"
    cs <- ddply(fs,metricN,summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob = 0.5
    lim = quantile(cs$imps,cumprob)
    metricF <- cs[cs$imps>lim,metricN]
    fs <- fs[fs[,metricN] %in% metricF,]

    metricN <- "Size"
    cs <- ddply(fs,metricN,summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob = 0.8
    lim = quantile(cs$imps,cumprob)
    metricF <- cs[cs$imps>lim,metricN]
    fs <- fs[fs[,metricN] %in% metricF,]


    metricN <- "Size"
    cs <- ddply(fs,metricN,summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob = 0.8
    lim = quantile(cs$imps,cumprob)
    metricF <- cs[cs$imps>lim,metricN]
    fs <- fs[fs[,metricN] %in% metricF,]

}
