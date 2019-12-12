library(caret)
library(fpp)


creditlog  <- data.frame(score=credit$score,
                         log.savings=log(credit$savings+1),
                         log.income=log(credit$income+1),
                         log.address=log(credit$time.address+1),
                         log.employed=log(credit$time.employed+1),
                         fte=credit$fte, single=credit$single)
fit  <- avNNet(score ~ log.savings + log.income + log.address +
                   log.employed, data=creditlog, repeats=25, size=3, decay=0.1,
               linout=TRUE)
fit <- nnetar(sunspotarea)
plot(forecast(fit,h=20))
