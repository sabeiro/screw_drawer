#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')


fs1 <- read.csv('raw/inventoryWeekPartner.csv',encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##
head(fs1)
fs1$Imps <- as.numeric(fs1$Imps)
fs1$AdvertiserType <- gsub("Autopromo","Invenduto",fs1$AdvertiserType)
fs1$AdvertiserType <- gsub("Default","Invenduto",fs1$AdvertiserType)
partnerDat <- ddply(fs1,.(Data,AdvertiserType),summarise,Imps=sum(Imps,na.rm=TRUE))
partnerDat <- as.data.frame.matrix(xtabs(formula="Imps~.",data=partnerDat))
partnerDat$Data <- as.Date(rownames(partnerDat))
partnerDat <- partnerDat[,c("Data","Paganti","Invenduto")]
partnerDat$TotalePartner <- partnerDat$Paganti + partnerDat$Invenduto

con <- pipe("xclip -selection clipboard -i", open="w")
write.table(partnerDat[,2:4],con,row.names=F,col.names=F,sep=",")
close(con)

sSum <- sapply(names(table(fs1$Partner)),function(x) sum(fs1[fs1$Partner==x,"Imps"],na.rm=TRUE))
sSum <- sSum[order(-sSum)]
sSum/sum(sSum)
sum(sSum)


##mediaTag vm_vu_rtb_vp_0_1

##setInternet2(T)
##fs <- read.csv('http://dashboard.ad.dotandad.com/downloadFullReportExcel.jsp?p=448d78ad-fbe3-42e5-a6ae-84e9f2a7d238_9220')

## fs <- read.csv('raw/inventoryWeek.csv',encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##
## fList <- list.files(path=".")

## sectId <-  grepl('XAXIS',fs$Section) | grepl('RTB',fs$Section) | grepl('PUBMATIC',fs$Section) | grepl('STICKY',fs$Section)
## fs <- fs[!sectId,]
## tapIdx <- grepl('Tapp',fs$FlightDescription) | grepl('TAPP',fs$FlightDescription) |  grepl('tapp',fs$FlightDescription)
## tapDat <- ddply(fs[tapIdx,],.(Data),summarise,Tappi=sum(Imps,na.rm=TRUE))
## fs <- fs[!tapIdx,]
## tapDat$Tappi[tapDat$Tappi==NULL] <- 0
## filterDat <- ddply(fs,.(Data,AdvertiserType),summarise,Imps=sum(Imps,na.rm=TRUE))
## filterDat <- as.data.frame.matrix(xtabs(formula="Imps~.",data=filterDat))
## filterDat$Tappi <- if(any(tapIdx)){tapDat$Tappi}else{rep(0,7)}
## filterDat$Invenduto <- filterDat$Autopromo + filterDat$Default + filterDat$Tappi
## filterDat$Totale <- filterDat$Invenduto + filterDat$Paganti
## filterDat$Data <- as.Date(rownames(filterDat))
## filterDat$day <- rev(c("Sunday","Saturday","Friday","Thursday","Wednesday","Tuesday","Monday"))
## filterDat <- filterDat[,c("Data","day","Paganti","Default","Autopromo","Tappi","Invenduto","Totale")]

## filterDat <- merge(filterDat,partnerDat,by="Data")
## filterDat <- filterDat[rev(order(filterDat$Data)),]
## filterDat$InvendutoPerc <- percent(filterDat$Invenduto.x/filterDat$Totale) 
## filterDat$PartnerPerc <- percent(filterDat$TotalePartner/filterDat$Totale)

## filterWeek <- filterDat[1,]
## filterWeek[,3:11] <- colSums(filterDat[,3:11])
## ## filterWeek$InvendutoPerc <-  percent(filterWeek$Invenduto.x/filterWeek$Totale) 
## ## filterWeek$PartnerPerc <- percent(filterWeek$TotalePartner/filterWeek$Totale)

## filterDat
## filterWeek

## con <- pipe("xclip -selection clipboard -i", open="w")
## write.table(filterDat,con,row.names=F,col.names=F,sep=",")
## close(con)
## con <- pipe("xclip -selection clipboard -i", open="w")
## write.table(filterWeek,con,row.names=F,col.names=F,sep=",")
## close(con)

## vSection <- read.csv("raw/inventoryVideoSection.csv",stringsAsFactor=F)
## fs$cluster <- "rest"
## fs$Section = tryTolower(fs$Section)
## for(i in 1:length(vSection$canale)){##assign ch
##     fs[grepl(vSection[i,"canale"],fs$Section),"cluster"] <- vSection[i,"cluster"]
## }
## fsSect = ddply(fs,.(cluster),summarise,imps=sum(Imps))
## con <- pipe("xclip -selection clipboard -i", open="w")
## write.table(fsSect,con,row.names=F,col.names=F,sep=",")
## close(con)
## fsSect = ddply(fs,.(Data,cluster),summarise,imps=sum(Imps))
## fsSect = as.data.frame.matrix(xtabs("imps ~ Data + cluster",data=fsSect))
## fsSect$data = row.names(fsSect)

## if(FALSE){
##     library('RMySQL')
##     source('credenza/intertino.R')
##     con <- dbConnect(MySQL(),user=db_usr,password=db_pass,dbname=db_db,host=db_host)
##     on.exit(dbDisconnect(con))
##     dbWriteTable(con,value=fsSect,name="inventory_video_section",row.names=FALSE,append=TRUE,overwrite=FALSE);
##     dbDisconnect(con)
## }



## cSum <- colSums(filterDat[,3:11])
## cSum[1]+cSum[2]+cSum[3]+cSum[4]
## (cSum[2]+cSum[3]+cSum[4])/(cSum[1]+cSum[2]+cSum[3]+cSum[4])
## sum(filterDat$Paganti.y)/sum(filterDat$Paganti.x)


## sum(fs[grepl('RTB',fs$Section),"Imps"],na.rm=TRUE)
## progShare <- sum(fs[sectId,"Imps"],na.rm=TRUE)
## dirShare <- sum(fs[!sectId,"Imps"],na.rm=TRUE)
## progShare/dirShare
## sSum <- sapply(names(table(fs$Section)),function(x) sum(fs[fs$Section==x,"Imps"]))
## sSum <- sSum[order(-sSum)]
## sum(sSum[c(1:5)])/sum(sSum)
## sSum[c(1:5)]

## sum(sSum)/(cSum[1]+cSum[2]+cSum[3]+cSum[4]+cSum[5])


