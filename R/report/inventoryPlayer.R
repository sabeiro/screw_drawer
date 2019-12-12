#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
library(shiny)
library(plotly)


if(FALSE){
    gsO <- ddply(gs,.(Numero.Contratto),summarise,caricato=sum(Quantità.Ordine),erogate=sum(Quantità.Impression.Erogate),data=head(Data.Prenotazione,1),cliente=head(Cliente,1))
    ##    gsD1 <- ddply(
    gsD <- read.csv("raw/inventoryCaricateDot.csv",stringsAsFactor=F) 
    gsE <- ddply(gsD,.(OrderExtId),summarise,goal=head(ImpsGoal,1),imps=sum(Imps),date=head(Data,1),adv=head(AdvertiserName,1))
    gsO <- merge(gsO,gsE,by.x="Numero.Contratto",by.y="OrderExtId",all=T)
    write.csv(gsO,"raw/inventoryCaricatoConfronto.csv")
    gsO$x <- 1:nrow(gsO)
    sum(is.na(gsO$caricato))/nrow(gsO)
    sum(is.na(gsO$imps))/nrow(gsO)
    
    set <- is.na(gsO$caricato) | is.na(gsO$imps)
    gsO <- gsO[!set,]
    
    gsD1 <- read.csv("raw/inventoryCaricateDot1.csv",stringsAsFactor=F)
    gsD1$week <-format(as.Date(gsD1$Data),"%W")
    gsD1 <- ddply(gsD1,.(week),summarise,imps=sum(Imps),goal=sum(ImpsGoal))
    gsD1$imps <- gsD1$imps/sum(as.numeric(gsD1$imps))
    gsD1$goal <- gsD1$goal/sum(as.numeric(gsD1$goal))
    melted <- melt(gsD1,id="week")
    ggplot(melted,aes(x=week,y=value,color=variable,group=variable)) + geom_line() #+ scale_y_continuous(limits = c(0,60))
    
    
    sum(gsO$caricato,na.rm=T)/sum(gsO$goal,na.rm=T)
    sum(gsO$caricato,na.rm=T)/sum(gsO$imps,na.rm=T)
    
    gsE$week <- format(as.Date(gsE$date),"%W")
    melted <- melt(ddply(gsE,.(week),summarise,imps=sum(imps,na.rm=T),goal=sum(goal,na.rm=T)))
    melted <- melted[!is.na(melted$week),]
    ggplot(melted,aes(x=week,y=value/1000000,color=variable,group=variable)) + geom_line() + scale_y_continuous(limits = c(0,60))
    
    melted <- melt(ddply(gsO[,c("x","caricato","erogate","goal","imps")],id="x"))
    ggplot(melted,aes(x=x,y=value,color=variable,group=variable)) + geom_line() + scale_y_continuous(limits = quantile(melted$value,c(0.25, .85),na.rm=T))
    ggplot(melted,aes(x=variable,y=value,color=variable)) + geom_boxplot() + scale_y_continuous(limits = quantile(melted$value,c(0.25, .85),na.rm=T))
    gsM <- as.matrix(gsO[,c("caricato","erogate","goal","imps")])
    gsM[is.na(gsM)] <- 0
    cor(gsM)
    library('corrplot')
    library('rpart')
    corrplot.mixed(cor(gsM),lower="pie",upper="number")
    require(boot)
    fitC = glm(caricato~goal, data=gsO)
    fitE = glm(erogate~imps, data=gsO)
    cv.glm(gsO,fitC)$delta
    summary(gsM)
    gsTree = rpart(erogate ~ .,data=gsO[,c("caricato","erogate","goal","imps")],method="class")
    ##gs <- read.csv("raw/impressionsCaricate1.csv",stringsAsFactor=F)
    gsP <- ddply(gs,.(Pacchetto),summarise,imps=sum(Quantità.Ordine)/1000000)
    ##gsP <- ddply(gs,.(Pacchetto),summarise,imps=sum(Quantità.Impression.Erogate)/1000000)
    gsP$perc <- gsP$imps/sum(gsP$imps)
    gsP <- gsP[order(gsP$imps),]
}

cs <- read.csv("tmp.csv",stringsAsFactor=F)
dateM <- data.frame(Mese=unique(cs$Mese),month=1:12)
cs <- merge(cs,dateM,all=T)
cs$month <- paste(cs$Anno,sprintf("%02d",cs$month),sep="-")
set <- grepl("A M E",cs$Publisher) | grepl("R T I",cs$Publisher) | grepl("WEBTV",cs$Publisher)
cs$Publisher[!set] <- "Terzi"
cs$Publisher[ grepl("WEBTV",cs$Publisher)] <- "R T I"
head(cs)
csM <- ddply(cs,.(month,Publisher),summarise,imps=sum(Imps,na.rm=T))
csMS <- ddply(cs[grepl("SPOT",cs$Size),],.(month,Publisher),summarise,imps=sum(Imps,na.rm=T))
csT <- as.data.frame.matrix(xtabs("imps ~ Publisher + month",data=csM))
csT <- rbind(csT, as.data.frame.matrix(xtabs("imps ~ Publisher + month",data=csMS)))
con <- pipe("xclip -selection clipboard -i", open="w")
##write.table(csT,con,row.names=F,col.names=F,sep=",")
write.table(csT,con,sep=",")
close(con)





melted <- rollQ[!grepl("-stop",rollQ$Media.Player.Actions),]
melted$percentage <- melted$imps/sum(melted$imps)
melted$name <- factor(melted$Media.Player.Actions, levels=melted$Media.Player.Actions)
gLabel = c("",lVar,paste("provider share",lVar),"provider")
pie <- ggplot(melted, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps),"M")), size=5) +
    geom_text(aes(x=1.6,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = substring(name,first=1,last=16)), size=5) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)),"M")), size=5) +
    theme_bw() +
    theme(
        panel.border = element_blank(),
        text = element_text(size = gFontSize),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks=element_blank(),
        legend.position="none",
        plot.background=element_blank(),
        panel.background = element_blank()
    ) +
    coord_polar("y",start=0) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
pie





fs <- read.csv('raw/impressionsPosition.csv',encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##
fs$Data <- as.Date(fs$Data)
head(fs)

ggplot(fs,aes(x=Data,y=Imps/1000000,color=Position,group=Position)) +
    geom_line(position="stack") + 
    ##    geom_line(data=wtsW,aes(x=Days,y=imps,color="player",group=1),size=1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
posS <- ddply(fs,.(Position),summarise,imps=sum(Imps))
posS$perc <- posS$imps/sum(posS$imps)


fs <- read.csv("raw/inventoryVideoFep.csv",stringsAsFactor=F)
fs$Data <- as.Date(fs$Data)
ratio <- data.frame(Data=unique(fs$Data))
ratio$Imps <- fs[fs$Site=="SNACKTV","Imps"]/fs[fs$Site=="FEP","Imps"]
ratio$Site <- "Ratio"
ma <- function(arr, n=16){
    m = n/2
    res = arr
    for(i in m:(length(arr)-m)){
        res[i] = mean(arr[(i-m):(i+m)])
    }
    res
}
ratio <- rbind(ratio,data.frame(Data=ratio$Data,Imps=ma(ratio$Imps),Site="Run av"))
ggplot(ratio,aes(x=Data,y=Imps,color=Site,group=Site)) + geom_line()

