##https://dzone.com/refcardz/machine-learning-predictive
##http://www.cs.toronto.edu/~delve/data/datasets.html
##http://rodrigob.github.io/are_we_there_yet/build/classification_datasets_results.html
##http://yann.lecun.com/exdb/mnist/
##http://archive.ics.uci.edu/ml/datasets.html?sort=nameUp&view=list
data(iris)
summary(iris)
head(iris)
testidx <- which(1:length(iris[,1])%%5 == 0)
iristrain <- iris[-testidx,]
iristest <- iris[testidx,]
##predictive model
library(car)
summary(Prestige)
head(Prestige)
testidx <- which(1:nrow(Prestige)%%4==0)
prestige_train <- Prestige[-testidx,]
prestige_test <- Prestige[testidx,]
##linear regression
model <- lm(prestige~., data=prestige_train)
prediction <- predict(model, newdata=prestige_test)
cor(prediction, prestige_test$prestige)
summary(model)
lm(formula = prestige ~ ., data = prestige_train)
##logistic regression
newcol = data.frame(isSetosa=(iristrain$Species == 'setosa'))
traindata <- cbind(iristrain, newcol)
head(traindata)
formula <- isSetosa ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
logisticModel <- glm(formula, data=traindata, family="binomial")
prob <- predict(logisticModel, newdata=iristest, type='response')
round(prob, 3)
##regression with regularization
library(glmnet)
cv.fit <- cv.glmnet(as.matrix(prestige_train[,c(-4, -6)]), as.vector(prestige_train[,4]), nlambda=100, alpha=0.7, family="gaussian")
plot(cv.fit)
coef(cv.fit)
prediction <- predict(cv.fit, newx=as.matrix(prestige_test[,c(-4, -6)]))
cor(prediction, as.vector(prestige_test[,4]))
##neuronal network
library(neuralnet)
nnet_iristrain <-iristrain
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'setosa')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'versicolor')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'virginica')
names(nnet_iristrain)[6] <- 'setosa'
names(nnet_iristrain)[7] <- 'versicolor'
names(nnet_iristrain)[8] <- 'virginica'
nn <- neuralnet(setosa+versicolor+virginica ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data=nnet_iristrain, hidden=c(3))
plot(nn)
mypredict <- compute(nn, iristest[-5])$net.result
maxidx <- function(arr) {
    return(which(arr == max(arr)))
}
idx <- apply(mypredict, c(1), maxidx)
prediction <- c('setosa', 'versicolor', 'virginica')[idx]
table(prediction, iristest$Species)
##support vector machine
library(e1071)
tune <- tune.svm(Species~., data=iristrain, gamma=10^(-6:-1), cost=10^(1:4))
summary(tune)
model <- svm(Species~., data=iristrain, method="C-classification", kernel="radial", probability=T, gamma=0.001, cost=10000)
prediction <- predict(model, iristest, probability=T)
table(iristest$Species, prediction)
##naive bayesian
library(e1071)
model <- naiveBayes(Species~., data=iristrain)
prediction <- predict(model, iristest[,-5])
table(prediction, iristest[,5])
boxplot(iristrain$Petal.Length ~ iristrain$Species)
##k-nearest neighbors
library(class)
train_input <- as.matrix(iristrain[,-5])
train_output <- as.vector(iristrain[,5])
test_input <- as.matrix(iristest[,-5])
prediction <- knn(train_input, test_input, train_output, k=5)
table(prediction, iristest$Species)
##decision tree
library(rpart)
                                        #Train the decision tree
treemodel <- rpart(Species~., data=iristrain)
plot(treemodel)
text(treemodel, use.n=T)
                                        #Predict using the decision tree
prediction <- predict(treemodel, newdata=iristest, type='class')
                                        #Use contingency table to see how accurate it is
table(prediction, iristest$Species)
names(nnet_iristrain)[8] <- 'virginica'
##random forest
library(randomForest)
                                        #Train 100 trees, random selected attributes
model <- randomForest(Species~., data=iristrain, nTree=500)
                                        #Predict using the forest
prediction <- predict(model, newdata=iristest, type='class')
table(prediction, iristest$Species)
importance(model)
library(gbm)
iris2 <- iris
newcol = data.frame(isVersicolor=(iris2$Species=='versicolor'))
newcol = data.frame(isVersicolor=(iris2$Species=='setosa'))
newcol = data.frame(isVersicolor=(iris2$Species=='virginica'))
iris2 <- cbind(iris2, newcol)
iris2[45:55,]
formula <- isVersicolor ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
model <- gbm(formula, data=iris2, n.trees=1000, interaction.depth=2, distribution="bernoulli")
prediction <- predict.gbm(model, iris2[45:55,], type="response", n.trees=1000)
round(prediction, 3)
summary(model)

#http://ww2.coastal.edu/kingw/statistics/R-tutorials/logistic.html
#http://www.ats.ucla.edu/stat/r/dae/logit.htm

setwd("C:/Users/giovanni.marelli/lav/media/")
library("MASS")
data(menarche)
str(menarche)
summary(menarche)
glm.out = glm(cbind(Menarche, Total-Menarche) ~ Age,family=binomial(logit), data=menarche)
plot(Menarche/Total ~ Age, data=menarche)
lines(menarche$Age, glm.out$fitted, type="l", col="red")
title(main="Menarche Data with Fitted Logistic Regression Line")
summary(glm.out)
anova(glm.out)

file <- 'raw/gorilla.csv'
read.csv(file) -> gorilla
str(gorilla)
cor(gorilla)
glm.out = glm(seen ~ W * C * CW, family=binomial(logit), data=gorilla)
summary(glm.out)
anova(glm.out, test="Chisq")
1 - pchisq(8.157, df=7)
plot(glm.out$fitted)
abline(v=30.5,col="red")
abline(h=.3,col="green")
abline(h=.5,col="green")
text(15,.9,"seen = 0")
text(40,.9,"seen = 1")


ftable(UCBAdmissions, col.vars="Admit")
dimnames(UCBAdmissions)
margin.table(UCBAdmissions, c(2,1))
ucb.df = data.frame(gender=rep(c("Male","Female"),c(6,6)),dept=rep(LETTERS[1:6],2),yes=c(512,353,120,138,53,22,89,17,202,131,94,24),no=c(313,207,205,279,138,351,19,8,391,244,299,317))
mod.form = "cbind(yes,no) ~ gender * dept"
glm.out = glm(mod.form, family=binomial(logit), data=ucb.df)
options(show.signif.stars=F)
anova(glm.out, test="Chisq")
summary(glm.out)



library(aod)
library(ggplot2)
mydata <- read.csv('raw/binary.csv')
head(mydata)
summary(mydata)
sapply(mydata, sd)
xtabs(~admit + rank, data = mydata)
mydata$rank <- factor(mydata$rank)
mylogit <- glm(admit ~ gre + gpa + rank, data = mydata, family = "binomial")
summary(mylogit)
confint(mylogit)
confint.default(mylogit)
wald.test(b = coef(mylogit), Sigma = vcov(mylogit), Terms = 4:6)
l <- cbind(0, 0, 0, 1, -1, 0)
wald.test(b = coef(mylogit), Sigma = vcov(mylogit), L = l)
exp(coef(mylogit))
exp(cbind(OR = coef(mylogit), confint(mylogit)))
newdata1 <- with(mydata, data.frame(gre = mean(gre), gpa = mean(gpa), rank = factor(1:4)))
newdata1$rankP <- predict(mylogit, newdata = newdata1, type = "response")
newdata1
newdata2 <- with(mydata, data.frame(gre = rep(seq(from = 200, to = 800, length.out = 100),
    4), gpa = mean(gpa), rank = factor(rep(1:4, each = 100))))
newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type = "link",
    se = TRUE))
newdata3 <- within(newdata3, {
    PredictedProb <- plogis(fit)
    LL <- plogis(fit - (1.96 * se.fit))
    UL <- plogis(fit + (1.96 * se.fit))
})

## view first few rows of final dataset
head(newdata3)
ggplot(newdata3, aes(x = gre, y = PredictedProb)) + geom_ribbon(aes(ymin = LL,
    ymax = UL, fill = rank), alpha = 0.2) + geom_line(aes(colour = rank),
    size = 1)
with(mylogit, null.deviance - deviance)
with(mylogit, df.null - df.residual)
with(mylogit, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))
logLik(mylogit)


##http://machinelearningmastery.com/compare-the-performance-of-machine-learning-algorithms-in-r/
# load libraries
library(mlbench)
library(caret)
# load the dataset
data(PimaIndiansDiabetes)

# prepare training scheme
control <- trainControl(method="repeatedcv", number=10, repeats=3)
# CART
set.seed(7)
fit.cart <- train(diabetes~., data=PimaIndiansDiabetes, method="rpart", trControl=control)
# LDA
set.seed(7)
fit.lda <- train(diabetes~., data=PimaIndiansDiabetes, method="lda", trControl=control)
# SVM
set.seed(7)
fit.svm <- train(diabetes~., data=PimaIndiansDiabetes, method="svmRadial", trControl=control)
# kNN
set.seed(7)
fit.knn <- train(diabetes~., data=PimaIndiansDiabetes, method="knn", trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(diabetes~., data=PimaIndiansDiabetes, method="rf", trControl=control)
# collect resamples
results <- resamples(list(CART=fit.cart, LDA=fit.lda, SVM=fit.svm, KNN=fit.knn, RF=fit.rf))
# summarize differences between modes
summary(results)
scales <- list(x=list(relation="free"), y=list(relation="free"))
bwplot(results, scales=scales)
scales <- list(x=list(relation="free"), y=list(relation="free"))
densityplot(results, scales=scales, pch = "|")
scales <- list(x=list(relation="free"), y=list(relation="free"))
dotplot(results, scales=scales)
# parallel plots to compare models
parallelplot(results)
# pair-wise scatterplots of predictions to compare models
splom(results)
# xyplot plots to compare models
xyplot(results, models=c("LDA", "SVM"))
# difference in model predictions
diffs <- diff(results)
# summarize p-values for pair-wise comparisons
summary(diffs)



library(neuralnet)
data(iris)
summary(iris)
head(iris)
colnames(iris) <- c("size","duration","av.time","bounce.rate","Species")
iris$bounce.rate <- iris$bounce.rate*10
hashT <- data.frame(id1=c("setosa","versicolor","virginica"), id2=c("food","banking","fashion"))
set <- match(x=iris$Species,table=hashT$id1)
iris$Species <- hashT$id2[set]
testidx <- which(1:length(iris[,1])%%5 == 0)
iristrain <- iris[-testidx,]
iristest <- iris[testidx,]



nnet_iristrain <-iristrain
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'food')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'banking')
nnet_iristrain <- cbind(nnet_iristrain, iristrain$Species == 'fashion')
names(nnet_iristrain)[6] <- 'food'
names(nnet_iristrain)[7] <- 'banking'
names(nnet_iristrain)[8] <- 'fashion'
nn <- neuralnet(food+banking+fashion ~ size + duration + av.time + bounce.rate, data=nnet_iristrain, hidden=c(3))
plot(nn)
mypredict <- compute(nn, iristest[-5])$net.result
maxidx <- function(arr) {
    return(which(arr == max(arr)))
}
idx <- apply(mypredict, c(1), maxidx)
prediction <- c('food', 'banking', 'virginica')[idx]
table(prediction, iristest$Species)
##support vector machine
library(rpart)
                                        #Train the decision tree
treemodel <- rpart(Species~., data=iristrain)
plot(treemodel)
text(treemodel, use.n=T)
                                        #Predict using the decision tree
prediction <- predict(treemodel, newdata=iristest, type='class')
                                        #Use contingency table to see how accurate it is
table(prediction, iristest$Species)
names(nnet_iristrain)[8] <- 'virginica'
