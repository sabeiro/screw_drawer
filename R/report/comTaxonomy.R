#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
#setwd('..')

##install.packages(c('textcat','svglite'))
source('src/R/graphEnv.R')
library('corrplot') #package corrplot
library('svglite')
library('ape')
library(cluster)
library(rjson)
library(psych)
library(GPArotation)
library(MASS)
library(MBESS)
library(parallel)

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


fs <- read.csv('raw/comTaxonomy.csv',stringsAsFactor=F)
fs <- fs[fs$STATUS=="OK",]
catL <- unique(c(fs$IAB.CATEGORY.1,fs$IAB.CATEGORY.2,fs$IAB.CATEGORY.3,fs$IAB.CATEGORY.4,fs$IAB.CATEGORY.5))
catL <- catL[order(catL)]
catN <- c(4,6,8,10,12)
proxM <- matrix(0,nrow=length(catL),ncol=length(catL))
i <- 1
for(i in 1:nrow(fs)){
    for(j in 1:(length(catN)-1)){
        j1 <- catN[j]
        for(k in (j+1):length(catN)){
            k1 <- catN[k]
            rowL <- match(fs[i,j1],catL)
            colL <- match(fs[i,k1],catL)
            proxM[rowL,colL] = proxM[rowL,colL] + fs[i,j1+1] + fs[i,k1+1]
        }
    }
}
colnames(proxM) <- catL
rownames(proxM) <- catL
proxM[is.na(proxM)] <- 0
proxM1 <- proxM
if(FALSE){
    lim = quantile(colSums(proxM),0.70)
    setC <- colSums(proxM) > lim
    lim = quantile(rowSums(proxM),0.70)
    setR <- rowSums(proxM) > lim
    proxM <- proxM[setR,setC]
}

catSpl <- strsplit(catL,split="::")
catL1 <- NULL
catL2 <- NULL
for(i in as.numeric(labels(catSpl))){
    catL1 <- c(catL1,try(catSpl[[i]][1]))
    catL2 <- c(catL1,try(catSpl[[i]][2]))
}
melted <- melt(proxM)
melted <- melted[!melted$Var1=="",]
melted <- melted[!melted$Var2=="",]
sum(melted$value)
melted$cat1 <- unlist(lapply(strsplit(as.character(melted$Var1),split="::"),'[[',1))
melted$cat2 <- unlist(lapply(strsplit(as.character(melted$Var2),split="::"),'[[',1))
proxC <- as.matrix(xtabs("value ~ cat1 + cat2",data=melted))

rc <- rainbow(nrow(proxC), start = 0, end = .3)
cc <- rainbow(ncol(proxC), start = 0, end = .3)
jpeg("fig/taxonomyDendo.jpg",width=pngWidth,height=pngHeight)
hv <- heatmap(proxC,col=brewer.pal(11,'YlOrRd'), scale = "column",
              RowSideColors = rc, ColSideColors = cc, margins = c(5,10),
              xlab = "", ylab =  "",
              main = "heatmap cat")
dev.off()

melted <- data.frame(name=colnames(proxM),col=colSums(proxM),row=rowSums(proxM))
melted$name <- as.character(melted$name)
melted$name <- paste(melted$name,"::",sep="")
melted$cat <- unlist(lapply(strsplit(as.character(melted$name),split="::"),'[[',1))
melted[order(melted$col),]
gLabel = c("cat rti","cat comscore",paste("cat confusion matrix",""),"collisions")
p <- ggplot(melted,aes(x=cat,group=cat)) +
    ## geom_line(aes(y=col,color=cat)) +
    ## geom_line(aes(y=row,color=cat)) +
    geom_boxplot(aes(y=col,color=cat),show.legend=F) +
    geom_jitter(aes(y=col,color=cat),height = 0,alpha=0.3,show.legend=F) +
    scale_x_discrete(breaks=melted$cat) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) 
p
ggsave(file="fig/taxonomyBox.jpg", plot=p, width=gWidth, height=gHeight)




proxD <- dist(proxC, method = "euclidean") # distance matrix

##cor(proxD,method="spearman")
psych:omega(as.matrix(proxD))##,n.iter = 7, p = 0.05, nfactors = 3)


## wss <- (nrow(proxM)-1)*sum(apply(proxM,2,var),na.rm=T)
## for (i in 2:15) wss[i] <- sum(kmeans(proxM,centers=i)$withinss,na.rm=T)
## plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares") 
## "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski"
colL = colSums(proxM) > quantile(colSums(proxM),0.70)
proxD <- dist(proxM[colL,colL], method = "minkowski") # distance matrix
# "ward.D", "ward.D2", "single", "complete", "average" (= UPGMA), "mcquitty" (= WPGMA), "median" (= WPGMC) or "centroid" (= UPGMC).
hc <- hclust(proxD, method="ward.D2")
json <- HCtoJSON(hc)
write(json,"intertino/data/comTaxonomy.json")
dend <- as.dendrogram(hc)
##plot(as.phylo(hc),type="fan")
##groups <- cutree(hc, k=5) # cut tree into 5 clusters
## library(data.tree)
## data(acme)
## l <- as.list(acme)
## library(rjson)
## cat(toJSON(l))



fit <- kmeans(proxM,5)
library(cluster)
clusplot(proxM, fit$cluster, color=TRUE, shade=TRUE,labels=2, lines=0)
library(fpc)
plotcluster(proxM, fit$cluster) 


##cluster.stats(proxD, fit1$cluster, fit2$cluster) 
##-----------------------confusion-matrix------------------------
ts <- read.csv("raw/trainingUrl.csv",stringsAsFactor=F)
ts <- ts[order(ts$url),]
fs <- read.csv('raw/comTaxonomy.csv',stringsAsFactor=F)
fs <- fs[order(fs$URL),]
fs$IAB.CATEGORY.1 <- paste(fs$IAB.CATEGORY.1,"::",sep="")
fs$cat1 <- unlist(lapply(strsplit(fs$IAB.CATEGORY.1,split="::"),'[[',1))
fs$IAB.CATEGORY.2 <- paste(fs$IAB.CATEGORY.2,"::",sep="")
fs$cat2 <- unlist(lapply(strsplit(fs$IAB.CATEGORY.2,split="::"),'[[',1))
fs$IAB.CATEGORY.3 <- paste(fs$IAB.CATEGORY.3,"::",sep="")
fs$cat3 <- unlist(lapply(strsplit(fs$IAB.CATEGORY.3,split="::"),'[[',1))
fs$IAB.CATEGORY.4 <- paste(fs$IAB.CATEGORY.4,"::",sep="")
fs$cat4 <- unlist(lapply(strsplit(fs$IAB.CATEGORY.4,split="::"),'[[',1))
fs$IAB.CATEGORY.5 <- paste(fs$IAB.CATEGORY.5,"::",sep="")
fs$cat5 <- unlist(lapply(strsplit(fs$IAB.CATEGORY.5,split="::"),'[[',1))
fsMatch <- read.csv("raw/trainingUrlMatch.csv",stringsAsFactor=F)

for(i in unique(fsMatch$rti)){
    ts[ts$label_id==i,"cat1"] <- fsMatch[fsMatch$rti==i,"iab"]
}
confMat <- table(ts$cat1,fs$cat1) + table(ts$cat1,fs$cat2) + table(ts$cat1,fs$cat3)# + table(ts$cat1,fs$cat4) + table(ts$cat1,fs$cat5)

melted <- melt(proxC)
colnames(melted) <- c("Var1","Var2","value")
melted <- melt(confMat)
melted$value <- melted$value/100
gLabel = c("cat rti","cat comscore",paste("cat confusion matrix",""),"collisions")
p <- ggplot(melted,aes(x=Var1,y=Var2,group=Var2)) +
##    geom_raster(data=meltTarget[!is.na(meltTarget$value),],aes(fill = value), interpolate = TRUE,alpha=0.7) + 
    geom_tile(aes(fill=value),size=1,width=0.9,height=0.9) +
    geom_text(aes(fill=value,label=paste(formatC(value*100,digit=0,format="f"),"",sep="")),colour="white",size=3) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
##    scale_fill_gradient(low="white",high="steelblue") +
    ## facet_grid(. ~ source) + ##,scales = "free", space = "free") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        panel.background = element_blank()
    )
p
ggsave(file="fig/taxonomyHeat.jpg", plot=p, width=gWidth, height=gHeight)


## Ward Hierarchical Clustering with Bootstrapped p values
## install.packages('pvclust')
## library(pvclust)
## fit <- pvclust(proxM, method.hclust="ward",method.dist="euclidean")
## plot(fit) # dendogram with p values
## pvrect(fit, alpha=.95) 








