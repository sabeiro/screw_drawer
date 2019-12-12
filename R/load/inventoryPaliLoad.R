#!/usr/bin/env Rscript
setwd('~/lav/media/')
##setwd('..')

source('src/R/graphEnv.R')
library(dplyr)

chL <- c("C5","I1","R4")
paliL <- c("co – c5","co – i1","co – r4")
timeC = data.frame(time=c(000,700,900,1200,1500,1800,2030,2230,2400),len=c(24,2,3,3,3,2.5,2,1.5,1.5))
vSection <- read.csv("raw/inventoryVideoSection.csv",stringsAsFactor=F)
vSection$canale = vSection$canale %>% tryTolower %>% gsub("[[:punct:]]"," ",.)

aggrAll <- NULL
i <- 1
for(i in 1:length(chL)){
    print(chL[i])
    fs <- NULL
    ## fs <- rbind(fs,read.csv(paste("raw/paliSoap2013",chL[i],".csv",sep=""),stringsAsFactor=F))
    ## fs <- rbind(fs,read.csv(paste("raw/paliSoap2014",chL[i],".csv",sep=""),stringsAsFactor=F))
    ## fs <- rbind(fs,read.csv(paste("raw/paliSoap2015",chL[i],".csv",sep=""),stringsAsFactor=F))
    fs <- rbind(fs,read.csv(paste("raw/paliSoap2016",chL[i],".csv",sep=""),stringsAsFactor=F))
    fs <- rbind(fs,read.csv(paste("raw/paliSoap2017",chL[i],".csv",sep=""),stringsAsFactor=F))
    fs = fs[!fs$type=="FILM",]
    fs = fs[!fs$type=="SHOPPING ",]
    fs = fs[!fs$type=="TELEVENDITE",]
    fs$name = fs$name %>% tryTolower %>% gsub("[[:punct:]]"," ",.)
    ##as.Date(strptime(fs$time,format="%d/%m/%Y %H:%M:%S")) %>% head
    dtparts = t(as.data.frame(strsplit(fs$time,' ')))
    row.names(dtparts) = NULL
    fs$date <- as.Date(dtparts[,1],"%d/%m/%Y")
    fs$min <- as.numeric(substring(dtparts[,2],1,5) %>% gsub(":","",.))
    fw <- NULL
    ## fw <- rbind(fw,read.csv("log/paliViews2013.csv",stringsAsFactor=F))
    ## fw <- rbind(fw,read.csv("log/paliViews2014.csv",stringsAsFactor=F))
    ## fw <- rbind(fw,read.csv("log/paliViews2015.csv",stringsAsFactor=F))
    fw <- rbind(fw,read.csv("log/paliViews2016.csv",stringsAsFactor=F)%>%head)
    fw <- rbind(fw,read.csv("log/paliViews2017.csv",stringsAsFactor=F))
    fw$day <- as.Date(strptime(fw$day,format="%Y%m%d")) 
    fw5 <- fw[fw$channel==paliL[i],]

    fs$cluster <- "rest"
    for(j in 1:length(vSection$canale)){##assign ch
        fs[grepl(vSection[j,"canale"],fs$name),"cluster"] <- vSection[j,"cluster"]
    }
    fs <- fs[!is.na(fs$cluster),]
    fs$strip = NA
    for(j in 1:(nrow(timeC)-1)){
        stripV = which(fs$min>=timeC[j,"time"] & fs$min<timeC[j+1,"time"])
        fs$strip[stripV] = j + 4
    }
    fs$tel <- NA
    for(j in 1:nrow(fs)){
        set <- fs[j,"date"]==fw5[,"date"]
        if(any(set)){
            fs[j,"tel"] <- fw5[set,fs[j,"strip"]]
        }
    }
    aggrAll <- rbind(aggrAll,fs)
}

tabAll1 <- ddply(aggrAll,.(date,cluster),summarise,tel=sum(tel,na.rm=T))
tabAll <- xtabs(tel~date+cluster,data=tabAll1)
write.csv(tabAll,"out/invVideoTimeSeqTel.csv",row.names=T)
head(tabAll)

vSection <- read.csv("raw/inventoryVideoSection.csv",stringsAsFactor=F)
yearL = c('2013','2014','2015','2016','2017')
chL = c('C5','I1','R4')
fs <- NULL
for(i in yearL){
    for(j in chL){
        fs <- rbind(fs,read.csv(paste("raw/paliSoap",i,j,".csv",sep=""),stringsAsFactor=F))
    }
}
fs$name <- tryTolower(fs$name)
fs$genre <- tryTolower(fs$genre)
fs$name <- gsub("[[:punct:]]","",fs$name)
fs$date <- as.Date(gsub('[[:alpha:]]',"",fs$time),format="%d/%m/%Y")
fs$cluster <- "rest"
for(i in 1:nrow(vSection)){fs[grepl(vSection$canale[i],fs$name),"cluster"] <- vSection$cluster[i]}
table(fs$cluster)
head(fs)
fs$un <- 1
paliS <- xtabs("un ~ date + cluster",data=fs)
head(paliS)
write.csv(paliS,"out/invVideoTimeSeqPali.csv")


fw = fw[,1:10]
colnames(fw) = c("date","channel","tot","fascia7","fascia9","fascia12","fascia15","fascia18","fascia20","fascia22")
head(fw)
fs$fascia = substring(fs$time,12,13)
fw1 = fw[fw$channel=="am – c5+i1+r4",]
fw1 = fw1[,!colnames(fw1) %in% c("channel")]
numsC = sapply(fw1,is.numeric)
fw1[,numsC] = fw1[,numsC]*1000
rownames(fw1) = fw1$date

fw2 = melt(fw1,id="date")
fw2$week = format(fw2$date,"%y-%W")
head(fw2)
fw3 = ddply(fw2,.(week,variable),summarise,imps=sum(value),date=head(date,1))
fw4 <- as.data.frame.matrix(xtabs("imps ~ date + variable",data=fw3))
fw4 = cbind(date=rownames(fw4),fw4)
head(fw4)


library('RMySQL')
source('credenza/intertino.R')
con <- dbConnect(MySQL(),user=db_usr,password=db_pass,dbname=db_db,host=db_host)
on.exit(dbDisconnect(con))
gs <- read.csv("out/invVideoTimeSeqTel.csv",row.names=1)
dbGetQuery(con,"DROP TABLE inventory_tel")
colnames(gs) = unique(vSection$cluster) %>% gsub("\\.","/",.)
dbWriteTable(con,"inventory_tel",gs)
gs <- read.csv("out/invVideoTimeSeqPali.csv",stringsAsFactor=F)
for(g in colnames(gs)[2:ncol(gs)]){gs[,g] = gs[,g]/max(gs[,g])*1000000}
colnames(gs) = colnames(gs) %>% gsub("\\.","/",.) %>% gsub("X","date",.)
gs$date = as.Date(gs$date)
dbGetQuery(con,"DROP TABLE inventory_tv_pali")
dbWriteTable(con,"inventory_tv_pali",gs)

dbGetQuery(con,"DROP TABLE inventory_tv_audience")
dbWriteTable(con,"inventory_tv_audience",fw1)
dbGetQuery(con,"DROP TABLE inventory_tv_audience_week")
dbWriteTable(con,"inventory_tv_audience_week",fw4)

dbDisconnect(con)





