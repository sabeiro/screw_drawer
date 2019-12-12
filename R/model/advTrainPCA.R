#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')
source('script/graphEnv.R')

library("FactoMineR")
library("factoextra")
library("PerformanceAnalytics")
# install.packages("corrplot")
library("corrplot")


varList <- c("AdvertiserName","cat","Section","Channel","Site","Publisher","DeviceType","Size")
varLoopIn <- NULL
varLoopOut<- NULL
for(i in 1:(length(varList)-1)){
    for(j in (i+1):length(varList)){
    varLoopIn <- c(varLoopIn,i)
    varLoopOut <- c(varLoopOut,j)
    }
}
cumprob = 0.40
k <- 1
for(k in 1:length(varLoopIn)){
    iN <- varLoopIn[k]
    oN <- varLoopOut[k]
    ##if(any(k == c(8:12)) ){next}
    print(paste(k,varList[iN],varList[oN]))
    advI <- read.csv(paste("out/train/advCorrImps",varList[iN],varList[oN],".csv",sep=""),sep=",",row.names=1)
    advC <- as.matrix(read.csv(paste("out/train/advCorrCtr",varList[iN],varList[oN],".csv",sep=""),sep=",",row.names=1))


    limC <- quantile(colSums(advI),cumprob)
    set <- colSums(advI)>limC
    advC <- advC[set,set]
    ##diag(advC) <- 0
    set <- !colnames(advC) %in% c("pharmaceutics.")
    set <- set & !colnames(advC) %in% c("car.cheap")
    set <- set & !colnames(advC) %in% c("food.")
    set <- set & !colnames(advC) %in% c("food.distribution")
    advC <- advC[set,set]

    res.pca <- PCA(advC, graph = FALSE)
    ## eigenvalues <- res.pca$eig
    ## barplot(eigenvalues[, 2], names.arg=1:nrow(eigenvalues),main = "Variances",xlab = "Principal Components",ylab = "Percentage of variances",col ="steelblue")
    ## lines(x = 1:nrow(eigenvalues), eigenvalues[, 2],type="b", pch=19, col = "red")
    plot(res.pca, choix = "var")
    plot(res.pca, choix = "ind")



}





## corrplot(cor.mat, type="upper", order="hclust",   tl.col="black", tl.srt=45)
## chart.Correlation(decathlon2.active[, 1:6], histogram=TRUE, pch=19)


