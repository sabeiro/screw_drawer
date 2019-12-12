#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library(neuralnet)
library(car)


varList <- c("AdvertiserName","cat","Section","Channel","Site","Publisher","DeviceType","Size")
varLoopIn <- NULL#c(1,1,1,1,1,1,8,8,8,8,8,8)
varLoopOut<- NULL#c(2,3,4,5,6,7,2,3,4,5,6,7)
for(i in 1:(length(varList)-1)){
    for(j in (i+1):length(varList)){
    varLoopIn <- c(varLoopIn,i)
    varLoopOut <- c(varLoopOut,j)
    }
}

k <- 1
for(k in 1:length(varLoopIn)){
    iN <- varLoopIn[k]
    oN <- varLoopOut[k]
    ##if(any(k == c(8:12)) ){next}
    print(paste(k,varList[iN],varList[oN]))
    advI <- read.csv(paste("out/train/advCorrImps",varList[iN],varList[oN],".csv",sep=""),sep=",")
    advC <- read.csv(paste("out/train/advCorrCtr",varList[iN],varList[oN],".csv",sep=""),sep=",")
    ## advP <- sapply(colnames(advC),function(x) mean(advC[,colnames(advC) == x]) < advC[,colnames(advC)] )
    testidx <- round(runif(nrow(advC)/20,1,nrow(advC)))
    advTrain <- advC[-testidx,]
    advTest <- advC[testidx,]
    model <- lm(formula="X ~ .",data=advTrain)
    ##model$xlevels[[grp]] <- union(model$xlevels[[grp]], levels(advTest[,grp]))
    ##advTest$prediction <- predict(model,newdata=advTest)

    depC1 <- model$coefficients[order(-abs(model$coefficients))]
    depC <- data.frame(site=names(depC1),ctr=depC1,group="train")
    write.csv(depC,paste("out/train/coeff",varList[iN],varList[oN],".csv",sep=""))
    melted <- melt(depC)
    melted$site <- factor(melted$site,levels=melted$site)
    melted <- melted[!grepl("intercept",melted$site),]
    NShow <- 30
    melted <- melted[1:min(NShow,nrow(melted)),]
    gLabel = c(varList[oN],varList[iN],paste("coefficient influence"),"group")
    p <- ggplot() +
        geom_bar(data=melted,aes(x=site,y=value,fill=value),stat="identity") +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
    p
    fName <- paste("figLearn/logistic",varList[iN],varList[oN],".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
}


