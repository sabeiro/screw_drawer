#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')
library(gtools)
library("forecast")
library(stringi)
library(wordcloud)
library(RColorBrewer)
library(igraph)
library(ggplot2)
library(tm)
library(cluster)
##library(FactoMineR)
library(plyr)
library(reshape)
library(deldir)
library(tripack)
comprob <- .98

##install.packages('seewave')
##library(seewave)
##install.packages('signal')
##library(signal)


##source("script/inventoryLoad.R")
##aggrAll <- read.csv("out/invVideoTimeSeq.csv")
aggrAll <- read.csv("out/invVideoTimeSeqCh.csv")
aggrAll$X <- as.Date(aggrAll$X)
aggrM <- as.matrix(aggrAll[,-1])

NLevel <- 9
NCluster <- 7
chImps <- data.frame(imps=as.vector(colSums(aggrM)))
chImps$sect <- as.vector(colnames(aggrM))
chImps <- chImps[order(-chImps$imps),]
cumprob <- 1:9/9
lim <- c(0,quantile(chImps$imps,cumprob))
chImps$level <- cut(chImps$imps,breaks=lim,labels=1:NLevel)
chImps <- chImps[!chImps$sect=="total",]
chImps <- chImps[!chImps$sect=="rest",]
chImps <- chImps[!chImps$sect=="PUBMATIC",]
chImps <- chImps[!chImps$sect=="XAXIS",]
chImps <- chImps[!chImps$sect=="Test.RTB",]
head(chImps)

write.csv(chImps,"raw/inventoryVideoSection2.csv")

k <- 9
for(k in unique(chImps$level)){
    sectL <- chImps[chImps$level==k,"sect"]
    aggrM1 <- aggrAll[,c(TRUE,colnames(aggrAll) %in% sectL)]
    melted <- melt(aggrM1,id="X")
    head(melted)
    melted$week <-  paste(format(melted$X,"%y"),format(melted$X,"%W"),sep="-")
    meltedW <- ddply(melted,.(week,variable),summarise,value=sum(value))
    head(meltedW)
    gLabel = c("canale","canale",paste("cross correlation level",k),"percentuale")
    p <- ggplot(melted,aes(x=X,y=value,group=variable)) +
        geom_line(aes(color=variable)) +
        ##geom_text(aes(fill=value,label=formatC(value*100,digit=0,format="f")),colour="white",size=4) +
        scale_fill_gradient(low="white",high="steelblue") +
        theme(
            ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
            legend.position="bottom", legend.box = "horizontal",
            panel.background = element_blank()
        ) +
        ##scale_x_date(date_breaks = "1 week", date_labels = "%W") +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
    p

    aggrSpe <- NULL##data.frame(X=aggrM1$X)
    aggrSea <- NULL##data.frame(X=aggrM1$X)
    aggrRes <- NULL##data.frame(X=aggrM1$X)
    densBreak <- seq(-200,200,by=1)
    i <- 5
    NSet <- ncol(aggrM1)
    for(i in 2:NSet ){
        impr = ts(aggrM1[,i], frequency=7)##, start=c(2012,07,01), end=c(2016,07,03))
        impr2 = window(impr)##, start=c(2013,10), end=c(2015, 12))
        dog = stl(impr2, s.window="periodic")
        timeS <- dog$time.series[,1]
        ##timeS <- aggrM1[,i]
        aggrSpe <- cbind(aggrSpe,spectrum(timeS,plot=FALSE)$spec)
        aggrSea <- cbind(aggrSea,dog$time.series[,2])
        aggrRes <- cbind(aggrRes,density(dog$time.series[,3],n=200,from=-200,to=200)$y)
    }
    aggrSpe <- as.data.frame(aggrSpe)
    colnames(aggrSpe) <- colnames(aggrM1[2:NSet])
    aggrSpe$X <- 1:nrow(aggrSpe)
    aggrSea <- as.data.frame(aggrSea)
    colnames(aggrSea) <- colnames(aggrM1[2:NSet])
    aggrSea$X <-  1:nrow(aggrSea)
    aggrRes <- as.data.frame(aggrRes)
    colnames(aggrRes) <- colnames(aggrM1[2:NSet])
    aggrRes$X <-  1:nrow(aggrRes)

    melted <- melt(aggrRes,id="X")
    head(melted)
    gLabel = c("canale","canale",paste("cross correlation level",k),"percentuale")
    p <- ggplot(melted,aes(x=X,y=value,group=variable)) +
        geom_line(aes(color=variable)) +
        ##geom_text(aes(fill=value,label=formatC(value*100,digit=0,format="f")),colour="white",size=4) +
        scale_fill_gradient(low="white",high="steelblue") +
        ##scale_x_log10() +
        ##scale_y_log10() + annotation_logticks() +
        theme(
            ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
            legend.position="bottom", legend.box = "horizontal",
            panel.background = element_blank()
        ) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
    p


    corM <- cor(aggrM1[-1])
    diag(corM) <- 0
    corSpe <- cor(aggrSpe[-ncol(aggrSpe)])
    diag(corSpe) <- 0
    corSea <- cor(aggrSea[-ncol(aggrSea)])
    diag(corSea) <- 0
    corRes <- cor(aggrRes[-ncol(aggrRes)])
    diag(corRes) <- 0

    corTot <- corM + corSpe + corSea + corRes



    gp_graph = graph.adjacency(corTot, weighted=TRUE,mode = "max",add.rownames=TRUE)
    posi_matrix = layout.spring(gp_graph, list(weightsA=E(gp_graph)$weight))
    posi_matrix = cbind(V(gp_graph)$name, posi_matrix)
    gp_df = data.frame(posi_matrix, stringsAsFactors=FALSE)
    names(gp_df) = c("word", "x", "y")
    gp_df$x = as.numeric(gp_df$x)
    gp_df$y = as.numeric(gp_df$y)
    se = diag(corM) / max(diag(corM))
    words_km = kmeans(cbind(as.numeric(posi_matrix[,2]), as.numeric(posi_matrix[,3])), NCluster)
    w_size <- diag(corM)^(0.1)
    gp_df = transform(gp_df, freq=w_size, cluster=as.factor(words_km$cluster))
    V <- voronoi.mosaic(words_km$centers[,1],words_km$centers[,2])
    P <- voronoi.polygons(V)
    voro <- deldir(words_km$centers[,1],words_km$centers[,2])
    row.names(gp_df) = 1:nrow(gp_df)
    gLabel = c("canale","canale",paste("cross correlation level",k),"percentuale")
    gp_words = ggplot(gp_df, aes(x=x, y=y)) +
        geom_text(aes(size=freq, label=gp_df$word, alpha=.90, color=as.factor(cluster))) +
        geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2),size = 1,data = voro$dirsgs,linetype = "dotted",color= "#FFB958") +
    scale_size_continuous(breaks = c(10,20,30,40,50,60,70,80,90), range = c(1,8)) +
        scale_colour_manual(values=skillPal) +
        scale_x_continuous(breaks=c(min(gp_df$x), max(gp_df$x)), labels=c("","")) +
        scale_y_continuous(breaks=c(min(gp_df$y), max(gp_df$y)), labels=c("","")) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
        theme(panel.grid.major=element_blank(),
              legend.position="none",
              panel.background = element_rect(fill="transparent",colour=NA),
              panel.grid.minor=element_blank(),
              axis.ticks=element_blank(),
              title = element_text("Skills clustering"),
              plot.title = element_text(size=12))
    plot(gp_words)

    ggsave(plot=gp_words, filename=paste("fig/advVoro",varList[iN],varList[oN],".png",sep=""), width=gWidth+2, height=gHeight)

    write.csv(gp_df,paste("out/advClusterCtr",varList[iN],varList[oN],".csv",sep=""),sep="\t")

    melted <- melt(corM)
    melted <- merge(melted,gp_df,by.x="X1",by.y="word")
    melted <- melted[order(melted$cluster),]
    melted$X2 <- factor(melted$X2,levels=unique(melted$X2))
    melted$X1 <- factor(melted$X1,levels=unique(melted$X1))

    gLabel = c("canale","canale",paste("cross correlation level",k),"percentuale")
    p <- ggplot(melted,aes(x=X1,y=X2,group=X2)) +
        geom_tile(aes(fill=value),colour="white") +
        ##geom_text(aes(fill=value,label=formatC(value*100,digit=0,format="f")),colour="white",size=4) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
        scale_fill_gradient(low="white",high="steelblue") +
        theme(
            ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
            panel.background = element_blank()
        )
    p

}




