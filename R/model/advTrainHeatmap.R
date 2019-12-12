#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
source('script/advTrain.R')

x <- as.character(advTrain$Channel)
x <- sapply(x,function(X) digest(as.character(X),algo="sha1",serialize=FALSE))
hs <- as.list(hash(keys=unique(x),values=1:length(unique(x))))
x <- unlist(hs[x])
y <- as.character(advTrain$cat)
y <- sapply(y,function(X) digest(as.character(X),algo="sha1",serialize=FALSE))
hs <- as.list(hash(keys=unique(y),values=1:length(unique(y))))
y <- unlist(hs[y])
z <- as.numeric(advTrain$Ctr)

cumprob <- c(0.20,0.80)
melted <- data.frame(x=x,y=y,z=z)
impsSum <- as.matrix(xtabs(z ~ x + y,melted))
lim <- quantile(rowSums(impsSum),cumprob)
impsSum <- impsSum[rowSums(impsSum) > lim[1] & rowSums(impsSum) < lim[2],]
lim <- quantile(colSums(impsSum),cumprob)
impsSum <- impsSum[,colSums(impsSum) > lim[1] & colSums(impsSum) < lim[2] ]

melted <- melt(impsSum)
melted$x <- sapply(melted$x,function(X) digest(as.character(X),algo="sha1",serialize=FALSE))
hs <- as.list(hash(keys=unique(melted$x),values=1:length(unique(melted$x))))
melted$x <- unlist(hs[melted$x])
melted$y <- sapply(melted$y,function(X) digest(as.character(X),algo="sha1",serialize=FALSE))
hs <- as.list(hash(keys=unique(melted$y),values=1:length(unique(melted$y))))
melted$y <- unlist(hs[melted$y])
melted$value[melted$value<=0.000] <- 0.0001
melted$value <- rnorm(n=length(melted$value),mean=melted$value,sd=0.01)

gLabel = c("categoria merceologica","sezione",paste("ctr campaign","2015"),"percentuale")
p <- ggplot(melted,aes(x=x,y=y,fill=(value),group=y)) +
    geom_tile(colour="white") +
    ##geom_text(aes(fill=viewability,label=round(viewability*100)),colour="white",size=24) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
    scale_fill_gradient(low="white",high="steelblue") +
    theme(
        axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
                panel.background = element_blank()
    )
p

