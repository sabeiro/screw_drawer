#!/usr/bin/env Rscript
setwd('~/lav/media/')
##rm(list=ls())
source('src/R/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)

monthL <- c("Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno")
mList <- c("01","02","03","04","05","06","07","08","09","10","11","12")
monthL <- c("January","February","March","April","May","June","July","August","September")
monthL <- c("June","July","August","September","October","November","December")
monthL <- c("2017January")
monthL <- c("2017Feb","2017Mar","2017Apr")

fSect <- "section"
month <- mList[1]
NSect1 <- 20
fLab <- c("total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")
chCol <- "Publisher"
stCol <- "Site"
scCol <- "Channel"


month <- monthL[7]
for(month in monthL){
    print(month)
    fs <- read.csv(paste("log/priceSection",month,".csv",sep=""),stringsAsFactor=FALSE)
    fs$FlightTotalSales <- as.numeric(gsub(",","\\.",fs$FlightTotalSales))
    ## fs$Data <- as.Date(fs$Data)
    ## fs$week <- format(fs$Data,"%W")
    source("src/R/heatJsonDotPre.R")
    write.csv(cs,paste("intertino/data/heatmapDot",month,".csv",sep=""))
    ##-------------------------generate-publisher-site-section-tables------------------
    chL <- ddply(cs,chCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE))
    chL1 <- ddply(cs,.(Publisher,Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE) )
    chL2 <- as.data.frame.matrix(xtabs("imps ~ Publisher + Size",data=chL1))
    chL2$RECTANGLE <- rowSums(chL2[,grepl("RECTANGLE",colnames(chL2))]) 
    chL2$masthead <- rowSums(chL2[,grepl("MASTHEAD",colnames(chL2))]) 
    chL2$Publisher <- rownames(chL2)
    chL <- merge(chL,chL2,by="Publisher")
    chL2 <- as.data.frame.matrix(xtabs("price ~ Publisher + Size",data=chL1))
    chL2$Publisher <- rownames(chL2)
    chL <- merge(chL,chL2,by="Publisher")
    chL <- chL[order(-chL$imps),]
    chL[is.na(chL)] <- 0
    chL[chL==Inf] <- 0
    colnames(chL) <- gsub("\\.x","_imps",colnames(chL))
    colnames(chL) <- gsub("\\.y","_price",colnames(chL))
    ## write.csv(chL,paste("intertino/data/heatmapDot","Editor",month,".csv",sep=""))

    stL <- ddply(cs,stCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE),Publisher=head(Publisher,1))
    stL1 <- ddply(cs,.(Site,Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE) )
    stL2 <- as.data.frame.matrix(xtabs("imps ~ Site + Size",data=stL1))
    stL2$RECTANGLE <- rowSums(stL2[,grepl("RECTANGLE",colnames(stL2))]) 
    stL2$masthead <- rowSums(stL2[,grepl("MASTHEAD",colnames(stL2))]) 
    stL2[,stCol] <- rownames(stL2)
    stL <- merge(stL,stL2,by=stCol)
    stL2 <- as.data.frame.matrix(xtabs("price ~ Site + Size",data=stL1))
    stL2[,stCol] <- rownames(stL2)
    stL <- merge(stL,stL2,by=stCol)
    stL <- stL[order(-stL$imps),]
    stL[is.na(stL)] <- 0
    stL[stL==Inf] <- 0
    colnames(stL) <- gsub("\\.x","_imps",colnames(stL))
    colnames(stL) <- gsub("\\.y","_price",colnames(stL))
    ## write.csv(stL,paste("intertino/data/heatmapDot","Site",month,".csv",sep=""))

    cs[,scCol] <- tryTolower(paste(cs[,scCol],cs[,stCol],sep="|"))
    scL <- ddply(cs,scCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE),Site=head(Site,1))
    scL1 <- ddply(cs,.(Channel,Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightTotalSales,na.rm=TRUE) )
    scL2 <- as.data.frame.matrix(xtabs("imps ~ Channel + Size",data=scL1))
    scL2$RECTANGLE <- rowSums(scL2[,grepl("RECTANGLE",colnames(scL2))]) 
    scL2$masthead <- rowSums(scL2[,grepl("MASTHEAD",colnames(scL2))]) 
    scL2[,scCol] <- rownames(scL2)
    scL <- merge(scL,scL2,by=scCol)
    scL2 <- as.data.frame.matrix(xtabs("price ~ Channel + Size",data=scL1))
    scL2[,scCol] <- rownames(scL2)
    scL <- merge(scL,scL2,by=scCol)
    scL <- scL[order(-scL$imps),]
    colnames(scL) <- gsub("\\.x","_imps",colnames(scL))
    colnames(scL) <- gsub("\\.y","_price",colnames(scL))
    scL[is.na(scL)] <- 0
    scL[scL==Inf] <- 0
    ## write.csv(scL,paste("intertino/data/heatmapDot","Section",month,".csv",sep=""))

    ch <- 1
    st <- 1
    sc <- 1
    ##---------------------------generate-json----------------------
    selCol <- c(1,5)
    chselCol <- c(1)
    chC <- list()
    for(ch in 1:length(chL[,chCol])){
        chN <- chL[ch,chCol]
        stC <- list()
        stL1 <- stL[grepl(chN,stL[,chCol]),]
        for(st in 1:length(stL1[,stCol])){
            stN <- stL1[st,stCol]
            sectV <- list(label_short=substr(stN,start=1,stop=5),label_long=stN)
            scC <- list()
            scL1 <- scL[grepl(stN,scL[,stCol]),]
            for(sc in 1:length(scL1[,scCol])){
                if(sc<1){next}
                scN <- scL1[sc,scCol]
                scN <- gsub("\\|.*$","",scN)
                scV <- (as.numeric(scL1[sc,-selCol]))
                scV[-1] <- scV[-1]##*100
                scB <- list(label_short=substr(scN,start=1,stop=5),label_long=scN,values=scV)
                scC[[sc]] <- scB
            }
            stV <- (as.numeric(stL1[st,-selCol]))
            stV[-1] <- stV[-1]##*100
            stB <- list(label_short=substr(stN,start=1,stop=5),label_long=stN,values=stV)
            stB$children <- scC
            stC[[st]] <- stB
        }
        chV <- (as.numeric(chL[ch,-chselCol]))
        chV[-1] <- chV[-1]##*100
        chB <- list(label_short=substr(chN,start=1,stop=5),label_long=chN,values=chV)
        chB$children <- stC
        chC[[ch]] <- chB
    }
    ##monthV <- c(monthV,sapply( (1:ncol(chL))[-chselCol],function(i) sum(chL[,i])))
    monthV <- colSums(chL[,-chselCol])

    monthB <- list(title="Prezzario",depth=2,label_short=as.character(month),label_long=month,values=as.numeric(monthV))
    monthB$children <- chC

    write(toJSON(monthB),paste("intertino/data/heatmapDot",month,".json",sep=""))
}

selLab <- data.frame(num=(1:length(colnames(scL[-selCol])))-1,name=colnames(scL[-selCol]))
selLab <- data.frame(num=(1:length(colnames(chL[-chselCol])))-1,name=colnames(chL[-chselCol]))
selLab$name <- gsub("RECTANGLE","box",selLab$name)
selLab$name <- gsub("STRIP SKIN MASTHEAD","masthead",selLab$name)
for(i in 1:nrow(selLab)){cat(paste('<option value="',selLab[i,"num"],'" unit="NONE">',selLab[i,"name"],"</option>\n",sep=""))}


