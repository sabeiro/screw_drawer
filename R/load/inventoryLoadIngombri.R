#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
library(RCurl)

## fRaw <- getURL('http://services.bluekai.com/Services/WS/audiences?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=p1cKHJ4B1JSZyp2AqTlCs60pUpVDdp%2FDsCljNkvwAR0%3D',ssl.verifypeer=F)
## x = base64("Simple text", TRUE, "raw")
## URL <- 'http://services.bluekai.com/Services/WS/audiences?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=p1cKHJ4B1JSZyp2AqTlCs60pUpVDdp%2FDsCljNkvwAR0%3D'
## html <- getURLContent(URL)


##may
addMay <- c(1,5,3,7,4,2,6,4) #sunday is the first
addMay <- c(5,3,7,4,2,6,4) #sunday is the first
originD <- c("2016-05-01","2016-06-01","2016-07-01","2016-08-01","2016-09-01","2016-10-01","2016-11-01","2016-12-01")

##https://docs.google.com/spreadsheets/d/1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c/edit?pref=2&pli=1#gid=274965455
year <- "2016"
month <- c("05","06","07","08","09","10","11","12")
originD <- c("2016-05-02","2016-06-01","2016-07-01","2016-08-01","2016-09-01","2016-10-01","2016-11-01","2016-12-01")
urlDPre <- "https://docs.google.com/spreadsheets/d/1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c/export?format=tsv&id=1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c&gid="
urlD <-c('274965455','2023380516','2129496430','1058054768','1383792609','1997553984','1415798686','2123836577')

ingombri1 <- data.frame(x=character(),imps=numeric(),week=numeric(),month=character())
ingombriW1 <- data.frame(week=numeric(),imps=numeric(),day=character(),date=as.Date(as.character()))
k <- 8
week <- 1
for(k in 1:length(urlD)){
    print(originD[k])
    fRaw <- getURL(url=paste(urlDPre,urlD[k],sep=""),ssl.verifypeer=F)
    fs <- read.csv(text=fRaw,sep="\t", encoding = "utf-8",stringsAsFactors = FALSE,quote="")
    head(fs,1)
    
    siteTmp <- fs[1,3]
    slotTmp <- fs[1,4]
    for(i in 1:nrow(fs)){
        if(fs[i,3]==""){fs[i,3] <- siteTmp}else{siteTmp <- fs[i,3]}
        if(fs[i,4]==""){fs[i,4] <- slotTmp}else{slotTmp <- fs[i,4]}
    }

    ts <- !fs==""
    ts <- ts[,-c(1:4)]
    ts <- ts[,!sapply(1:ncol(ts),function(i) sum(ts[,i],na.rm=TRUE))<=1]

    typeL <- fs[,c(3,4)]
    if(k>=7){typeL <- fs[,c(2,3)]}
    videoB <- c(min(grep("People Medium Screen",typeL[,1])),max(grep("Skin Home Page",typeL[,1])))
    if(k >=5){
        videoB <- c(min(grep("People Medium Screen",typeL[,1])),min(grep("Skin Home Page",typeL[,1]))+1)
    }
    typeL[,2] <- gsub("[[:alpha:]]","",typeL[,2])
    typeL[,2] <- gsub("[[:punct:]]","",typeL[,2])
    
    videoL <- typeL[c(videoB[1]:videoB[2]),]
    videoL[,2] <- gsub("[[:alpha:]]","",videoL[,2])
    videoL[,3] <- 500000/7
    for(i in 1:nrow(videoL)){
        imps <- videoL[i,2]
        impsN <- strsplit(imps,split="  ")
        impsN <- impsN[[1]][[length(impsN[[1]])]]
        impsN <- as.numeric(gsub(" ","",impsN))/7
        if(is.na(impsN)){next}
        videoL[i,3] <- impsN
    }
    videoT<- ts[c(videoB[1]:videoB[2]),]
    videoT[videoT==TRUE] <- 1
    ingombri <- data.frame(x=colnames(videoT))
    ingombri$imps <- 0
    for(i in 1:ncol(videoT)){
        ingombri$imps[i] <- sum(videoT[,i]*videoL[,3])
    }
    ## ingombri$week <- 0
    ## ingombri$month <- rep(month[k],nrow(ingombri))
    ## for(i in 1:nrow(ingombri)){
    ##     ingombri$week[i] <- week
    ##     if(grepl("dom",ingombri$x[i])){week <- week + 1}
    ## }
    ingombri = ingombri[!ingombri$imps==0,]
    ingombri[,1] <- gsub("[[:alpha:]]","",ingombri[,1])
    ingombri[,1] <- gsub("[[:punct:]]","",ingombri[,1])
    ingombri[,1] <- paste(year,month[k],ingombri[,1],sep="-")
    ingombri1 <- rbind(ingombri1,ingombri)
}

ingombri1$week <- format(as.Date(ingombri1$x),"%W")
ingombriW <- ddply(ingombri1,.(week),summarise,imps=sum(imps,na.rm=TRUE),day=head(x,1),month=head(month,1))
ingombriW <- ingombriW[,c("day","imps")]
colnames(ingombriW) = c("date","imps")
write.csv(ingombriW,paste("raw/ingombri",year,".csv",sep=""))


