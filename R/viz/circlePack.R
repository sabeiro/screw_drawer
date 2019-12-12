#!/usr/bin/env Rscript
setwd('~/lav/media/')
#setwd('..')

##install.packages(c('textcat','svglite'))
source('src/R/graphEnv.R')

library(rjson)

gColL = gCol1

toInt <- function(col,alpha){
    str <- 'rgba('
    str = paste(str,strtoi(paste("0",substring(col,2,3),sep="x")),",",sep="")
    str = paste(str,strtoi(paste("0",substring(col,4,5),sep="x")),",",sep="")
    str = paste(str,strtoi(paste("0",substring(col,6,7),sep="x")),",",alpha,")",sep="")
    return(str)
}

fs <- read.csv("raw/organigrammaAziendale.csv",stringsAsFactor=F)
fs <- fs[!is.na(fs$assegnatario),]
grpL <- unique(fs$ubicazione)
catL <- unique(fs$gruppo)
empL1 <- list()
k = 1
for(k in 1:length(catL)){
    cs = fs[fs$gruppo==catL[k],]
    grpL1 <- unique(cs$ubicazione)
    empC <- list()
    for(j in 1:length(grpL1)){
        gs = fs[fs$ubicazione==grpL1[j],]
        empG <- list()
        for(i in 1:nrow(gs)){
            empG[[i]] = list(name=gs$assegnatario[i],size=1,role=paste("sn",gs$sn[i],"codice",gs$codice[i],"modello",gs$Modello[i]))
        }
        empC[[j]] = list(name=grpL1[j],color=toInt(gColL[k],.7),children=empG)
    }
    empL1[[k]] = list(name=catL[k],color=toInt(gColL[k],.3),children=empC)
}


write(toJSON(list(name="Organigramma Mediamond",color="rgba(230,230,230,0.9)",title="...",children=empL1)),"intertino/data/orgaMediamond.json")








