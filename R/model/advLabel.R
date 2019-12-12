#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library(RColorBrewer)
library(igraph)
library(tm)
library(wordcloud)

advList <- read.csv("raw/advCatPrice.csv",sep=",",stringsAsFactor=FALSE)
advList$ValoreNetto <- as.numeric(gsub("'","",advList$ValoreNetto))
advList$ValoreNetto[is.na(advList$ValoreNetto)] <- 0


head(advList)

cumprob = 0.96
cloud_lim = 500

wFreq <- as.data.frame(table(advList$cat))
wFreq
wordcloud(wFreq$Var1,wFreq$Freq,random.order=FALSE, colors=luftPal)

wFreq <- as.data.frame(table(advList$subCat))
wFreq <- wFreq[!wFreq$Var1=="",]
wordcloud(wFreq$Var1,wFreq$Freq,random.order=FALSE, colors=luftPal)

wList <- unlist(strsplit(advList$name,split=" "))
wList <- gsub("[[:punct:]]","",wList)
wList <- removeWords(wList,read.csv("raw/advCatStop.csv")$name)
wList <- wList[!wList==""]
wFreq <- as.data.frame(table(wList))
wordcloud(wFreq$wList,wFreq$Freq,random.order=FALSE, colors=luftPal)

wList <- advList$name
wList <- gsub("[[:punct:]]","",wList)
for(i in read.csv("raw/advCatStop.csv")$name){
    wList <- gsub(i,"",wList)
}
wFreq <- data.frame(wList=wList,Freq=advList$ValoreNetto)
lim = quantile(wFreq$Freq,cumprob)
wFreq <- wFreq[wFreq$Freq>lim,]
wordcloud(wFreq$wList,wFreq$Freq,random.order=FALSE, colors=luftPal)

head(advComp)

## advList1 <- read.csv("raw/advCatDot.csv",sep=",",stringsAsFactor=FALSE)
## advList1$Cliente <- gsub("\\* ","",advList1$Cliente)
## advComp <- merge(advList,advList1,by.x="name",by.y="Cliente",all=TRUE)
##write.csv(advComp,"raw/advCatPrice.csv")


