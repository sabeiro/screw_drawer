#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')
library('corrplot') #package corrplot
library('svglite')
require(stats)
require(dplyr)
library(grid)
library(sqldf)
library('rjson')
library('jsonlite')
library('RJSONIO')
library(RCurl)


catLapi <- getURLContent("http://services.bluekai.com/Services/WS/Taxonomy?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=Gl03XkcrZLRDoq6nycOK2vvFI%2FkoX5zyfgi8OTnUCTs%3D")
catL1 <- RJSONIO::fromJSON(catLapi)
catL1 <- catL1[['nodeList']]
catL <- do.call(rbind.data.frame,catL1)
catG <- NULL
catGL <- list()
for(i in 1:nrow(fs)){
    catS <- fromJSON(fs$cat[i])
    for(j in catS){
        catG = rbind(catG,data.frame(id=j$AND[[1]]$cat,reach=j$AND[[1]]$reach,group=fs[i,"id"],gName=fs[i,"name"],gReach=fs[i,"reach"]))
    }
}
catG$name <- catL[match(catG$id,catL$nodeID),"nodeName"]
catG$parent <- catL[match(catG$id,catL$nodeID),"parentID"]
catG$parentName <- catL[match(catG$parent,catL$nodeID),"nodeName"]
catG$reach <- catG$reach/1000000
catG$gReach <- catG$gReach/1000000
catG <- catG[!is.na(catG$name),]
catG$gName <- catG$gName %>% gsub("Yahoo ","",.) %>% sub("i-t ","",.)
groupG <- ddply(catG,.(gName,gReach,group),summarise,reach_sum=sum(reach),nodes=length(name))
groupG <- groupG[groupG$nodes > 7,]##filter
groupG <- groupG[!grepl("mm01",groupG$gName),]##filter
##groupG <- groupG[!grepl("an seconde",groupG$gName),]##filter
groupG <- groupG[!grepl("an femminile",groupG$gName),]##filter
groupG <- groupG[!grepl("an video",groupG$gName),]##filter
groupG <- groupG[!grepl("Fertilit",groupG$gName),]##filter
groupG <- groupG[!grepl("Bellezza",groupG$gName),]##filter
groupG <- groupG[!grepl("Genitori",groupG$gName),]##filter
groupG <- groupG[!grepl("Sciure",groupG$gName),]##filter
##groupG <- groupG[!grepl("Yahoo",groupG$gName),]##filter
catG <- catG[catG$gName %in% groupG$gName,]
parentG <- ddply(catG,.(parent,parentName,group),summarise,nodes=length(name))
nodeF <- data.frame(name=groupG$gName,group=-1,ref=groupG$group,size=groupG$gReach)
nodeF <- rbind(nodeF,data.frame(name=parentG$parentName,group=parentG$group,ref=parentG$parent,size=parentG$nodes))
nodeF <- rbind(nodeF,data.frame(name=catG$name,group=catG$group,ref=catG$id,size=catG$reach))
nodeF <- ddply(nodeF,.(ref),summarise,name=head(name,1),group=head(group,1),size=sum(size))
nodeF$idx <- 1:nrow(nodeF)
nodeL <- as.list(nodeF)
nodeL <- list()
for(i in 1:nrow(nodeF)){
    nodeL[[i]] = list(name=nodeF$name[i],group=nodeF$group[i],idx=nodeF$idx[i],size=nodeF$size[i])
}
nodeL <- list(nodes=nodeL)
write(toJSON(nodeL),"intertino/data/networkTaxonomyNodes.json")
linkF <- data.frame(id=catG$id,to=catG$parent,value=catG$reach,name=catG$name)
linkF <- rbind(linkF,data.frame(id=parentG$parent,to=parentG$group,value=parentG$nodes,name=parentG$parentName))
linkF$source <- nodeF[match(linkF$id,nodeF$ref),"idx"]
linkF$target <- nodeF[match(linkF$to,nodeF$ref),"idx"]
linkL <- list()
for(i in 1:nrow(linkF)){
    linkL[[i]] = list(source=linkF$source[i]-1,target=linkF$target[i]-1,value=linkF$value[i],name=linkF$name[i])
}
linkL <- list(links=linkL)
write(toJSON(linkL),"intertino/data/networkTaxonomyLinks.json")
