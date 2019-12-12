library(mlbench)
data(Sonar)

library(caret)
set.seed(998)
inTraining <- createDataPartition(Sonar$Class, p = .75, list = FALSE)
training <- Sonar[ inTraining,]
testing  <- Sonar[-inTraining,]

fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10,
                           classProbs = TRUE,
                           summaryFunction = twoClassSummary,
                           search = "random")

set.seed(825)
rda_fit <- train(Class ~ ., data = training, 
                  method = "rda",
                  metric = "ROC",
                  tuneLength = 30,
                  trControl = fitControl)
rda_fit
ggplot(rda_fit) + theme(legend.position = "top")
