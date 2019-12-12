#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
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


##advList <- read.csv("raw/advComplete.csv",sep="\t")
advList <- read.csv("raw/adv2015short.csv",sep=",",stringsAsFactor=FALSE)
advList$subcat <- unlist(lapply(strsplit(advList$cat,split="|"),"[[",1))
advList$Imps <- as.numeric(advList$Imps)
advList$Click <- as.numeric(advList$Click)
varList <- c("AdvertiserName","cat","subcat","Section","Channel","Site","Publisher","DeviceType","Size")
varLoopIn <- NULL#c(1,1,1,1,1,1,8,8,8,8,8,8)
varLoopOut<- NULL#c(2,3,4,5,6,7,2,3,4,5,6,7)
for(i in 1:(length(varList)-1)){
    for(j in (i+1):length(varList)){
    varLoopIn <- c(varLoopIn,i)
    varLoopOut <- c(varLoopOut,j)
    }
}
k <- 1
comm_prob = 0.75
for(k in 1:length(varLoopIn)){
    iN <- 5
    oN <- 2
    iN <- varLoopIn[k]
    oN <- varLoopOut[k]
    print(paste("aggregate",varList[iN],varList[oN]))
    aggr1 <- ddply(advList,c(varList[iN],varList[oN]),summarise,imps = sum(Imps,na.rm=TRUE),click = sum(Click,na.rm=TRUE))
    impsSum <- as.matrix(xtabs(paste("imps ~",varList[iN],"+",varList[oN]),data=aggr1))
    clickSum <- as.matrix(xtabs(paste("click ~",varList[iN],"+",varList[oN]),aggr1))
    ctrSum <- as.matrix(clickSum / impsSum)
    ctrSum[is.na(ctrSum)] <- 0
    ctrSum[is.infinite(ctrSum)] <- 0

    impsSum = t(impsSum) %*% impsSum
    ctrSum = t(ctrSum) %*% ctrSum
    ctrSum[is.nan(ctrSum)] <- 0
    ctrSum[is.infinite(ctrSum)] <- 0
    ## write.csv(impsSum,paste("out/advAdjaImps",varList[iN],varList[oN],".csv",sep=""),sep="\t")
    ## write.csv(ctrSum,paste("out/advAdjaCtr",varList[iN],varList[oN],".csv",sep=""),sep="\t")

    cor(c(impsSum),c(ctrSum))

    view <- ctrSum
    k_cluster <- min(11,nrow(view)/4)
    diag(view) = 0
    wc = rowSums(view)
    for(i in seq(1:length(colnames(view)))){view[i,i] = wc[[i]]}
    s_words <- colnames(view)
    word_freqs = sort(rowSums(view), decreasing=TRUE)
    lim = quantile(word_freqs, probs=comm_prob)
    ##    lim = 1
    good <- view[rowSums(view)>lim,colSums(view)>lim]

    corrField = good[rowSums(good)!=0,colSums(good)!=0]
    ##m1dist = dist(corrField, method="fJaccard")
    m1dist = dist(corrField)
    clus1 = hclust(m1dist, method="ward.D2")
    ## plot dendrogram
    svg(paste("fig/advDendo",varList[iN],varList[oN],".svg",sep=""))
    plot(clus1, cex=0.7)
    dev.off()


    adja_matrix <- good
    diag(adja_matrix) <- 0
    affi_matrix <- good
    ##    mode=c("directed", "undirected", "max","min", "upper", "lower", "plus"),
    gp_graph = graph.adjacency(adja_matrix, weighted=TRUE,mode = "max",add.rownames=TRUE)
    ##posi_matrix = layout.fruchterman.reingold(gp_graph, list(weightsA=E(gp_graph)$weight))
    ##posi_matrix = layout.drl(gp_graph, list(weightsA=E(gp_graph)$weight))
    posi_matrix = layout.spring(gp_graph, list(weightsA=E(gp_graph)$weight))
    posi_matrix = cbind(V(gp_graph)$name, posi_matrix)
    gp_df = data.frame(posi_matrix, stringsAsFactors=FALSE)
    names(gp_df) = c("word", "x", "y")
    gp_df$x = as.numeric(gp_df$x)
    gp_df$y = as.numeric(gp_df$y)
    se = diag(affi_matrix) / max(diag(affi_matrix))
    words_km = kmeans(cbind(as.numeric(posi_matrix[,2]), as.numeric(posi_matrix[,3])), k_cluster)
    w_size <- diag(affi_matrix)^(0.1)
    gp_df = transform(gp_df, freq=w_size, cluster=as.factor(words_km$cluster))
    V <- voronoi.mosaic(words_km$centers[,1],words_km$centers[,2])
    P <- voronoi.polygons(V)
    voro <- deldir(words_km$centers[,1],words_km$centers[,2])
    row.names(gp_df) = 1:nrow(gp_df)
    gLabel <- c("","",paste(varList[iN]," by ",varList[oN]),"")
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

}





