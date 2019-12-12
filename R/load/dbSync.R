#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library('RMySQL')
source('credenza/intertino.R')
con <- dbConnect(MySQL(),user=db_usr,password=db_pass,dbname=db_db,host=db_host)
on.exit(dbDisconnect(con))

ws <- read.csv("raw/inventoryVideoWeekly.csv")
ws$Data <- as.Date(ws$Data)
ws$Data <- ws$Data - 3
ws$imps <- as.numeric(gsub("[[:punct:]]","",ws$Totale.inventory))/1000000
ws$Totale.inventory <- as.numeric(gsub("[[:punct:]]","",ws$Totale.inventory))/1000000
ws$Totale.partner <- as.numeric(gsub("[[:punct:]]","",ws$Totale.partner))/1000000
ws$Invenduto <- as.numeric(gsub("[[:punct:]]","",ws$Invenduto))/1000000
ws$Paganti <- as.numeric(gsub("[[:punct:]]","",ws$Paganti))/1000000
#wImps <- read.csv("raw/inventoryVideoHist.csv")
dbGetQuery(con,"DROP TABLE inventory_video_dot")
dbWriteTable(con,"inventory_video_dot",ws)

ps <- read.csv("out/inventoryPredictionMonthEts.csv")
ps$date <- as.Date(ps$date,format="%Y-%m-%d")
ps$date <- as.Date(paste(substring(as.character(ps$date),1,8),"15",sep=""))
ps <- ps[order(ps$variable),]
ps$variable <- factor(ps$variable,levels=ps$variable)
predM <- ddply(ps,.(date),summarise,imps=sum(imps))
dbGetQuery(con,"DROP TABLE inventory_prediction")
dbWriteTable(con,"inventory_prediction",ddply(ps,.(date,month),summarise,imps=sum(imps)))#*0.23) )

gs <- NULL
gs <- rbind(gs,read.csv("raw/storicoERP2016.csv",stringsAsFactor=F))
gs <- rbind(gs,read.csv("raw/storicoERP2017.csv",stringsAsFactor=F))
gs <- gs[gs$Formato=="Pre-Roll Video" | gs$Formato=="Spot Video" ,]
gs$date <- as.Date(gs$Data.Prenotazione)
gs$week <- format(gs$date,format="%y-%W")
gs$month <- format(gs$date,format="%y-%m")
gs$Quantita.Ordine = as.numeric(gs$Quantita.Ordine)
gsW <- ddply(gs,.(month),summarise,day=head(date,n=1),imps=sum(Quantita.Ordine)/1000000*7/30,week=head(week,1))
gsW$day <- as.Date(paste(substring(as.character(gsW$day),1,8),"15",sep=""))
## dbGetQuery(con,"DROP TABLE inventory_erp")
## dbWriteTable(con,"inventory_erp",gs)
dbGetQuery(con,"DROP TABLE inventory_erp_weekly")
dbWriteTable(con,"inventory_erp_weekly",gsW)

wtp <- read.csv("raw/inventoryVideoWebtrekkPreroll.csv",sep=",",stringsAsFactor=FALSE)
wtp <- rbind(wtp,read.csv("raw/inventoryVideoWebtrekkPreroll2017.csv",sep=",",stringsAsFactor=FALSE))
wtp$Days <- as.Date(wtp$Days)
wtp$week <- format(wtp$Days,format="%y-%W")
wtp = wtp[order(wtp$Days),]
wtd = data.frame(date=unique(wtp$Days))
wtd$alive = wtp[wtp$Media.Player.Actions == "alive","Qty.Media.Player.Actions"]
wtd$play = wtp[wtp$Media.Player.Actions == "play","Qty.Media.Player.Actions"]
wtd$seek = wtp[wtp$Media.Player.Actions == "seek","Qty.Media.Player.Actions"]
wtd = merge(wtd,ddply(wtp[grepl("roll",wtp$Media.Player.Actions),],.(Days),summarise,preroll=sum(Qty.Media.Player.Actions)),by.x="date",by.y="Days",all.x=T)
wtd = merge(wtd,ddply(wtp[grepl("embed",wtp$Media.Player.Actions),],.(Days),summarise,embed=sum(Qty.Media.Player.Actions)),by.x="date",by.y="Days",all.x=T)
wtd$week <- format(wtd$date,format="%y-%W")
wtd$weekD <- weekdays(wtd$date)
dbGetQuery(con,"DROP TABLE inventory_webtrekk_preroll")
dbWriteTable(con,"inventory_webtrekk_preroll",wtd)



wtp <- wtp[grepl("start",wtp$Media.Player.Actions),]
##wtp <- wtp[grepl("start",wtp$ Media.Player.Actions),]
wtpW <- ddply(wtp,.(week),summarise,Days=head(Days+3,n=1),imps=sum(Qty.Media.Player.Actions))##,play=sum(
wts <- read.csv("raw/inventoryVideoWebtrekk.csv",sep=",",stringsAsFactor=FALSE)
wts <- rbind(wts,read.csv("raw/inventoryVideoWebtrekk2017.csv",sep=",",stringsAsFactor=FALSE))
wts = wts[order(wts$Days),]
wts$Bounce.Rate.. <- as.numeric(gsub("%","",wts$Bounce.Rate..))
##plot(wts$Bounce.Rate..)
wts <- wts[wts$Media.Livello.04...Tipologia=="Sum",]
##wts <- merge(wts,wts1,by="Days")
wts$Days <- as.Date(wts$Days)
wts$week <- format(wts$Days,format="%y-%W")
wts$Media.Views <- wts$Media.Views/1000000
wts$time <- 0
timeStr <- strsplit(wts$Avg.Run.Time,split=":")
i <- labels(timeStr)[1]
for(i in as.numeric(labels(timeStr))){wts$time[i] <- as.numeric(try(timeStr[[i]][2]))*60 + as.numeric(try(timeStr[[i]][3]))}
wts$time[is.na(wts$time)] <- 0
##plot(wts$time,type="l")
wtsW <- ddply(wts,.(week),summarise,Days=head(Days+3,n=1),imps=sum(Media.Views))##,play=sum(Qty.Media.Player.Actions))
dbGetQuery(con,"DROP TABLE inventory_webtrekk")
dbWriteTable(con,"inventory_webtrekk",wts)
dbGetQuery(con,"DROP TABLE inventory_webtrekk_weekly")
dbWriteTable(con,"inventory_webtrekk_weekly",wtsW)


dbGetQuery(con,"DROP TABLE inventory_sticky")
dbWriteTable(con,"inventory_sticky",ss)


dbGetQuery(con,"DROP TABLE inventory_marker")
marker <- read.csv("raw/inventoryMarker.csv",stringsAsFactor=F)
dbWriteTable(con,"inventory_marker",marker)

fs <- read.csv("raw/pricePerClient.csv")
dbGetQuery(con,"DROP TABLE price_client")
dbWriteTable(con,"price_client",fs)

fs <- read.csv("raw/pricePerClientBanzai.csv",stringsAsFactor=F)
fs = fs[fs$Anno.fiscale %in% c(2015,2016),]
str(fs)
fs$Nome.prodotto = fs$Nome.prodotto %>% gsub("INTRO VIDEO","INTRO-VIDEO",.)
fs$Nome.prodotto = fs$Nome.prodotto %>% gsub("^(\\S+)_(\\S+)\\s(.*)","\\2",.)
fs$Nome.prodotto = fs$Nome.prodotto %>% tryTolower
gs = ddply(fs,.(Nome.cliente,Nome.prodotto),summarise,imps=sum(Impression.Pianificate,na.rm=T),price=sum(Valore.offerta,na.rm=T))
gs$cpm = gs$price/gs$imps*1000
colnames(gs) <- c("cliente","prodotto","imps","price","cpm")
dbGetQuery(con,"DROP TABLE price_client_banzai")
dbWriteTable(con,"price_client_banzai",gs)
## remove leading gsub('^\\s+|\\s+$', '', .) | or
## space \\s non space \\S, \\s+ spaces, \\S+ non spaces


fs <- read.csv("raw/pricePerClientYahoo.csv",stringsAsFactor=F)
fs$cpm = fs$Advertiser.Spending/fs$Impressions*1000
head(fs)
colnames(fs) = c("cliente","formato","imps","spent","cpm")
dbGetQuery(con,"DROP TABLE price_client_yahoo")
dbWriteTable(con,"price_client_yahoo",fs)


fs <- read.csv("raw/audSourceEv.csv")
dbGetQuery(con,"DROP TABLE audience_usage")
dbWriteTable(con,"audience_usage",fs)



## sql <- sprintf("insert into networks (species_id, name, data_source, description, created_at) values (%d, '%s', '%s', '%s', NOW());",species.id, network.name, data.source, description)
## rs <- dbSendQuery(con, sql)
## dbClearResult(rs)
## id <- dbGetQuery(con, "select last_insert_id();")[1,1]
## dbRemoveTable(con,"inventory_video_dot")
## dbBegin(con)
## dbGetQuery(con, "UPDATE df SET id = id * 10")
## dbGetQuery(con, "SELECT id FROM df")
## dbRollback(con)
## dbGetQuery(con, "SELECT id FROM df")
## dbRemoveTable(con, "df")
## dbDisconnect(con)

rs <- dbSendQuery(con, "select * from inventory_ingombri limit 10;")
data <- fetch(rs, n=10)
huh <- dbHasCompleted(rs)
dbClearResult(rs)


fs <- read.csv("raw/inventoryVideoShinyMonth.csv",stringsAsFactor=F)
dbGetQuery(con,"DROP TABLE inventory_shiny_month")
dbWriteTable(con,"inventory_shiny_month",fs)

fs <- read.csv("raw/inventoryVideoShinyWeek.csv",stringsAsFactor=F)
## fs$date <- fs$date %>% gsub("-.*$","",.)
## fs$date <- as.Date(fs$date,format="%d/%m/%Y") + 3
## fs$imps = as.numeric(gsub("\\.","",fs$imps))
## fs <- fs[order(fs$date),]
dbGetQuery(con,"DROP TABLE inventory_shiny_week")
dbWriteTable(con,"inventory_shiny_week",fs)


fs <- read.csv("out/invVideoTimeSeqTot.csv",stringsAsFactor=F)
colnames(fs) = colnames(fs) %>% gsub("\\.","/",.)
dbGetQuery(con,"DROP TABLE inventory_daily_sect")
dbWriteTable(con,"inventory_daily_sect",fs)

## fs <- read.csv("raw/tmp.csv",stringsAsFactor=F)
## fs$date = as.Date(as.character(fs$date),format="%Y%m%d")
## fs[,2:ncol(fs)] = fs[,2:ncol(fs)]*1000
## dbGetQuery(con,"DROP TABLE inventory_tv_audience")
## dbWriteTable(con,"inventory_tv_audience",fs)



dbDisconnect(con)

