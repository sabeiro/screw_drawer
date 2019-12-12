#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')
library(neuralnet)
library(car)
library(plyr)
library(dplyr)
library(randomForest)
library(rpart)
library(caret)

fs <- read.csv("raw/adv2015short.csv")
largeA <- table(fs$AdvertiserName)

ad <- names(largeA)[2]
for(ad in names(largeA)){
    advList <- fs[fs$AdvertiserName==ad,c("Publisher","Site","Channel","Section","Size","DeviceType","Ctr..")]
    advList <- fs[fs$AdvertiserName==ad,c("Site","Size","DeviceType","Ctr..")]
    print(paste(ad,nrow(advList)))
    testidx <- sample(1:nrow(advList))[1:(round(nrow(advList))*.5)]
    advTrain <- advList[-testidx,]
    advTest <- advList[testidx,]
    advTrain = advTrain[1:100,]
    advTest = advTest[1:100,]
    
    model <- lm(formula="Ctr.. ~ .",data=advTrain)
    modelRF <- randomForest(Ctr.. ~ .,data=advTrain,ntree=100)
    modelPart <- rpart(Ctr..~.,data=advTrain,method="class")
    fitControl <- trainControl(method = "repeatedcv",number = 10,repeats = 10)
    tuneGrid <- data.frame(interaction.depth = 4,n.trees = 100,shrinkage = .1,n.minobsinnode = 20)
    ## gridGbm <- expand.grid(interaction.depth = c(1, 5, 9),n.trees = (1:30)*50,shrinkage = 0.1,n.minobsinnode = 20)
    modelGbm <- train(Ctr.. ~ ., data = advTrain,method = "gbm",verbose=F,tuneGrid=tuneGrid)##,trControl = fitControl,tuneGrid = gridGbm)
    ##    whichTwoPct <- tolerance(modelGbm$results, metric = "ROC",tol = 2, maximize = TRUE)
    

    
    ##model$xlevels[[grp]] <- union(model$xlevels[[grp]], levels(advTest[,grp]))
    advTest$prediction <- predict(model,newdata=advTest)
    advTest$predictionRF <- predict(modelRF,newdata=advTest)

    centroids <- classDist(advTrain,advTest)
    distances <- predict(centroids, testBC)
    distances <- as.data.frame(distances)
    head(distances)
    
    n <- nrow(advTrain)
    K <- 10
    block <- n%/%K
    set.seed(5)
    alea <- runif(n)
    rang <- rank(alea)
    bloc <- (rang-1) %/% block + 1
    bloc <- as.factor(bloc)
    print(summary(bloc))
    all.err <- NULL
    for(k in i:K){
        tree <- rpart(Species~.,data=iris[bloc!=k,],method="class")
        pred <- predict(tree,newdata=iris[bloc==k,],type="class")
        mc <- table(iris$Species[bloc==k],pred)
        err <- 1.0 - sum((diag(mc)))/sum(mc)
        all.err <- rbind(all.err,err)
    }
    

    
    depC1 <- model$coefficients[order(-model$coefficients)]
    depC <- data.frame(site=names(depC1),ctr=depC1,group="train")
    grp <- "Site"
    advTest$x <- advTest[,grp]
    depC1 <- depC[grepl(grp,depC$site),]
    depC1$site <- gsub(grp,"",depC1$site)
    NShow <- 30
    depC1 <- depC1[1:NShow,]
    depC1$site <- factor(depC1$site,levels=depC1$site)
    advTest <- advTest[1:min(NShow,nrow(advTest)),]
    corR <- round(cor(advTest$prediction, advTest[,"Ctr.."]),digits=2)
    gLabel = c(grp,"correlation",paste("metric",grp,"correlation",corR,"ad",ad),"group")
    p <- ggplot() +
        geom_line(data=depC1,aes(x=site,y=ctr,color="train",group="train"),size=2) +
        geom_point(data=advTest,aes(x=x,y=Ctr..,group="test"),color=gCol1[2],size=4) +
        geom_point(data=advTest,aes(x=x,y=prediction,group="prediction"),color=gCol1[3],size=4) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
    p
    fName <- paste("figPredict/logistic",grp,".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

}


data <- iris
glimpse(data)
k = 5
data$id <- sample(1:k, nrow(data), replace = TRUE)
list <- 1:k
prediction <- NULL
testsetCopy <- NULL
for(i in 1:k){
    trainingset <- subset(data, id %in% list[-i])
    testset <- subset(data, id %in% c(i))
    mymodel <- randomForest(trainingset$Sepal.Length~.,data=trainingset,ntree=100)
    prediction <- rbind(prediction,as.data.frame(predict(mymodel,testset[,-1])))
    testsetCopy <- rbind(testsetCopy, as.data.frame(testset[,1]))
}
result <- cbind(prediction, testsetCopy[, 1])
names(result) <- c("Predicted", "Actual")
result$Difference <- abs(result$Actual - result$Predicted)
hist(result$Difference,type="l")
summary(result$Difference)

tree <- rpart(Species~.,data=iris,method="class")
pred <- predict(tree,newdata=iris,type="class")
mc <- table(iris$Species,pred)
print(mc)
err.resub <- 1.0 - sum((diag(mc)))/sum(mc)
err.cv <- mean(all.err)

library(AppliedPredictiveModeling)
transparentTheme(trans = .4)
featurePlot(x = iris[, 1:4],y = iris$Species,plot = "pairs",auto.key = list(columns = 3))
featurePlot(x = iris[, 1:4],y = iris$Species,plot = "ellipse",auto.key = list(columns = 3))
featurePlot(x = iris[, 1:4],y = iris$Species,plot = "density",scales = list(x = list(relation="free"),y=list(relation="free")),adjust = 1.5,pch = "|",layout = c(4, 1),auto.key = list(columns = 3))
featurePlot(x = iris[, 1:4],y = iris$Species,plot = "box",scales = list(y = list(relation="free"),x = list(rot = 90)),layout = c(4,1 ),auto.key = list(columns = 2))

library(party)
set.seed(1234)
ind <- sample(2,nrow(iris),replace=TRUE,prob=c(.7,.3))
train.data <-  iris[ind==1,]
test.data <- iris[ind==2,]
form <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_ctree <- ctree(form,data=train.data)
table(predict(iris_ctree),train.data$Species)
plot(iris_ctree,type="simple")
testPred <- predict(iris_ctree,newdata=test.data)
table(testPred,test.data$Species)


iris_ctree <- rpart(form,data=train.data,control=rpart.control(minsplit=10))
plot(iris_ctree)
text(iris_ctree,use.n=T)
opt <- which.min(iris_ctree$cptable[,"xerror"])
cp <- iris_ctree$cptable[opt,"CP"]
iris_prune <- prune(iris_ctree,cp=cp)
plot(iris_prune)
text(iris_prune,use.n=T)
iris_pred <- predict(iris_prune,newdata=test.data)

iris_rf <- randomForest(form,data=train.data,ntree=100,proximity=T)
table(predict(iris_rf),train.data$Species)
print(iris_rf)
importance(iris_rf)
varImpPlot(iris_rf)
