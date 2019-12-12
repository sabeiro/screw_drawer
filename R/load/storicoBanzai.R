#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')

fs <- read.csv('raw/storicoBanzai.csv',stringsAsFactor=F)
fs$Lordo.c.a. = fs$Lordo.c.a. %>% gsub(",","",.) %>% as.numeric()
fsM <- read.csv('raw/storicoBanzaiMap.csv')
fsRev <- as.data.frame(setNames(replicate(ncol(fsM),numeric(0), simplify = F),colnames(fsM)))
i <- 1
j <- 1
fsRev = NULL
fs2 = NULL
for(i in 1:nrow(fs)){
    if( !(grepl("Circuito",fs$Sito.Web[i]) | grepl("Network",fs$Sito.Web[i])) ){
        fsLine = as.vector(unlist(c(fs[i,],fs$Sito.Web[i],fs$Lordo.c.a.[i])))
        fs2 = rbind(fs2,fsLine)
        next;
    }
    revI = fs$Lordo.c.a.[i]
    tabIdx = fsM[fs$Sito.Web[i]==fsM$X,]*revI/100
    colnames(tabIdx) = colnames(fsM)
    fsRev = rbind(fsRev,tabIdx)
    tmp = t(tabIdx)
    tmp = tmp[!is.na(tmp),]
    for(j in 1:length(tmp)){
        fsLine = as.vector(unlist(c(fs[i,],names(tmp)[j],as.numeric(tmp[j]))))
        fs2 = rbind(fs2,fsLine)
    }
}
head(fs2)
ncol(fs2)
colnames(fs2) = c(colnames(fs),"site","site_rev")
revSite = colSums(fsRev,na.rm=T)
write.csv(fs2,"raw/storicoBanzaiRev.csv")



