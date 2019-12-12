##!/usr/bin/env Rscript
setwd('~/lav/media')
source('src/R/graphEnv.R')
library(dplyr)
library(grid)
library('rjson')
library('RJSONIO')
library("tm")

##ad server
fs <- NULL
#fs <- rbind(fs,read.csv(gzfile('log/bkOrder2016.csv.gz'),stringsAsFactor=F))
fs <- rbind(fs,read.csv(gzfile('log/bkOrder2017.csv.gz'),stringsAsFactor=F))
fs <- rbind(fs,read.csv('log/bkOrder2017.csv',stringsAsFactor=F))
fs <- ddply(fs,.(camp,OrderExtId,aud),summarise,imps=sum(imps,na.rm=T))
##brightroll
fs1 <- read.csv("raw/bkBrroll.csv",stringsAsFactor=F)
fs1$Day <- as.Date(fs1$Day,format="%m/%d/%y")
fs1$OrderExtId = fs1$Campaign.Name %>% gsub(".*_","",.)
fs1 <- fs1[,c("Day","Campaign.Name","Targeted.Audience.Name","Impressions","OrderExtId")]
colnames(fs1) <- c("date","camp","aud","imps","OrderExtId")
fs1 <- ddply(fs1,.(camp,OrderExtId,aud),summarise,imps=sum(imps,na.rm=T))
unique(fs1$aud)
## fs1 = fs1[grepl("Mediamond",fs1$aud) | grepl("Banzai",fs1$aud),]
fs1 = fs1[!fs1$aud=="",]
fs <- rbind(fs,fs1)
##gestionale
es <- NULL
es <- rbind(es,read.csv("raw/storicoERP2016.csv",stringsAsFactor=F))
es <- rbind(es,read.csv("raw/storicoERP2017.csv",stringsAsFactor=F))
## es <- es[!grepl("GOOGLE",es$Cliente),]
## es <- es[!grepl("PUBMATIC",es$Cliente),]
## es <- es[!grepl("SPONSORED",es$Formato),]
## es <- es[!grepl("AUDIENCE ADS",es$Formato),]
es[es$Pacchetto=="","Pacchetto"] = es[es$Pacchetto=="","Formato"]
es$date <- as.Date(es$Data.Prenotazione,format="%Y-%m-%d")
es$year = format(es$date,"%y")
es$month <- format(es$date,"%y-%m")
## set <- grepl("DATA PLANNING",es$Pacchetto)
## formL <- c("FloorAd","Half Page","INTERSTITIAL","Intro","Ipad Display","iPhone","Leaderboard","Masthead","Mobile Display","Minisito","Overlayer","Pre-Roll Video","PromoBox","Rectangle","Rectangle Exp-Video","Skin","Splash Page","SPLASH PAGE","Strip")
## formL <- c("Masthead","Pre-Roll Video","Rectangle","Skin")
## es <- es[es$Formato %in% formL,]
##join
fes = merge(fs,es,by.x="OrderExtId",by.y="Numero.Contratto",all.x=T)
ld = ddply(fes,.(OrderExtId,camp,Pacchetto,year),summarise,rev=sum(Valore.Netto,na.rm=T))
write.csv(ld,"out/audienceOrder.csv")

esL = unique(fs[!grepl("IT_",fs$camp),"OrderExtId"])
esT <- es[es$Numero.Contratto %in% esL ,]
sum(esT[,"Valore.Netto"])
sum(esT[,"Valore.Netto"])
table(esT$Pacchetto)
sum(es[,"Valore.Netto"])
sum(es[grepl("DATA PLANNING",es$Pacchetto),"Valore.Netto"])


es[es['Numero.Contratto'] == 1007194,]
sum(es[es['Numero.Contratto'] == 1007194,'Valore.Netto'])
