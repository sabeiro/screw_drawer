#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('/home/sabeiro/lav/media/')

source('src/R/graphEnv.R')

##data size section

vSection <- read.csv("raw/inventoryVideoSection.csv",stringsAsFactor=F)
isPartner = TRUE
isPartner = FALSE
if(isPartner){fileL <- c('log/inventoryVideoPartner2017.csv','log/inventoryVideoPartner2016.csv','log/inventoryVideoPartner2015.csv','log/inventoryVideoPartner2014.csv','log/inventoryVideoPartner2013.csv')}
if(!isPartner){fileL <- c('log/inventoryVideo2017.csv','log/inventoryVideo2016.csv','log/inventoryVideo2015.csv','log/inventoryVideo2014.csv','log/inventoryVideo2013.csv','log/inventoryVideo2012.csv')}

aggrAll <- NULL
f <- fileL[1]
for(f in fileL){
    print(f)
    fs <- read.csv(f,encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##
    fs$Imps <- as.numeric(gsub("[[:punct:]]","",fs$Imps))
    fs$Click <- as.numeric(gsub("[[:punct:]]","",fs$Click))
    sectId <-  grepl('XAXIS',fs$Section) | grepl('RTB',fs$Section) | grepl('PUBMATIC',fs$Section) | grepl('STICKY',fs$Section)
    fs <- fs[!sectId,]##rem double count passback
    fs$Data <- as.Date(fs$Data)
    fs$cluster <- "rest"
    for(i in 1:length(vSection$canale)){##assign ch
        fs[grepl(vSection[i,"canale"],fs$Section),"cluster"] <- vSection[i,"cluster"]
    }
    aggr16 <- ddply(fs[,c("Data","cluster","Imps","Click")],.(Data,cluster),summarise,imps = sum(Imps,na.rm=TRUE),click = sum(Click,na.rm=TRUE))
    aggrAll <- rbind(aggrAll,aggr16)
    sectC <- ddply(fs[fs$cluster=="sport",],.(Section),summarise,imps=sum(Imps,na.rm=T))
    sectC[order(sectC$imps),]
}
tabAll <- xtabs(imps~Data+cluster,data=aggrAll)
##write.csv(tabAll,"out/invVideoTimeSeqPartner.csv")
if(isPartner){write.csv(tabAll,"out/invVideoTimeSeqPartner.csv",row.names=T)}
if(!isPartner){write.csv(tabAll,"out/invVideoTimeSeq.csv",row.names=T)}
aggrAll$week <- format(aggrAll$Data,format="%y-%W")
aggrW <- ddply(aggrAll,.(week),summarise,imps=sum(imps),date=max(Data))
write.csv(aggrW,"raw/inventoryVideoHist.csv")
tail(aggrAll)


timeSeq  <- read.table("out/invVideoTimeSeq.csv",row.names=1,header=TRUE,sep=",")
timeSeqPartner  <- read.table("out/invVideoTimeSeqPartner.csv",row.names=1,header=TRUE,sep=",")
timeSeqBanzai  <- read.table("raw/inventoryVideoBanzai.csv",row.names=2,header=TRUE,sep=",")
rownames(timeSeqBanzai) <- as.Date(rownames(timeSeqBanzai),format="%m/%d/%y")
## sum(sapply(timeSeq, as.numeric))
## sum(sapply(timeSeqPartner, as.numeric))
if(TRUE){##substract partners
    timeSeqPartner[is.na(timeSeqPartner)] <- 0
    syndI <- match(rownames(timeSeq),rownames(timeSeqPartner))
    partner <- data.frame(imps=rowSums(timeSeqPartner[syndI[!is.na(syndI)],]))
    timeSeq[!is.na(syndI),] <- timeSeq[!is.na(syndI),] - timeSeqPartner[syndI[!is.na(syndI)],]
    timeSeq$partner <- 0
    timeSeq[!is.na(syndI),"partner"] <- partner$imps
}
syndI <- match(rownames(timeSeq),rownames(timeSeqBanzai))
timeSeq[,"banzai"] <- NA
timeSeq[!is.na(syndI),"banzai"] <- timeSeqBanzai$Total.impressions
write.csv(timeSeq,"out/invVideoTimeSeqTot.csv",row.names=T)



##write.csv(unique(c(sel16$Section,sel15$Section,sel14$Section,sel13$Section,sel12$Section)),"out/inventoryVideoSection.csv")




vSection <- read.csv("raw/inventoryVideoSection2.csv")
vSection$canale <- gsub("[[:digit:]]","",vSection$canale)
vSection$canale <- gsub("I$","",vSection$canale)
vSection$canale <- gsub("II$","",vSection$canale)
vSection$canale <- gsub("III$","",vSection$canale)
vSection$canale <- gsub("IV$","",vSection$canale)
vSection$canale <- gsub("V$","",vSection$canale)
vSection$canale <- gsub("VI$","",vSection$canale)
vSection$canale <- gsub("_$","",vSection$canale)


vAgg <- ddply(vSection,.(canale),summarise,imps=sum(imps))
write.csv(vAgg[order(-vAgg$imps),],"raw/inventoryVideoSection3.csv")


vSection <- read.csv("raw/inventoryVideoSection.csv",stringsAsFactor=F)
fList <- list.files(path="raw/")
fMeasure <- fList[grep("tel",fList)]
k <- 5
fs <- NULL
for(k in 1:length(fMeasure)){
    fName <- paste('raw/',fMeasure[k],sep="")
    if(grepl("Palinsesto",fName)){next;}
    if(grepl("AmiciCol",fName)){next;}
    print(fName)
    fs1 <- read.csv(fName,stringsAsFactors=FALSE)
    if(!any(grepl("Description",colnames(fs1)))) {fs1$Description <- fName}
    fs1 <- fs1[,c("Date","Description","Total.Individuals")]
    fs1[,1] <- as.Date(gsub('[[:alpha:]]',"",fs1[,1]),format="%d/%m/%Y")
    fs1[,2] <- tryTolower(gsub("[[:punct:]]","",fs1[,2]))
    fs1[,3] <- as.numeric(gsub("[[:punct:]]","",fs1[,3]))
    head(fs1)
    for(i in 1:nrow(vSection)){fs1[grepl(vSection$canale[i],fs1$Description),"cluster"] <- vSection$cluster[i]}
    fs <- rbind(fs,fs1[,c(1,3,4)])
}
str(fs)
colnames(fs) <- c("date","individuals","ch")
write.csv(fs,"out/invTvTimeSeq.csv",row.names=F)
