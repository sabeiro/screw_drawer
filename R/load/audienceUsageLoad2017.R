#!/usr/bin/env Rscript
setwd('~/lav/media')
source('src/R/graphEnv.R')
library(RCurl)
library(digest)
library(base64enc)
library('jsonlite')
library('rjson')
library('RJSONIO')
library('httr')


cred <- fromJSON('credenza/dotandmedia.json')
token <- POST("http://api.dashboard.ad.dotandad.com:9190/api/v1/token",body=paste('{"username":"',cred[[1]],'","password":"',cred[[2]],'"}',sep="") )
token = httr::content(token,type="application/json")$resource$token
sData = paste('{"token":"',token,'","request":{"status":1,"type":"bk"}}',sep="")
resq = POST("http://api.dashboard.ad.dotandad.com:9190/api/v1/getExternalDmpClusters",body=sData)
stop_for_status(resq)
idList = httr::content(resq)$resource$rows
idConv = NULL
for(i in 1:length(idList)){
    idConv = rbind(idConv,c(unlist(idList[[i]])))
}

html <- getURLContent('http://services.bluekai.com/Services/WS/Campaign?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=mYryT6VXQYSb3pTwzxfp6%2BE%2BpKrvr9t8r5VpKYeaVR4%3D')
campList <- RJSONIO::fromJSON(html)$campaigns

campD <- NULL
for(i in as.numeric(labels(campList)) ){
    campD <- rbind(campD,c(campList[[i]]$name,campList[[i]]$campaignId,campList[[i]]$activated))
}
campD <- as.data.frame(campD)
colnames(campD) <- c("name","id","active")
colnames(idConv) = c("name","id","code","type","active")
campD = rbind(campD,idConv[,colnames(campD)])

##fs <- read.csv("log/bkKeyOrder.csv",stringsAsFactor=F)
fileL = c("log/bkOrder17-01.csv.gz","log/bkOrder17-02.csv.gz","log/bkOrder17-03.csv.gz","log/bkOrder17-04.csv.gz","log/bkOrder17-05.csv.gz","log/bkOrder17-06.csv.gz","log/bkOrder17-07.csv.gz","log/bkOrder17-08.csv.gz")
fsT <- NULL
for(i in fileL){
    print(i)
    fs <- read.csv(gzfile(i),stringsAsFactor=F)
    fs <- fs[grepl("=bk_",fs$MatchedKeyword) | grepl("^w=",fs$MatchedKeyword),]
    fs$key <- fs$MatchedKeyword %>% gsub("^.*=bk_","",.) %>% gsub("^.*w=","",.) %>% gsub("\\^.*$","",.)
    fs$key2 <- NULL
    set <- grepl("§bk_",fs$key)
    fsT <- fs[set,]
    fsT$key <- gsub("^.*§bk_","",fs$key[set])
    print(paste("double count:",percent(nrow(fsT)/nrow(fs))))
    fs <- rbind(fs,fsT)
    fs$key[set] <- gsub("§bk_.*$","",fs$key[set])
    fs$date <- as.Date(as.character(fs$Data),format="%Y%m%d",origin="1970-01-01")
    orderNA <- ddply(fs,.(OrderExtId),summarise,imps=sum(imps))
    print(paste("missing order:",orderNA[is.na(orderNA$OrderExtId),"imps"]/sum(orderNA[,"imps"])))
    fs <- merge(fs,campD,by.x="key",by.y="id",all.x=T)
    fs$name[grepl("103163",fs$key)] <- "F z beha"
    fs$name[grepl("108047",fs$key)] <- "F z"
    fs$source <- "first"
    fs$source[grepl(" z",fs$name)] <- "zalando intent"
    ##fs$source[grepl("shopp",fs$name)] <- "e-shoppers"
    fs$source[grepl(" z",fs$name) & grepl("s-d",fs$name)] <- "zalando s/d"
    fs$source[grepl(" z",fs$name) & grepl("pub",fs$name)] <- "zalando s/d"
    fs$source[grepl(" z",fs$name) & grepl("beha",fs$name)] <- "zalando behavioural"
    fs$source[grepl(" 1st",fs$name) & grepl("s-d",fs$name)] <- "first s/d"
    fs$source[grepl(" v",fs$name)] <- "vodafone"
    fs$name <- fs$name %>% gsub("pub ","",.) %>% gsub("s-d ","",.) %>% gsub(" v","",.) %>% gsub(" z","",.) %>% gsub(" 1st","",.) %>% gsub(" beha","",.)
    fs$format <- "Display"
    fs$format[fs$Size=="SPOT"] <- "Video"
    fs <- fs[,c("date","AdvertiserName","name","source","format","imps","OrderExtId",'Size')]
    colnames(fs) <- c("date","camp","aud","source","format","imps","OrderExtId","Size")
    fsT <- rbind(fsT,fs)
}
write.csv(fsT,"log/bkOrder2017.csv")
