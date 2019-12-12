#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
rm(list=ls())

source('script/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)

monthL <- c("January","February","March","April","May")

placeF <- read.csv("raw/placementTable.csv")


month <- monthL[5]
for(month in monthL){
    print(month)
    fs <- read.csv(paste("raw/priceSection",month,".csv",sep=""))
    head(fs)
    str(fs)

    ##---------------------------generate-publisher-site-section-tables----------------------
    chL1 <- ddply(fs,.(Publisher,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE)*100,cpm=sum(FlightTotalSales,na.rm=TRUE)/sum(Imps,na.rm=TRUE)*1000)
    chL <- as.data.frame.matrix(xtabs("imps ~ Publisher + Size",data=chL1))

    head(chL)

    chL1 <- ddply(cs,.(editor,position),summarise,view_pc=sum(view_pc,na.rm=TRUE)/sum(imps_pc,na.rm=TRUE),view_mob=sum(view_mob,na.rm=TRUE)/sum(imps_mob,na.rm=TRUE) )
    chL2 <- as.data.frame.matrix(xtabs("view_pc ~ editor + position",data=chL1))
    chL2$editor <- rownames(chL2)
    chL <- merge(chL,chL2,by="editor")
    chL2 <- as.data.frame.matrix(xtabs("view_mob ~ editor + position",data=chL1))
    chL2$editor <- rownames(chL2)
    chL <- merge(chL,chL2,by="editor")
    chL <- chL[order(-chL$imps),]
    write.csv(chL,paste("intertino/data/heatmap","Editor",month,".csv",sep=""))


    stL <- ddply(cs,.(Site.Name),summarise,imps=sum(imps_pc,na.rm=TRUE)+sum(imps_mob,na.rm=TRUE),view=sum(view_pc,na.rm=TRUE)+sum(view_mob,na.rm=TRUE),editor=head(editor,1))
    stL1 <- ddply(cs,.(Site.Name,position),summarise,view_pc=sum(view_pc,na.rm=TRUE)/sum(imps_pc,na.rm=TRUE),view_mob=sum(view_mob,na.rm=TRUE)/sum(imps_mob,na.rm=TRUE) )
    stL2 <- as.data.frame.matrix(xtabs("view_pc ~ Site.Name + position",data=stL1))
    stL2$Site.Name <- rownames(stL2)
    stL <- merge(stL,stL2,by="Site.Name")
    stL2 <- as.data.frame.matrix(xtabs("view_mob ~ Site.Name + position",data=stL1))
    stL2$Site.Name <- rownames(stL2)
    stL <- merge(stL,stL2,by="Site.Name")
    stL <- stL[order(-stL$imps),]
    write.csv(stL,paste("intertino/data/heatmap","Site",month,".csv",sep=""))


    scL <- ddply(cs,.(site),summarise,imps=sum(imps_pc,na.rm=TRUE)+sum(imps_mob,na.rm=TRUE),view=sum(view_pc,na.rm=TRUE)+sum(view_mob,na.rm=TRUE),Site.Name=head(Site.Name,1) )
    scL1 <- ddply(cs,.(site,position),summarise,view_pc=sum(view_pc,na.rm=TRUE)/sum(imps_pc,na.rm=TRUE),view_mob=sum(view_mob,na.rm=TRUE)/sum(imps_mob,na.rm=TRUE) )
    scL2 <- as.data.frame.matrix(xtabs("view_pc ~ site + position",data=scL1))
    scL2$site <- rownames(scL2)
    scL <- merge(scL,scL2,by="site")
    scL2 <- as.data.frame.matrix(xtabs("view_mob ~ site + position",data=scL1))
    scL2$site <- rownames(scL2)
    scL <- merge(scL,scL2,by="site")
    scL <- scL[order(-scL$imps),]
    write.csv(scL,paste("intertino/data/heatmap","Section",month,".csv",sep=""))

    ch <- 1
    st <- 1
    sc <- 1
    ##---------------------------generate-json----------------------
    selCol <- c(2,5,6,7,8,9,10,11,12)
    chselCol <- c(2,4,5,6,7,8,9,10,11)
    chC <- list()
    for(ch in 1:length(chL$editor)){
        chN <- chL$editor[ch]
        stC <- list()
        stL1 <- stL[grepl(chN,stL$editor),]
        for(st in 1:length(stL1$Site.Name)){
            stN <- stL1$Site.Name[st]
            sectV <- list(label_short=stN,label_long=stN)
            scC <- list()
            scL1 <- scL[grepl(stN,scL$Site.Name),]
            for(sc in 1:length(scL1$site)){
                if(sc<1){next}
                scN <- scL1$site[sc]
                scV <- as.numeric(scL1[sc,selCol])
                scV[-1] <- scV[-1]*100
                scB <- list(label_short=scN,label_long=scN,values=scV)
                scC[[sc]] <- scB
            }
            stV <- as.numeric(stL1[st,selCol])
            stV[-1] <- stV[-1]*100
            stB <- list(label_short=stN,label_long=stN,values=stV)
            stB$children <- scC
            stC[[st]] <- stB
        }
        chV <- as.numeric(chL[ch,chselCol])
        chV[-1] <- chV[-1]*100
        chB <- list(label_short=chN,label_long=chN,values=chV)
        chB$children <- stC
        chC[[ch]] <- chB
    }
    monthV <- sum(chL$imps,na.rm=TRUE)
    monthV <- c(monthV,sapply(chselCol,function(i) weighted.mean(chL[,i],chL$imps))*100)
    monthB <- list(label_short=month,label_long=month,values=monthV)
    monthB$children <- chC

    write(toJSON(monthB),paste("intertino/data/heatmap",month,".json",sep=""))
}
