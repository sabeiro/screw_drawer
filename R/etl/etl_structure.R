require(RJSONIO)

HCtoJSON<-function(hc){
  labels<-hc$labels
  merge<-data.frame(hc$merge)
  for (i in (1:nrow(merge))) {
    if (merge[i,1]<0 & merge[i,2]<0) {eval(parse(text=paste0("node", i, "<-list(name=\"", i, "\", children=list(list(name=labels[-merge[i,1]]),list(name=labels[-merge[i,2]],size=1 )))")))}
    else if (merge[i,1]>0 & merge[i,2]<0) {eval(parse(text=paste0("node", i, "<-list(name=\"", i, "\", children=list(node", merge[i,1], ", list(name=labels[-merge[i,2]],size=1)))")))}
    else if (merge[i,1]<0 & merge[i,2]>0) {eval(parse(text=paste0("node", i, "<-list(name=\"", i, "\", children=list(list(name=labels[-merge[i,1]],size=1), node", merge[i,2],"))")))}
    else if (merge[i,1]>0 & merge[i,2]>0) {eval(parse(text=paste0("node", i, "<-list(name=\"", i, "\", children=list(node",merge[i,1] , ", node" , merge[i,2]," ))")))}
  }
  eval(parse(text=paste0("JSON<-toJSON(node",nrow(merge), ")")))
  return(JSON)
}

grp2List <- function(fName){
    fs <- read.csv(fName,stringsAsFactor=F)
    tList <- list()
    for(i in 1:nrow(fs)){
        rList = "list("
        for(j in colnames(fs)){
            chr <-  ifelse(typeof(fs[i,j])=="character",paste(j,"=\"",fs[i,j],"\",",sep=""),paste(j,"=",fs[i,j],",",sep=""))
            rList <- paste(rList,chr)
        }
        rList <- paste(gsub(",$","",rList),")",sep="")
        rVect <- eval(parse(text=rList))
        tList[[i]] = rVect
    }
    return toJSON(list(links=tList))
}

grp2List <- function(fs){
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
}
