#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media')

##http://www.engage.it/datacenter/audiweb-febbraio/67182
##setwd('..')
source('script/graphEnv.R')

## fs <- read.csv("raw/uniqueDeviceSept.csv")
## fs <- read.csv("raw/browserUniciFeb.csv")

## traffic <- ddply(fs,.(ISP),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficISP.csv")

## traffic <- ddply(fs,.(IpProvincia),summarise,imps=sum(imps,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficProvincia.csv")

## traffic <- ddply(fs,.(IpRegione),summarise,imps=sum(imps,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficRegione.csv")

## traffic <- ddply(fs,.(Area),summarise,imps=sum(imps,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficArea.csv")

## traffic <- ddply(fs,.(BrowserDescription),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficBrowser.csv")

## traffic <- ddply(fs,.(OperativeSystem),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficOS.csv")

## traffic <- ddply(fs,.(IpStato),summarise,imps=sum(imps,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficStato.csv")

## traffic <- ddply(fs,.(DeviceType),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))
## traffic <- traffic[order(-traffic$imps),]
## write.csv(traffic,"out/trafficDevice.csv")

## traffic <- ddply(fs,.(Data),summarise,unique=sum(unique_browsers,na.rm=TRUE),imps=sum(imps,na.rm=TRUE))
## write.csv(traffic,"out/trafficUnique.csv")

traffic <- read.csv("out/trafficUnique.csv")
sum(as.numeric(fs$imps),na.rm=T)/sum(as.numeric(fs$unique_browsers),na.rm=T)

##---------------------------------provider---------------------------------------
nSlice <- 8
traffic <- read.csv("out/trafficISP.csv")
lVar <- "unique"
traffic$imps <- as.numeric(traffic[,lVar])
tot <- sum(traffic$imps,na.rm=TRUE)
traffic$name <- as.character(traffic$ISP)
traffic$name <- gsub("SpA","",traffic$name)
traffic$name <- gsub("Italy","",traffic$name)
traffic$name <- gsub("Italia","",traffic$name)
traffic$name <- gsub("DSL","",traffic$name)
traffic$name <- gsub("null","unknown",traffic$name)
##traffic$name <- gsub("Omnitel","",traffic$name)
traffic$name <- gsub("[[:punct:]]","",traffic$name)
traffic$name <- gsub("BV","",traffic$name)

traffic <- ddply(traffic,.(name),summarise,imps=sum(imps))
traffic <- traffic[order(-traffic$imps),]

traffic[grepl("know",traffic$name),]$imps/sum(traffic$imps)

melted <- traffic[1:nSlice,c("name","imps")]
rest <- tot - sum(melted$imps,na.rm=TRUE)
melted <- rbind(melted,c("resto",rest))
##melted[nSlice+2,] <- c("total",tot)
melted$imps <- as.numeric(melted$imps)
melted$percentage <- melted$imps/sum(melted$imps)
melted$name <- factor(melted$name , levels=melted$name )


gLabel = c("",lVar,paste("provider share",lVar),"provider")
pie <- ggplot(melted, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps/1000000),"M")), size=5) +
    geom_text(aes(x=1.6,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = substring(name,first=1,last=16)), size=5) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)/1000000),"M")), size=5) +
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


##---------------------------------browser---------------------------------------
traffic <-  ddply(fs[grepl("Vodafone Omnit",fs$ISP),],.(BrowserDescription),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))

nSlice <- 9
##traffic <- read.csv("out/trafficBrowser.csv")
lVar <- "unique"
lVar <- "imps"
traffic$imps <- as.numeric(traffic[,lVar])
tot <- sum(traffic$imps,na.rm=TRUE)
traffic$name <- as.character(traffic$Browser)
traffic$name <- gsub("[[:punct:]]","",traffic$name)
traffic$name <- gsub("[[:digit:]]","",traffic$name)

traffic <- ddply(traffic,.(name),summarise,imps=sum(imps))
traffic <- traffic[order(-traffic$imps),]

melted <- traffic[1:nSlice,c("name","imps")]
rest <- tot - sum(melted$imps,na.rm=TRUE)
melted <- rbind(melted,c("resto",rest))
##melted[nSlice+2,] <- c("total",tot)
melted$imps <- as.numeric(melted$imps)
melted$percentage <- melted$imps/sum(melted$imps)
melted$name <- factor(melted$name , levels=melted$name )
sum(melted$imps)

gLabel = c("",lVar,paste("provider share",lVar),"browser")
pie <- ggplot(melted, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps/1000000,1),"M")), size=5) +
    geom_text(aes(x=1.6,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = substring(name,first=1,last=16)), size=5) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)/1000000),"M")), size=5) +
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



##---------------------------------device---------------------------------------
head(fs)
traffic <-  ddply(fs[grepl("Vodafone Omni",fs$ISP),],.(DeviceType),summarise,imps=sum(imps,na.rm=TRUE),unique=sum(unique_browsers,na.rm=TRUE))

nSlice <- 9
##traffic <- read.csv("out/trafficDevice.csv")
lVar <- "imps"
lVar <- "unique"
traffic$imps <- as.numeric(traffic[,lVar])
tot <- sum(traffic$imps,na.rm=TRUE)
traffic$name <- as.character(traffic$DeviceType)
traffic$name[grepl("Mobile",traffic$DeviceType)] <- "Mobile"
set <- grepl("Deskt",traffic$name) | grepl("Tablet",traffic$name) |  grepl("Mobile",traffic$name) 
traffic$name[!set] <- "Rest"

traffic <- ddply(traffic,.(name),summarise,imps=sum(imps))
traffic <- traffic[order(-traffic$imps),]

melted <- traffic
##melted[nSlice+2,] <- c("total",tot)
melted$imps <- as.numeric(melted$imps)
melted$percentage <- melted$imps/sum(melted$imps)
melted$name <- factor(melted$name , levels=melted$name )


gLabel = c("",lVar,paste("device share",lVar),"browser")
pie <- ggplot(melted, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=4) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps/1000000),"M")), size=5) +
    geom_text(aes(x=1.6,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = substring(name,first=1,last=16)), size=4) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)/1000000),"M")), size=5) +
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

4982/55996

##---------------------------------format---------------------------------------
cs <- read.csv("raw/formatTypeSept.csv",stringsAsFactor=F)
cs$Size[grepl("APP",cs$Size)] <- "APP"
set <- grepl("RECTANGLE",cs$Size) | grepl("SPOT",cs$Size) | grepl("APP",cs$Size) | grepl("STRIP",cs$Size)
cs$Size[!set] <- "Rest"

melted <- ddply(cs,.(AdvertiserType),summarise,imps=as.numeric(sum(Imps)))
melted$name <- melted$AdvertiserType
melted <- ddply(cs[cs$AdvertiserType=="Paganti",],.(Size),summarise,imps=as.numeric(sum(Imps)))
melted$name <- melted$Size

melted$percentage <- melted$imps/sum(melted$imps)
gLabel = c("",lVar,paste("monetization"),"browser")
pie <- ggplot(melted, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps/1000000),"M")), size=5) +
    geom_text(aes(x=1.5,y = percentage/4 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = substring(name,first=1,last=10)), size=5) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)/1000000),"M")), size=5) +
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


if(FALSE){
setP <- grepl("Vodafone Omnit",fs$ISP)
setB <- grepl("Safari",fs$BrowserDescription)
setDev <- grepl("Mobile",fs$DeviceType)

setF <- grepl("RECTAN",cs$Size) | grepl("SKIN",cs$Size) | grepl("SPOT",cs$Size)
setA <- grepl("APP",cs$Size)
setM <- grepl("Paganti",cs$AdvertiserType)
setD <- grepl("Mobile",cs$DeviceType)

sum(as.numeric(cs[setF,"Imps"]))/sum(as.numeric(cs[,"Imps"]))
sum(fs[setP,"imps"],na.rm=T)/sum(fs[setP,"unique_browsers"],na.rm=T)
sum(as.numeric(cs[setA & setM,"Imps"]),na.rm=T)/sum(as.numeric(cs[setA,"Imps"]),na.rm=T)
sum(as.numeric(cs[setD & setA,"Imps"]),na.rm=T)/sum(as.numeric(cs[setD,"Imps"]),na.rm=T)
sum(as.numeric(cs[setF,"Imps"]),na.rm=T)/sum(as.numeric(cs[,"Imps"]),na.rm=T)

safImps <- sum(fs$imps[setB])
safUnique <- sum(fs$unique_browsers[setB])
sum(as.numeric(fs$unique_browsers))*(safImps/sum(as.numeric(fs$imps)) - safUnique/sum(as.numeric(fs$unique_browsers)))


(5 - 5*.33 - 0.5)*16

sum(as.numeric(fs[setB & setP & setDev,"imps"]),na.rm=T)/sum(as.numeric(fs[setP & setDev,"imps"]),na.rm=T)
sum(as.numeric(fs[setB & setDev,"imps"]),na.rm=T)/sum(as.numeric(fs[setDev,"imps"]),na.rm=T)
sum(as.numeric(fs[setB & setP & setDev,"imps"]),na.rm=T)/34*.70

sum(as.numeric(fs[setB & setP & setDev,"unique_browsers"]),na.rm=T)/sum(as.numeric(fs[setP & setB,"unique_browsers"]),na.rm=T)

(1.8-2)/2

sum(as.numeric(fs[setDev,"imps"]),na.rm=T)/sum(as.numeric(fs[,"imps"]),na.rm=T)



0.4530973*34.34769

sum(fs[grepl("Vodafone Omnit",fs$ISP) & (grepl("Mobile",fs$DeviceType) | grepl("Tablet",fs$DeviceType) ) ,"imps"])/sum(fs[grepl("Vodafone Omnit",fs$ISP) ,"imps"])


}


##---------------------------------pages---------------------------------------
library(wordcloud)

fs <- read.csv("raw/webtrekkPages.csv",sep="\t")
fs$Bounce <- gsub("%","",fs$Bounce)
fs$Bounce <- as.numeric(fs$Bounce)
fs$Page.Impressions <- as.numeric(fs$Page.Impressions)

head(fs)

print("unique")
sum(fs$Browsers..Unique,na.rm=TRUE)/sum(fs$Page.Impressions,na.rm=TRUE)
print("bounce rate")
sum(fs$Bounce*fs$Page.Impressions,na.rm=TRUE)/(sum(fs$Page.Impressions,na.rm=TRUE))


http <- fs[grepl("http://",fs$Pages),]
http$Pages <- gsub("http://","",http$Pages)
http$Pages <- gsub("\\.html","",http$Pages)
http$Pages <- gsub("\\.shtml","",http$Pages)
http$Pages <- gsub("\\?refresh_ce","",http$Pages)
http$Pages <- gsub("www\\.","",http$Pages)
http$Pages <- gsub("\\.it","",http$Pages)
http$Pages <- gsub("\\.com","",http$Pages)
http$Pages <- gsub("\\.net","",http$Pages)
http$Pages <- gsub("[[:digit:]]","",http$Pages)
http$Pages <- gsub("\\.mediaset","",http$Pages)
http$Page.Duration.Avg <- as.character(http$Page.Duration.Avg)
head(http)

##http$Page.Duration.Avg <- format(http$Page.Duration.Avg,"%H:%M:%S")

tree <- strsplit(http$Pages,split="/")
domain <- data.frame(name=sapply(tree, "[[", 1))
domain$imps <- http$Page.Impressions
domain$view <- http$Visits
domain$click <- http$Clicks
hou <- as.numeric(sapply(strsplit(http$Page.Duration.Avg,split=":"), "[", 1))
min <- as.numeric(sapply(strsplit(http$Page.Duration.Avg,split=":"), "[", 2))
sec <- as.numeric(sapply(strsplit(http$Page.Duration.Avg,split=":"), "[", 3))
domain$sec <- hou*3600 + min*60 + sec
domain$bounce <- http$Bounce
domain$imps[domain$imps == NA] <- 0
domain$click[domain$clic == NA] <- 0
domain$imps <- as.numeric(domain$imps)
domain$click <- as.numeric(domain$click)
domain$sec[domain$sec == NA] <- 0
domain$bounce[domain$bounce == NA] <- 0
sum(domain$bounce*domain$imps,na.rm=TRUE)/(sum(domain$imps,na.rm=TRUE))
sum(domain$sec*domain$imps,na.rm=TRUE)/(sum(domain$imps,na.rm=TRUE))

domAgg <- ddply(domain,.(name),summarise,impressions=sum(imps,na.rm=TRUE),durAv=weighted.mean(sec,imps,na.rm=TRUE),bounce=weighted.mean(bounce,imps,na.rm=TRUE),clicks=sum(click,na.rm=TRUE),visits=sum(view,na.rm=TRUE))
domAgg$ctr <- domAgg$clicks/domAgg$impressions
domAgg$visitAv <- domAgg$visits/domAgg$impressions
## svg("fig/Comm",fExt,"Cloud.svg")
wordcloud(domAgg$name, domAgg$impressions, min.freq=cloud_lim,max.words=cloud_max,random.order=FALSE, colors=gCol1)
wordcloud(domAgg$name, domAgg$durAv, min.freq=cloud_lim,max.words=cloud_max,random.order=FALSE, colors=gCol1)
wordcloud(domAgg$name, domAgg$ctr, min.freq=cloud_lim,max.words=cloud_max,random.order=FALSE, colors=gCol1)
wordcloud(domAgg$name, domAgg$visitAv, min.freq=cloud_lim,max.words=cloud_max,random.order=FALSE, colors=gCol1)
## dev.off()

write.csv(domAgg,"out/trafficAv.csv")

fs <- read.csv('raw/WebtrekkTree.csv',stringsAsFactors=FALSE)
colnames(fs) <- as.character(fs[5,])
fs <- fs[-c(1:5),]
fs <- fs[!fs$Pages=='',]

bRate <- fs[,c("Pages","Page Impressions","Exits","Bounce Rate %","Page Duration Avg")]
colnames(bRate) <- c("Pages","imps","exits","bounce","dur")
bRate$imps <- as.numeric(bRate$imps)
bRate$exits <- as.numeric(bRate$exits)
bRate$bounce <- as.numeric(bRate$bounce)
bRate$dur <- as.numeric(bRate$dur)
bRate$Pages <-  gsub("http://", "", bRate$Pages)
bRate$Pages <-  gsub("www.", "", bRate$Pages)
bRate$domain <- do.call(rbind,strsplit(bRate$Pages,split="/") )[,1]
bRate$section <- do.call(rbind,strsplit(bRate$Pages,split="/") )[,2]
comm_prob = 0.96
lFreq = sort(table(bRate$domain), decreasing=TRUE)
lim = quantile(lFreq, probs=comm_prob)
lGood <- names(lFreq[lFreq > lim])
bRate <- bRate[!is.na(match(bRate$domain,lGood)),]
table(bRate$domain)

## bRate[is.na(bRate$bounce),"imps"] <- NA
## bRate[is.na(bRate$dur),"imps"] <- NA
## bRate[is.na(bRate$imps),"bounce"] <- NA
## bRate[is.na(bRate$imps),"dur"] <- NA

sitePerf <- ddply(bRate,c("domain"),summarise,Imps = sum(imps,na.rm=TRUE),Exits = sum(exits,na.rm=TRUE),Bounce = weighted.mean(bounce,imps,na.rm=TRUE),Dur = weighted.mean(dur,imps,na.rm=TRUE))
sitePerf$domain <- gsub("\\.it","",sitePerf$domain)
sitePerf$domain <- gsub("\\.com","",sitePerf$domain)
sitePerf$domain <- gsub("[[:punct:]]"," ",sitePerf$domain)
sitePerf$domain <- gsub("[[:digit:]]","",sitePerf$domain)
sitePerf$domain <- gsub("^mediaset$","sport mediaset",sitePerf$domain)
sitePerf$domain <- gsub("salepepe","sale e pepe",sitePerf$domain)
sitePerf$domain <- gsub("mobile","",sitePerf$domain)
sitePerf$domain <- gsub("tgcom mediaset","tgcom",sitePerf$domain)
sitePerf$domain <- gsub("video mediaset","witty",sitePerf$domain)
sitePerf$domain <- gsub(" meteo","meteo",sitePerf$domain)

write.csv(sitePerf,"out/trafficAvTree.csv")



evDot <- read.csv("raw/impsVolJanFeb.csv")
evDot$Imps <- as.numeric(evDot$Imps)/1000000
evDot$Data <- as.Date(evDot$Data)
evDot$month <- format(as.Date(evDot$Data),"%m")
evDot$week <- paste(format(as.Date(evDot$Data),"%m"),calWeek(evDot$Data),sep="-")
gLabel = c("date","impressions",paste("basin evolution",""),"percentage")
##evDot$Data = as.numeric(evDot$Data)
fLab = unique(evDot$week)
##meltDF$variable=as.numeric(levels(meltDF$variable))[meltDF$variable]
gLabel = c("settimana","impressioni",paste("evoluzione bacino"),"percentuale\ntracciata")
p <- ggplot(evDot,aes(x=Data,y=Imps,group=month,color=month)) +
    geom_boxplot() +
    geom_line() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    ##    scale_x_continuous(breaks = fLab) +
    ##    scale_x_continuous(breaks = 1:10) +
    scale_x_date(labels=date_format("%W"),breaks = date_breaks("week")) +
    stat_smooth(aes(fill="fit"),method=lm,formula=y~poly(x,8),size=1,alpha=.2,show.legend=TRUE,fill=gColor[4]) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
##    scale_x_discrete(labels=fLab) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1,size=10),
        panel.background = element_blank(),
        legend.position=c(.75,.69),
        axis.title.x=element_text(margin=margin(20,0,0,0)),
        text = element_text(size = gFontSize)
    ) +
    scale_fill_manual(values=gCol1)
p
fName <- paste("fig/basinEvolution","","",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)


hist(evDot$Imps, freq=FALSE, xlab="impressions", main="Distribution of impressions", col="lightgreen",breaks=40)##, xlim=c(15,35),  ylim=c(0, .20))
curve(dnorm(x, mean=mean(evDot$Imps), sd=sd(evDot$Imps)), add=TRUE, col="darkblue", lwd=2)
evMonth <- ddply(evDot,.(month),summarise,imps=sum(Imps,na.rm=TRUE))
