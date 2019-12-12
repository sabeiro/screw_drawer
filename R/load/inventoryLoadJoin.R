#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')


##---------------------------graph----------------------------
## ds <- read.csv("raw/inventoryVideoDaily.csv")
## colnames(filterDat) <- colnames(ds)
## ds <- rbind(filterDat,ds)
##write.csv(ds,"raw/inventoryVideoDaily.csv",row.names=F)
ws <- read.csv("raw/inventoryVideoWeekly.csv")
ws$Data <- as.Date(ws$Data)
ws$imps <- as.numeric(gsub("[[:punct:]]","",ws$Totale.inventory))
ws$Totale.inventory <- as.numeric(gsub("[[:punct:]]","",ws$Totale.inventory))
ws$Totale.partner <- as.numeric(gsub("[[:punct:]]","",ws$Totale.partner))
ws$Invenduto <- as.numeric(gsub("[[:punct:]]","",ws$Invenduto))
ws$Paganti <- as.numeric(gsub("[[:punct:]]","",ws$Paganti))
ws$imps <- ws$imps/1000000
##ws <- read.csv("raw/inventoryVideoHist.csv")
##ws$diff = ws$imps - ws$Totale.inventory
##plot(ws$diff,type="l")
##colnames(ws) <- colnames(filterWeek)
##ws <- rbind(filterWeek,ws)
##write.csv(ws,"raw/inventoryVideoWeekly.csv",row.names=F)
wImps <- read.csv("raw/inventoryVideoHist.csv")
##ws <- merge(ws,wImps,by.x="Data",by.y="date",all=T)
##source('script/inventoryIngombriLoad.R')
ingombriW <- read.csv('raw/ingombri2016.csv',stringsAsFactor=FALSE)
ingombriW <- rbind(ingombriW,read.csv('raw/ingombri2017.csv',stringsAsFactor=FALSE))
ingombriW$imps <- ingombriW$imps/1000000
ingombriW$date <- as.Date(ingombriW$date)-1
ingombriW <- ingombriW[!is.na(ingombriW$date),]
ingombriW <- ingombriW[-1,]

melted <- ws[,c("Data","imps")]
melted$group <- "measured"
mSpline <- as.data.frame(spline(x=melted$Data,y=melted$imps))
mSpline$x <- as.Date(mSpline$x,origin="1970-01-01")

model <- lm("imps ~ Data",data=melted)
timeAll <- merge(melted,ingombriW,by.x="Data",by.y="date",all=TRUE)
pred <- predict(model,timeAll)

ps <- read.csv("out/inventoryPredictionMonthEts.csv")
ps$date <- as.Date(ps$date,format="%Y-%m-%d")
ps$date <- as.Date(paste(substring(as.character(ps$date),1,8),"15",sep=""))
ps <- ps[order(ps$variable),]
ps$variable <- factor(ps$variable,levels=ps$variable)
##ps <- ddply(ps,.(date),summarise,imps=sum(imps))
##ps$imps <- ps$imps/30*7
predM <- ddply(ps,.(date),summarise,imps=sum(imps))
ws$month <- format(ws$Data,"%y-%m")
predW <- ddply(ws,.(month),summarise,imps=sum(imps)/30000000*7,date=head(Data,1))
##merge(predM,predW,all=T,by="date")

mPartner <- data.frame(Data=ws[,"Data"],partner=(ws$Totale.inventory-ws$Totale.partner)/1000000,invenduto=(ws$Totale.inventory-ws$Invenduto)/1000000)
today <- data.frame(date=melted[nrow(melted),"Data"],imps=melted[nrow(melted),"imps"])

ss <- read.csv("raw/inventoryVideoSticky.csv")
ss$date <- as.Date(ss$Day)
ss$Requests <- as.numeric(gsub("[[:punct:]]","",ss$Requests))/1000

##gs <- read.csv("raw/inventoryCaricate.csv",stringsAsFactor=F)
gs <- read.csv("raw/storicoERP2016.csv",stringsAsFactor=F)
gs <- rbind(gs,read.csv("raw/storicoERP2017.csv",stringsAsFactor=F))
gs <- gs[gs$Formato=="Pre-Roll Video",]
gs$date <- as.Date(gs$Data.Prenotazione)
gs$week <- format(gs$date,format="%y-%W")
gs$month <- format(gs$date,format="%y-%m")
gsW <- ddply(gs,.(month),summarise,day=head(date,n=1),imps=sum(Quantità.Ordine)/30000000*7,week=head(week,1))
gsW$day <- as.Date(paste(substring(as.character(gsW$day),1,8),"15",sep=""))

## wts <- read.csv("raw/inventoryVideoWebtrekk.csv",sep=",",stringsAsFactor=FALSE)
## wts <- wts[wts$Media.Player.Actions=="play",]
## wts$Qty.Media.Player.Actions <- wts$Qty.Media.Player.Actions/1000000
## wts$Media.Player.Actions[grepl("roll",wts$Media.Player.Actions)] <- "roll"
wtp <- read.csv("raw/inventoryVideoWebtrekkPreroll.csv",sep=",",stringsAsFactor=FALSE)
head(wtp)
wtp$Days <- as.Date(wtp$Days)
wtp$week <- format(wtp$Days,format="%y-%W")
wtp <- wtp[grepl("start",wtp$Media.Player.Actions),]
##wtp <- wtp[grepl("start",wtp$ Media.Player.Actions),]
wtpW <- ddply(wtp,.(week),summarise,Days=head(Days,n=1),imps=sum(Qty.Media.Player.Actions))##,play=sum(
wtpW$imps <- wtpW$imps/1000000


wts <- read.csv("raw/inventoryVideoWebtrekk.csv",sep=",",stringsAsFactor=FALSE)
wts$Bounce.Rate.. <- as.numeric(gsub("%","",wts$Bounce.Rate..))
##plot(wts$Bounce.Rate..)
wts <- wts[wts$Media.Livello.04...Tipologia=="Sum",]
##wts <- merge(wts,wts1,by="Days")
wts$Days <- as.Date(wts$Days)
wts$week <- format(wts$Days+1,format="%y-%W")
wts$Media.Views <- wts$Media.Views/1000000
wts$time <- 0
timeStr <- strsplit(wts$Avg.Run.Time,split=":")
i <- labels(timeStr)[1]
for(i in as.numeric(labels(timeStr))){wts$time[i] <- as.numeric(try(timeStr[[i]][2]))*60 + as.numeric(try(timeStr[[i]][3]))}
wts$time[is.na(wts$time)] <- 0
##plot(wts$time,type="l")
wtsW <- ddply(wts,.(week),summarise,Days=head(Days,n=1),imps=sum(Media.Views))##,play=sum(Qty.Media.Player.Actions))




gLabel = c("data","impression (Mio/settimana)",paste("evoluzione bacino video"),"sequenza","canale")
p <- ggplot(melted,aes(x=Data,y=imps))+
    ##geom_ribbon(data=mPartner,aes(x=Data,y=tot,ymax=tot,ymin=invenduto,fill="partner/invenduto")) +
    geom_bar(data=gsW,aes(x=day,y=imps,color="caricato"),stat="identity",size=1,alpha=.0) +
    geom_line(data=mPartner,aes(x=Data,y=invenduto,fill="venduto",color="venduto")) +
    geom_line(data=mPartner,aes(x=Data,y=partner,color="partner",fill="- partner")) +
    geom_point(data=today,aes(x=date,y=imps,color="oggi"),size=15,show.legend=FALSE,color=gCol1[1],fill=NA,stroke=1.5,shape=21) + 
    geom_point(size=2,color=gCol1[3]) +
    geom_bar(data=ps,aes(x=date,y=imps,fill=variable),stat="identity",position="stack",size=1,alpha=.2,show.legend=FALSE) +
    ##geom_line(data=mSpline,aes(x=x,y=y,color="inventory"),size=1) +
    geom_line(aes(color="inventory"),size=1) +
    ##    geom_smooth(data=melted,method = "glm",family = gaussian(link="log"),aes(colour = "Exponential")) +
    stat_smooth(aes(color="regressione 1",fill="regressione 1"),method=lm,formula=y~poly(x,8),size=1,alpha=.1,show.legend=FALSE,linetype="solid") +
    stat_smooth(aes(color="regressione 2",fill="regressione 2"),method=lm,formula=y~splines::bs(x, 6),size=0,alpha=.1,show.legend=FALSE,linetype="solid") +
    geom_line(data=ingombriW,aes(x=date,y=imps,color="ingombri"),size=1) +
    geom_line(data=wtsW,aes(x=Days,y=imps,color="player wt"),size=1) +
    geom_line(data=wtpW,aes(x=Days,y=imps,color="preroll wt"),size=1) +
    geom_point(data=ingombriW,aes(x=date,y=imps,color="ingombri"),size=2) +
    theme(
        panel.background = element_blank(),
        legend.position="bottom"
    ) +
    ##guides(colour=guide_legend(title=""),fill="none") +
    scale_color_manual(values=gCol1[seq(3,length(gCol1),2)]) + 
    scale_fill_manual(values=gCol1[seq(13,length(gCol1),1)]) + 
    scale_x_date(limits=as.Date(c("2016-01-10",melted[nrow(melted),"Data"])),labels=date_format("%y-%m")) + ## date_breaks = "1 week", date_labels = "%W") +
    scale_y_continuous(breaks=seq(0,70,10)) + 
    coord_cartesian(ylim=c(0,75))  + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p
ggsave(file="intertino/fig/invHistDetail.jpg",plot=p,width=gWidth,height=gHeight)



gLabel = c("data","impression (Mio/settimana)",paste("evoluzione bacino video"),"sequenza","canale")
head(ws)

ws$Invenduto.. <- ws$Invenduto/ws$Totale.inventory
ws$Partner.su.tot.. <- ws$Totale.partner/ws$Totale.inventory
mPerc <- melt(ws[,c("Data","Invenduto..","Partner.su.tot..")],id="Data")
head(mPerc)

gLabel = c("data","percentuale",paste("evoluzione invenduto/partner"),"sequenza","tipo")
p <- ggplot(mPerc,aes(x=Data,y=value,fill=variable))+
    geom_bar(stat="identity",position="dodge",size=1,alpha=1) +
    scale_fill_manual(values=gCol1[seq(3,length(gCol1),1)]) + 
    scale_x_date(limits=as.Date(c("2015-12-01",melted[nrow(melted),"Data"])) ) +
    scale_y_continuous(limits=c(0,0.25))+
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p



ss <- read.csv("raw/inventorySticky.csv")
ss$date <- as.Date(ss$Day)
head(ss)
ss$Requests <- as.numeric(gsub("[[:punct:]]","",ss$Requests))
ss$Auctions <- as.numeric(gsub("[[:punct:]]","",ss$Auctions))
ss$Win.rate <- as.numeric(gsub("[[:punct:]]","",ss$Win.rate))
ss$Impressions <- as.numeric(gsub("[[:punct:]]","",ss$Impressions))
ss$win = ss$Impressions/ss$Requests
ss$wDay = weekdays(ss$date)
ss$wDay <- factor(ss$wDay,levels=c("lunedì","martedì","mercoledì","giovedì","venerdì","sabato","domenica"))


p <- ggplot(ss,aes(x=wDay,y=win,color=wDay)) +
    geom_boxplot() + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p

gLabel = c("data","percentuale",paste("evoluzione invenduto/partner"),"sequenza","tipo")
p <- ggplot(ss,aes(x=wDay,y=Impressions,color=wDay)) +
    geom_boxplot() +
    geom_jitter(height = 0,alpha=0.3) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p
