#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
##install.packages(c('textcat','svglite'))
source('src/R/graphEnv.R')
library('svglite')
require(stats)
require(dplyr)
library(grid)
library(sqldf)
library(rjson)

if(FALSE){
    fs <- read.csv('raw/audienceNielsen.csv',stringsAsFactor=FALSE)
    fMap <- read.csv('raw/audienceNielsenMap.csv',stringsAsFactor=FALSE)
    fs <- fs[,c("Campaign.Name","Demo.Segment","Computer","Mobile","Digital..C.M.")]
    fs <- melt(fs,id.vars=c("Campaign.Name","Demo.Segment")) 
    colnames(fs) <- c("Campaign.Name","Demo.Segment","Platform","unique")
    fs$aud <- fs$Campaign.Name
    unique(fs$aud)
    unique(fs$Campaign.Name)
    
    fs$source <- "interest"
    for(i in 1:nrow(fMap)){
        fs[fs$Campaign.Name == fMap$name1[i],"aud"] <- fMap$name2[i]
        fs[fs$Campaign.Name == fMap$name1[i],"source"] <- fMap$group[i]
    }
    fs <- fs[!grepl("Total",fs$Demo.Segment),]
    fs$seg <- fs$aud %>% sub("pub ","",.) %>% gsub("[[:punct:]]"," ",.) %>% sub(" v","",.) %>% sub(" z","",.)  %>% sub(" e","",.) %>% sub(" 1st","",.) %>% sub(" beha","",.) %>%  sub("BZ   SE ","",.) %>%  sub("BZ   SD ","",.) %>%  sub("BZ   SU ","",.) %>%  sub("Pub ","",.)
    uniT <- fs#ddply(fs,.(aud,seg,Demo.Segment,source),summarise,unique=sum(Total.Digital,na.rm=T))
    write.csv(uniT,paste("out/audComp","Nielsen",".csv",sep=""))
}
if(TRUE){
    ## fs <- read.csv('raw/audCompAll.csv',stringsAsFactor=FALSE)[,c("Campaign.Name","Demo.Segment","Placement","Platform.Device","Unique.Audience")]
    ## fs1 <- read.csv('raw/audCompAll3.csv',stringsAsFactor=FALSE)[,c("Campaign.Name","Demo.Segment","Placement","Platform.Device","Unique.Audience")]
    ## fs1 <- fs1[fs1$Campaign.Name=="post z",]
    ## fs <- rbind(fs,fs1)
    fs <- read.csv('raw/audienceNielsen2.csv',stringsAsFactor=FALSE)[,c("Campaign.Name","Demo.Segment","Placement","Platform.Device","Unique.Audience")]
    fs = fs[fs$Platform.Device %in% c("Computer","Mobile","Digital (C/M)"),]
    fs$Unique.Audience = fs$Unique.Audience %>% gsub(",","",.) %>% as.numeric(.)
    fs$Platform <- fs$Platform.Device
    ## fs$Placement[fs$Placement=="test bk 1 dinamic"] <- "mediamond_plc0001"
    #fs$Platform[fs$Platform=="Digital (C/M)"] <- "Total Digital"    
    ## fs <- fs[fs1$Country=="ITALY",]
    fs <- ddply(fs,.(Campaign.Name,Placement,Demo.Segment,Platform),summarise,unique=sum(Unique.Audience,na.rm=T))
    fMap <- read.csv('raw/audCampListNie.csv',stringsAsFactor=FALSE)
    cMap <- ddply(fMap,.(source,camp),summarise,imps=1)
    fs$source = "rest"
    for(i in 1:nrow(cMap)){fs[fs$Campaign.Name == cMap$camp[i],"source"] <- cMap$source[i]}
    cMap <- ddply(fMap,.(source,pc,camp),summarise,name=head(name,1))
    fs$aud = "rest"
    for(i in 1:nrow(cMap)){
        #set <- fs$Placement == cMap$pc[i] & fs$source == cMap$source[i]
        set <- fs$Placement == cMap$pc[i] & fs$Campaign.Name == cMap$camp[i]
        fs[set,"aud"] <- cMap$name[i]
    }
    table(fs$aud)
    fs$aud <- gsub("pub ","",fs$aud) %>% gsub("Pub ","",.)
    fs$source[grepl("beha",fs$aud)] = "zalando beha"
    fs1 <- read.csv('raw/audCompBanzai.csv',stringsAsFactor=FALSE)
    fs1 <- ddply(fs1,.(Campaign.Name,Placement,Demo.Segment,Platform),summarise,unique=sum(Unique.Audience,na.rm=T))
    ## fs1 <- fs1[fs1$Country=="ITALY",]
    fs1$aud <- fs1$Placement
    fs1$source <- "banzai"
    fs1$aud <- fs1$aud %>% gsub("BZ - ","",.) %>% gsub("ALL","",.) %>%  gsub("SD","F",.) %>%  gsub("SU","M",.) %>% gsub("SE ","",.) %>% gsub("\\_","",.)
    fs <- rbind(fs,fs1)
    fs <- fs[!grepl("Total",fs$Demo.Segment),]
    ## fs <- fs[!(fs$Site=="All"),]
    fs <- fs[!fs$Placement=="",]
    ##
    fs$seg <- fs$aud %>% sub("pub ","",.) %>% gsub("[[:punct:]]"," ",.) %>% sub(" v","",.) %>% sub(" z","",.)  %>% sub(" e","",.) %>% sub(" 1st","",.) %>% sub(" beha","",.) %>%  sub("BZ   SE ","",.) %>%  sub("BZ   SD ","",.) %>%  sub("BZ   SU ","",.) %>%  sub("Pub ","",.)
    segMap <- read.csv('raw/audCompSegMap.csv',row.names=1)
    segMap <- segMap[!grepl("Total",rownames(segMap)),]
    segMap2 <- read.csv('raw/audCompSegMap2.csv',row.names=1)
    segMap2 <- ifelse(segMap2==1,TRUE,FALSE)
    audL <- colnames(segMap2) %>% gsub("^X","",.) %>% gsub("[[:punct:]]"," ",.)
    segN <- colnames(segMap) %>% gsub("pub ","",.) %>% gsub("X","",.) %>% gsub("[[:punct:]]"," ",.) %>% gsub(" $","",.)
    audM <- audL %>% sub("pub ","",.) %>% gsub("[[:punct:]]"," ",.) %>% sub(" v","",.) %>% sub(" z","",.) %>% sub(" 1st","",.) %>% sub(" beha","",.) %>%  sub("BZ   SE ","",.) %>%  sub("BZ   SD ","",.) %>%  sub("BZ   SU ","",.)
    audSeg <- match(audM,segN)
    fs[grepl("Cultura",fs$aud),"source"] = "first i-t 2"
    fs[grepl("Ecologiaambiente",fs$aud),"source"] = "first i-t 2"
    fs[grepl("Scienza",fs$aud),"source"] = "first i-t 2"
    fs[grepl("Sciure",fs$aud),"source"] = "first i-t 2"
    fs[grepl("Musica",fs$aud),"source"] = "first i-t 2"
    fs[grepl("Dinamici",fs$aud),"source"] = "first i-t 2"
    uniT <- fs
    
    write.csv(uniT,paste("out/audComp","PostVal",".csv",sep=""))
    ab <- read.csv("raw/audCompBenchmarkGraph.csv")
    ab$percent <- ab$percent/100
    ab$target <- ab$target %>% gsub("[[:punct:]]"," ",.)
    ab$device <- ab$device %>% gsub(" Only","",.) %>% gsub("Total ","",.)
}
##----------------------benchmark-----------------------------
## mMap <- melt(read.csv('raw/audCompSegMap.csv'),id.vars="X")
## mMap$variable <- mMap$variable %>% gsub("X","",.) %>% gsub("[[:punct:]]"," ",.) %>% gsub(" $","",.)

## tmp <- sqldf("SELECT * FROM fs AS f LEFT JOIN mMap AS s ON (t.Var2 = s.seg) AND (t.source = s.source)")
devL <- c("Digital","Computer","Mobile")
sourceL <- unique(fs$source)
meltTarget <- NULL
reachTarget <- NULL
sour = "none"
sour <- sourceL[8]
for(sour in c(sourceL[!grepl("i-t",sourceL)],"all","none")){
    inTarget <- NULL
    tReach <- NULL
    d <- devL[1]
    for(d in devL){
        print(d)
        set <- TRUE
        if (sour=="all"){
            set <- grepl(d,uniT$Platform) & (uniT$source %in% c("vodafone s-d","zalando s-d","first s-d"))
        } else if (sour=="none"){
            set <- grepl(d,uniT$Platform) 
        } else {
            set <- grepl(d,uniT$Platform) & uniT$source==sour
        }
        uniD <- uniT[set,]
        inTarget1 <- NULL
        tReach1 <- NULL
        i <- 4
        for(i in 1:length(audL)){
            set2 <- segMap2[,audL[i] == colnames(segMap2) %>% gsub("X","",.) %>% gsub("[[:punct:]]"," ",.)]
            set3 <- FALSE
            for(s in names(set2[set2])){set3 <- set3 | grepl(s,uniD$seg)}
            if(sour=="none"){set3 <- TRUE}
            uniD1 <- uniD[set3,]
            setC <- unique(uniD1[,"seg"])
            sel <- segMap[,audL[i] == segN]
            selT <- rep(sel,length(setC))
            inTarget1[i] <- NA
            if(!any(audL[i] == segN)){next}
            inTarget1[i] <- sum(uniD1[selT,"unique"],na.rm=T)/sum(uniD1[,"unique"],na.rm=T)
            tReach1[i] <- sum(uniD1[,"unique"],na.rm=T)
        }
        inTarget <- rbind(inTarget,inTarget1)
        tReach <- rbind(tReach,tReach1)
    }
    colnames(inTarget) <- audL
    rownames(inTarget) <- devL
    colnames(tReach) <- audL
    rownames(tReach) <- devL
    meltTarget <- rbind(meltTarget,cbind(melt(inTarget),source=sour))
    reachTarget <- rbind(reachTarget,cbind(melt(tReach),source=sour))
}
meltTarget$reach <- reachTarget$value
breakN = unique(c(0,quantile(meltTarget$reach,seq(1,5)/5,na.rm=T)))
meltTarget$accuracy <- as.numeric(cut(meltTarget$reach,breaks=breakN,labels=1:(length(breakN)-1)))

write.csv(meltTarget,"out/audCompInTarget.csv")
##write.csv(as.data.frame.matrix(xtabs("value ~ Var2 + Var1",data=meltTarget)),"out/audCompInTarget.csv",sep=",")
write.csv(fs,"out/audCompAll.csv")
