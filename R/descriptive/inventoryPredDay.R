#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')
require('forecast')
library(splines)
library(gtools)
library('psd')
library('RSEIS')
##install.packages('sqldf')
library(sqldf)
comprob <- .98
##install.packages("forecastHybrid")
library(forecastHybrid)



timeSeq  <- read.csv("out/invVideoTimeSeq.csv",row.names=1)
timeSeq <- timeSeq[,!colnames(timeSeq) %in% "brand"]
## timeSeqTv <- read.csv("out/invTvTimeSeq.csv")
## tvSeq <- as.data.frame.matrix(xtabs("individuals ~ date + ch",timeSeqTv))
tvSeq  <- read.csv("out/invVideoTimeSeqTel.csv",row.names=1)
webSeq <- timeSeq[,colnames(tvSeq)]
i <- colnames(timeSeq)[1]
corM <- NULL
dayweekP <- NULL
weekP1 <- NULL
for(i in colnames(tvSeq)){
    seq1 <- data.frame(date=rownames(tvSeq),tv=as.numeric(tvSeq[,i])/1000)
    seq2 <- data.frame(date=rownames(webSeq),web=as.numeric(webSeq[,i])/1000000)
    seqA <- merge(seq1,seq2,all=F)
    seqA$date <- as.Date(seqA$date)
    seqA$day <- weekdays(seqA$date)
    seqA[is.na(seqA)] <- 0
    seqA$week <- format(seqA$date,"%y-%W")
    seqA$month<- format(seqA$date,"%m")
    webI <- ts(seqA$web/1000000, frequency=7, start=c(9,8))
    tvI <- ts(seqA$tv/1000000, frequency=7, start=c(9,8))
    seqW <- ddply(seqA,.(week),summarise,tv=sum(tv),web=sum(web))
    breaks <- seqW$tv == 0
    palW <- seqW[!breaks,"week"]
    set <- FALSE
    for(j in palW){set <- set | grepl(j,seqA$week)}
    seqD <- ddply(seqA,.(day),summarise,tv=sum(tv),web=sum(web))
    seqD$ch <- i
    seqW$ch <- i
    dayweekP <- rbind(dayweekP,seqD)
    weekP1 <- rbind(weekP1,seqW)
    ## dog <- stl(tvI,"per")
    ## plot(dog)
    
    corM <- rbind(corM,data.frame(
                           name=i,
                           corAll=cor(seqA$web,seqA$tv),
                           corWeek=cor(seqW[!breaks,"tv"],seqW[!breaks,"web"]),
                           ratio=sum(seqA$web)/sum(seqA$tv),
                           dayweek=sum(seqA[set,"tv"]>1)/length(seqA[set,"tv"])*7,
                           meanweektv=mean(seqW$tv),
                           meanweekweb=mean(seqW$web),
                           meantv=mean(seqA$tv),
                           meanweb=mean(seqA$web)) )
}
corM
write.csv(corM,"out/corWebTv.csv")
dayweekP$ratio <- dayweekP$web/dayweekP$tv
dayweekP$ratio[dayweekP$ratio==Inf] <- 0
dayP <- as.data.frame.matrix(xtabs("tv ~ day + ch",dayweekP))
dayP <- dayP/table(seqA$day)
write.csv(dayP,"out/corWebTv1.csv")
weekP1$ratio <- weekP1$web/weekP1$tv
weekP1$ratio[weekP1$ratio==Inf] <- 0
weekP <- as.data.frame.matrix(xtabs("tv ~ week + ch",weekP1))

melted <- weekP1 
melted$tv <-(melted[,c("ch","tv")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$tv 
melted$web <- (melted[,c("ch","web")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$web
melted$ratio <- (melted[,c("ch","ratio")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$ratio
gLabel = c("weekday","percentage",paste("audience media televisiva"),"week")
p <- ggplot(melted,aes(x=week,group=ch)) +
    geom_bar(aes(y=web,color=ch),size=1.5,stat="identity",show.legend=F,alpha=.0) +
    geom_bar(aes(y=tv,fill=week),size=1.5,stat="identity",show.legend=F,alpha=.3) +
    geom_line(aes(y=ratio,color="black"),size=1.5,show.legend=F) +
    ## geom_jitter(alpha=0.5) +
##    scale_fill_manual(values=gCol1) +
    facet_grid(ch ~ . ,scales="free") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file=paste("fig/invTvWeb","WeekW",".jpg",sep=""),plot=p,width=gWidth,height=gHeight)

if(FALSE){
    con <- pipe("xclip -selection clipboard -i", open="w")
    write.table(melted,con,row.names=F,col.names=T,sep=",")
    close(con)
}


melted <- dayweekP
melted$tv <-(melted[,c("ch","tv")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$tv 
melted$web <- (melted[,c("ch","web")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$web
melted$ratio <- (melted[,c("ch","ratio")] %>% group_by(ch) %>% mutate_each(funs(./sum(.))))$ratio

melted$day <- factor(melted$day,levels=c("lunedì","martedì","mercoledì","giovedì","venerdì","sabato","domenica"))
gLabel = c("weekday","percentage",paste("audience media televisiva"),"week")
p <- ggplot(melted,aes(x=day,group=ch)) +
    ##geom_line(size=1.5) +
    geom_line(aes(y=ratio,color="black"),size=.5,show.legend=F) +
    geom_bar(aes(y=web,color=day),size=1.5,stat="identity",show.legend=F,alpha=.0) +
    geom_bar(aes(y=tv,fill=day),size=1.5,stat="identity",show.legend=F,alpha=.3) +
    ## geom_jitter(alpha=0.5) +
    scale_fill_manual(values=gCol1) +
    scale_color_manual(values=gCol1) +
    facet_grid(ch ~ . ,scales="free") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file=paste("fig/invTvWeb","DayW",".jpg",sep=""),plot=p,width=gWidth,height=gHeight)



paliSeq <- read.csv("raw/inventoryPalinsesto2016.csv")
paliSeq$date <- as.Date(paliSeq$date)
paliSeq$day <- weekdays(paliSeq$date)
paliSeq2 <- paliSeq
j <- rownames(dayP)[1]
for(i in colnames(tvSeq)){
    for(j in rownames(dayP)){
        set <- grepl(j,paliSeq$day)
        paliSeq2[set,i] <- paliSeq[set,i]*dayP[j,i]
    }
}
paliSeq2$week <- format(paliSeq2$date,"%W")
predPali <- data.frame(week=0:52)
for(i in colnames(paliSeq2[,-c(1,12,13)]) ){
    predT <- eval(parse(text=paste0("ddply(paliSeq2,.(week),summarise,",i,"=sum(",i,"))")))
    head(tvSeq1)
    predPali <- cbind(predPali,predT[,2])
    print(i)
}
colnames(predPali) <- c("week", colnames(paliSeq2[,-c(1,12,13)]))
tvSeq1 <- tvSeq
tvSeq1$week <- format(as.Date(rownames(tvSeq)),"%W")
weekSeq <- as.numeric(format(as.Date(rownames(tvSeq)),"%W"))
yearSeq <- as.numeric(format(as.Date(rownames(tvSeq)),"%y"))
lastWeek <- weekSeq[length(weekSeq)]
histPali <- data.frame(week=0:lastWeek)
for(i in colnames(tvSeq)){
    set <- yearSeq == 16
    histT <- eval(parse(text=paste0("ddply(tvSeq1[yearSeq==16,],.(week),summarise,",i,"=sum(",i,")/1000000)")))
    histPali <- cbind(histPali,histT[,2])
}
colnames(histPali) <- c("week", colnames(tvSeq))
for(i in 1:lastWeek){
    predPali[i, colnames(tvSeq)] <- histPali[i,-1]
} 


melted <- melt(cbind(date=predPali[,"week"],predPali[,colnames(tvSeq)]*corM$ratio),id="date")
nVar <- length(colnames(tvSeq))
gLabel = c("week","preroll (Mio)",paste("tv generated content"),"section")
p <- ggplot(melted,aes(x=date,y=value,group=(variable))) +
    geom_area(aes(fill=(variable)),position="stack",size=1,alpha=.5) +
    ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    scale_color_manual(values=brewer.pal(nVar,'Spectral')) + 
    scale_fill_manual(values=brewer.pal(nVar,'Spectral')) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

fs <- read.csv("out/inventoryPredictionMonthEts.csv")
fs <- fs[grepl("16",fs$date),]
fs$date <- as.numeric(as.vector(lapply(strsplit(as.character(fs$date),split="-"),'[[',2)))
melted <- melt(cbind(date=predPali[,"week"],predPali[,colnames(tvSeq)]*corM$ratio),id="date")
melted$date <- round((melted$date+1)*12/52)
melted2 <- as.data.frame(fs[,2:4])
colnames(melted2) <- colnames(melted)
melted <- melted[order(melted$date),]
melted2 <- melted2[order(melted2$date),]
melted2$variable <- paste("web",melted2$variable)
gLabel = c("month","preroll (Mio)",paste("tv generated content"),"section")
p <- ggplot(melted,aes(x=date,y=value,group=(variable))) +
    ##geom_rect(aes(xmin=7,xmax=12,ymin=0,ymax=250),fill="red",size=1.5,alpha=.1) +
    annotate("rect",xmin=7,xmax=12,ymin=0,ymax=250 , alpha=0.2, fill="red") +
    geom_bar(aes(fill=(variable)),position="stack",size=1,alpha=.5,stat="identity") +
    geom_line(data=melted2,aes(x=date,y=value,group=(variable),color=(variable)),position="stack",size=1,alpha=.5,stat="identity") +
    ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p





head(paliSeq)
paliSeq2 <- tvSeq>0
paliSeq3 <- as.matrix(tvSeq)/(corM$meanweektv)




fs <- read.csv("raw/inventoryVideoDaily.csv")
fs$Data <- as.Date(fs$Data)
fs$month <- format(fs$Data,"%m")
fs$week <- format(fs$Data,"%W")
fs$weekday <- weekdays(fs$Data)
fs$Invenduto <- as.numeric(gsub('%',"",gsub(",","\\.",fs$Invenduto..)))
fs$Partner <- as.numeric(gsub('[[:punct:]]',"",fs$Partner.su.tot..))
head(fs)


melted <- fs[,c("month","Partner","Invenduto")]
melted <- melt(melted)
gLabel = c("month","percentage",paste("syndacation / invenduto"),"month")
p <- ggplot(melted,aes(x=month,y=value,color=month)) +
    geom_boxplot(size=1.5) +
    geom_jitter(alpha=0.5) +
    scale_color_manual(values=gCol1) +
    facet_grid(variable ~ . ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p

melted <- fs[,c("week","Partner","Invenduto")]
melted <- melt(melted)
gLabel = c("week","percentage",paste("syndacation partner"),"week")
p <- ggplot(melted,aes(x=week,y=value,color=week)) +
    geom_boxplot(size=1.5) +
    geom_jitter(alpha=0.5) +
    facet_grid(variable ~ . ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p

melted <- fs[,c("weekday","Partner","Invenduto")]
melted <- melt(melted)
gLabel = c("weekday","percentage",paste("syndacation partner"),"week")
p <- ggplot(melted,aes(x=weekday,y=value,color=   weekday)) +
    geom_boxplot(size=1.5) +
    geom_jitter(alpha=0.5) +
    scale_color_manual(values=gCol1) +
    facet_grid(variable ~ . ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
