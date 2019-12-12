#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
library(RCurl)

## fRaw <- getURL('http://services.bluekai.com/Services/WS/audiences?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=p1cKHJ4B1JSZyp2AqTlCs60pUpVDdp%2FDsCljNkvwAR0%3D',ssl.verifypeer=F)
## x = base64("Simple text", TRUE, "raw")
## URL <- 'http://services.bluekai.com/Services/WS/audiences?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=p1cKHJ4B1JSZyp2AqTlCs60pUpVDdp%2FDsCljNkvwAR0%3D'
## html <- getURLContent(URL)

##https://docs.google.com/spreadsheets/d/11ALr9PE2fFlmsZ6bADEpnlybaN_t8JTA9XnFK_kzWZE/edit
year <- "2017"
month <- c("01","02","03","04","05","06","07","08","09","10","11","12")
originD <- c("2017-01-01","2017-02-05","2017-03-05","2017-04-02","2017-05-07","2017-06-04","2017-07-02","2017-08-06","2017-09-03","2017-10-01","2017-11-05","2017-12-03")
urlDPre <- "https://docs.google.com/spreadsheets/d/11ALr9PE2fFlmsZ6bADEpnlybaN_t8JTA9XnFK_kzWZE/export?format=tsv&id=11ALr9PE2fFlmsZ6bADEpnlybaN_t8JTA9XnFK_kzWZE&gid="
urlD <-c("2070498389","1222702820","1418429703","807266244","474903661","1535886954","858251383","953691798","113090621","28249488","1288461234","1539663865")

ingombri1 <- data.frame(x=character(),imps=numeric(),week=numeric(),month=character())
ingombriW1 <- data.frame(week=numeric(),imps=numeric(),day=character(),date=as.Date(as.character()))
k <- 1
week <- 1
for(k in 1:length(urlD)){
    print(originD[k])
    fRaw <- getURL(url=paste(urlDPre,urlD[k],sep=""),ssl.verifypeer=F)
    fs <- read.csv(text=fRaw,sep="\t", encoding = "utf-8",stringsAsFactors = FALSE,quote="")
    fLim = c(0,0)
    if(!any(fs[,1]=="MEDIASET ON DEMAND ")){
        fLim[1] = head(grep("PEOPLE MEDIUM",fs[,2]),1)
    }else{
        fLim[1] = head(grep("MEDIASET ON DEMAND",fs[,1]),1)
    }
    fLim[2] = head(grep("ALL 24",fs[,2]),1)
    ##fs = fs[fs[,1]=="MEDIASET ON DEMAND ",]
    fs = fs[fLim[1]:fLim[2],]
    tmpL = c(fs[1,2],fs[1,3],fs[1,4])
    for(i in 1:nrow(fs)){
        for(d in 2:4){
            if(fs[i,d] == "" | is.na(fs[i,d])){fs[i,d] = tmpL[d]}
            else{tmpL[d] = fs[i,d]}
        }
    }
    fs[,3] <- gsub("[[:alpha:]]","",fs[,3])
    fs[,3] <- as.numeric(gsub("[[:punct:]]","",fs[,3]))
    i <- 6
    for(i in 5:ncol(fs)){
        fs[fs[,i]=="",i] = 0
        fs[,i] <- gsub("^(.*)\\((.*)k\\)(.*)$", "\\2000", fs[,i])
        colL <-  grepl("[[:alpha:]]", fs[,i])
        fs[colL,i] = fs[colL,3]
        fs[,i] <- as.numeric(fs[,i])
    }
    
    ingombri <- data.frame(date=colnames(fs)[5:ncol(fs)] %>% gsub("[[:alpha:]]","",.) %>% gsub("[[:punct:]]","",.))
    ingombri$date <- paste(year,month[k],ingombri$date,sep="-")
    ingombri$imps <- colSums(fs[,5:ncol(fs)],na.rm=T)/7
    ingombri1 <- rbind(ingombri1,ingombri)
}

ingombri1$week <- format(as.Date(ingombri1$date),"%W")
ingombriW <- ddply(ingombri1,.(week),summarise,imps=sum(imps,na.rm=TRUE),day=head(date,1),month=head(month,1))
ingombriW <- ingombriW[,c("day","imps")]
colnames(ingombriW) = c("date","imps")
write.csv(ingombriW,paste("raw/ingombri",year,".csv",sep=""))

library('RMySQL')
source('credenza/intertino.R')
con <- dbConnect(MySQL(),user=db_usr,password=db_pass,dbname=db_db,host=db_host)
on.exit(dbDisconnect(con))
ingombriW <- read.csv('raw/ingombri2016.csv',stringsAsFactor=FALSE)
ingombriW <- rbind(ingombriW,read.csv('raw/ingombri2017.csv',stringsAsFactor=FALSE))
ingombriW$date <- as.Date(ingombriW$date)+3
ingombriW <- ingombriW[!is.na(ingombriW$date),]
ingombriW <- ingombriW[-1,]
ingombriW$imps <- ingombriW$imps/1000000
dbGetQuery(con,"DROP TABLE inventory_ingombri")
dbWriteTable(con,"inventory_ingombri",ingombriW[,c("date","imps")])
dbDisconnect(con)
