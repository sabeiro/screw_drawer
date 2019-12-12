#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')

cumprob <- 0.50
NShow <- 30
##--------------------------dotandad------------------------------
if(FALSE){
    fs <- read.csv(file='raw/priceModel.csv',stringsAsFactor=FALSE,sep=",",row.names=NULL, fileEncoding="UTF-8")
    colnames(fs) <- c("site","channel","format","FlightPrice","price","client","imps","click","ctr","action","registration","smart.passback")
}
if(TRUE){
    fs <- read.csv("raw/storicoERPSite.csv",sep=",",stringsAsFactor=FALSE,fileEncoding="UTF-8")
##    colnames(fs) <- c("n","price","format","centro.media","client","imps","imps.free","site")
    colnames(fs) <- c("n","price","client","package","imps_free","imps","format","pos","site")
    fs$price <- fs$price*.85
    formatL <- c("1/2 PAG.ORIZ","1/2 PAG.VERT","Android","AUDIENCE ADS","BRANDED CHANNEL","COLONNA","Custom","Dem","DOPPIA PAGIN","Entertainment Take Over","FINESTRELLA","IICOP+I^ROMA","Ipad Display","iPhone","Listening Take Over","MANCH.TEST","MARCHIO","Minisito","Mobile Display","MODULI","Native Header","NATIVE POST","Newsletter","PAGINA","PARTNERSHIP","Picture in Picture","Post FB","Pre-Roll Audio","Publiredazionale","rest","Set Up Speciali","SHAZAM FOR TV","SHAZAM VISUAL","Sky","Slider","Speciali","SPONSORED POST","SPONSORED VIDEO","STORY AND BLOG","Strip")
    formatL <- c("FloorAd","Half Page","Intro","Leaderboard","Masthead","Overlayer","Pre-Roll Video","PromoBox","Rectangle","Rectangle Exp-Video","Skin","Splash Page")
    fs <- fs[fs$format %in% formatL,]
    fs$imps <- fs$imps + fs$imps_free
}
##---------------------filter-out-tails------------------------
fs <- fs[!is.na(fs$imps),]
fs <- fs[!fs$imps==0,]
fs$cpm <- fs$price/fs$imps*1000
## lim <- quantile(fs$cpm,c(0.1,0.9))
## fs <- fs[fs$cpm>lim[1] & fs$cpm < lim[2],]

ggplot(fs) + geom_density(aes(x=cpm),fill=gCol1[1]) + scale_x_log10()

agC <- ddply(fs,.(client),summarise,imps=sum(imps,na.rm=T),price=sum(price,na.rm=T))
agC$cpm <- agC$price/agC$imps*1000
lim = quantile(agC$imps,0.50)
agC <- agC[agC$imps>lim,]
agC <- agC[rev(order(agC$cpm)),]
agC$client <- factor(agC$client,levels=agC$client[rev(order(agC$cpm))])
   
agF <- ddply(fs,.(format),summarise,imps=sum(imps,na.rm=T),price=sum(price,na.rm=T))
agF$cpm <- agF$price/agF$imps*1000
## lim = quantile(agF$imps,0.50)
## agF <- agF[agF$imps>lim,]
agF <- agF[rev(order(agF$cpm)),]
agF$format <- factor(agF$format,levels=agF$format[rev(order(agF$cpm))])

agS <- ddply(fs,.(site),summarise,imps=sum(imps,na.rm=T),price=sum(price,na.rm=T))
agS$cpm <- agS$price/agS$imps*1000
lim = quantile(agS$imps,0.50)
agS <- agS[agS$imps>lim,]
agS <- agS[rev(order(agS$cpm)),]
agS$site <- factor(agS$site,levels=agS$site[rev(order(agS$cpm))])

agSF <- ddply(fs,.(site,format),summarise,imps=sum(imps,na.rm=T),price=sum(price))
agSF$cpm <- agSF$price/agSF$imps*1000
total <-  c(sum(agSF$imps),sum(agSF$price))
agSF <- agSF[!is.na(match(agSF$site,agS$site)),]
agSF <- agSF[!is.na(match(agSF$format,agF$format)),]
rest <-  c(sum(agSF$imps),sum(agSF$price))
rest <- total - rest
rest <-  list("rest","rest",rest[1],rest[2],rest[2]/rest[1]*1000)
agSF[nrow(agSF)+1,] <- rest
orderS <- ddply(agSF,.(site),summarise,cpm=sum(cpm))
agSF$site <- factor(agSF$site,levels=orderS$site[rev(order(orderS$cpm))])

total <-  c(sum(fs[,"price"],na.rm=T),sum(fs[,"imps"]))
fs <- fs[!is.na(match(fs$site,agS$site)),]
fs <- fs[!is.na(match(fs$format,agF$format)),]
fs <- fs[!is.na(match(fs$client,agC$client)),]
rest <-  c(sum(fs[,"price"],na.rm=T),sum(fs[,"imps"]))
rest <- total - rest
nLast <- nrow(fs)+1
fs[nLast,"price"] <- rest[1]
fs[nLast,"imps"] <- rest[2]
fs[nLast,"cpm"] <- rest[1]/rest[2]
fs[nLast,sapply(fs[nLast,],function(x) typeof(x))=="character"] <- "rest"
fs <- fs[order(-fs$price),]

melted <- fs[!is.na(match(fs$site,agS$site)),]
melted$site <- factor(melted$site,levels=agS$site)
gLabel = c("site","cpm",paste("cpm distribution"),"site")
p <- ggplot(melted) +
    geom_boxplot(aes(x=site,y=cpm,color=site)) +
    geom_text(data=agS,aes(x=site,y=cpm,label=round(cpm,1))) +
    scale_y_continuous(limits = quantile(melted$cpm,c(0.1,0.9))) +
    theme(legend.position="none") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
p

melted <- fs[!is.na(match(fs$format,agF$format)),]
melted$format <- factor(melted$format,levels=agF$format)
gLabel = c("site","cpm",paste("cpm distribution"),"site")
p <- ggplot(melted) +
    geom_boxplot(aes(x=format,y=cpm,color=format)) +
    geom_text(data=agF,aes(x=format,y=cpm,label=round(cpm,1))) +
    scale_y_continuous(limits = quantile(melted$cpm,c(0.1,0.9))) +
    theme(legend.position="none") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
p

gLabel = c("site","cpm",paste("cpm distribution"),"site")
p <- ggplot(agSF) +
    geom_bar(aes(x=site,y=cpm,fill=site),stat="identity") +
    geom_text(aes(x=site,y=cpm/2,label=round(cpm,1)),stat="identity") +
    facet_grid(format ~ .) +
    theme(legend.position="none") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p


ag <- ddply(fs,.(site),summarise,imps=sum(imps,na.rm=TRUE),price=sum(price,na.rm=TRUE))
ag$price <- ag$price/1000000
ag <- ag[order(-ag$price),]
ag <- ag[1:min(30,nrow(ag)),]
ag$site <- factor(ag$site,levels=ag$site)

gLabel = c("site","revenue ME",paste("daily revenue distribution"),"site")
p <- ggplot(ag) +
    geom_bar(aes(x=site,y=price,fill=site),stat="identity") +
    geom_text(aes(x=site,y=price/2,label=round(price,1)),stat="identity") +
    theme(legend.position="none") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

set <- fs$format %in% agF$format | fs$client %in% agC$client | fs$site %in% agS$site
ag <- fs[set,]
ag <- ag[ag$imps>quantile(ag$imps,0.4) & ag$imps<quantile(ag$imps,0.6),]
nrow(ag)
ag$impC <- cut(ag$imps,breaks=seq(0,max(ag$imps),max(ag$imps)/10),labels=1:10)
fit <- lm(cpm ~ impC + format + client + site,data=ag)
summary(fit)
fit1 <- lm(cpm ~ impC + format + client + site,data=ag)
fit2 <- lm(cpm ~ format + client,data=ag)
anova(fit1, fit2) 


cf <- coefficients(fit) # model coefficients
nVar <- "client"
nVar <- "site"
nVar <- "format"
acF <- data.frame(var=names(cf[grepl(nVar,names(cf))]),value=cf[grepl(nVar,names(cf))])
acF$var <- gsub(nVar,"",acF$var)
acF <- acF[order(-acF$value),]
acF$var <- factor(acF$var,levels=acF$var)
if(nrow(acF)>40){
    ##acF <- acF[acF$value<quantile(acF$value,0.05) | acF$value>quantile(acF$value,0.95),]
    acF <- acF[c(1:20,(nrow(acF)-20):nrow(acF)),]
}

gLabel = c(nVar,"coefficient",paste("influence on cpm"),nVar)
p <- ggplot(acF) +
    geom_bar(aes(x=var,y=value,fill=var),stat="identity") +
    geom_text(aes(x=var,y=value/2,label=round(value,1)),stat="identity") +
    theme(legend.position="none") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

confint(fit, level=0.95) # CIs for model parameters
fitted(fit) # predicted values
residuals(fit) # residuals
anova(fit) # anova table
vcov(fit) # covariance matrix for model parameters
influence(fit) # regression diagnostics 

# diagnostic plots
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
plot(fit)

## library(DAAG)
## cv.lm(data=ag, fit, m=3) # 3 fold cross-validation

library(MASS)
step <- stepAIC(fit, direction="both")
step$anova # display results 

# All Subsets Regression
library(leaps)
leaps<-regsubsets(cpm ~ format + client,data=ag[1:500,],nbest=10,really.big=T)
summary(leaps)
# plot a table of models showing variables in each model.
# models are ordered by the selection statistic.
plot(leaps,scale="r2")
# plot statistic by subset size
library(car)
subsets(leaps, statistic="rsq") 

# Calculate Relative Importance for Each Predictor
library(relaimpo)
calc.relimp(fit,type=c("lmg","last","first","pratt"),
   rela=TRUE)

# Bootstrap Measures of Relative Importance (1000 samples)
boot <- boot.relimp(fit, b = 1000, type = c("lmg",
  "last", "first", "pratt"), rank = TRUE,
  diff = TRUE, rela = TRUE)
booteval.relimp(boot) # print result
plot(booteval.relimp(boot,sort=TRUE)) # plot result 

library(bootstrap)
theta.fit <- function(x,y){lsfit(x,y)}
theta.predict <- function(fit,x){cbind(1,x)%*%fit$coef}

# matrix of predictors
X <- as.matrix(ag[c("impC","format","client")])
# vector of predicted values
y <- as.matrix(ag[c("cpm")])

results <- crossval(X,y,theta.fit,theta.predict,ngroup=10)
cor(y, fit$fitted.values)**2 # raw R2
cor(y,results$cv.fit)**2 # cross-validated R2 




library(car)
fit <- lm(mpg~disp+hp+wt+drat, data=mtcars)
outlierTest(fit) # Bonferonni p-value for most extreme obs
qqPlot(fit, main="QQ Plot") #qq plot for studentized resid
leveragePlots(fit) # leverage plots
# Influential Observations
# added variable plots
av.Plots(fit)
# Cook's D plot
# identify D values > 4/(n-k-1)
cutoff <- 4/((nrow(mtcars)-length(fit$coefficients)-2))
plot(fit, which=4, cook.levels=cutoff)
# Influence Plot
influencePlot(fit, id.method="identify", main="Influence Plot", sub="Circle size is proportial to Cook's Distance" )
av plots
# Normality of Residuals
# qq plot for studentized resid
qqPlot(fit, main="QQ Plot")
# distribution of studentized residuals
library(MASS)
sresid <- studres(fit)
hist(sresid, freq=FALSE,
   main="Distribution of Studentized Residuals")
xfit<-seq(min(sresid),max(sresid),length=40)
yfit<-dnorm(xfit)
lines(xfit, yfit)
# Evaluate homoscedasticity
# non-constant error variance test
ncvTest(fit)
# plot studentized residuals vs. fitted values
spreadLevelPlot(fit)
# Evaluate Collinearity
vif(fit) # variance inflation factors
sqrt(vif(fit)) > 2 # problem?
crPlots(fit)
# Ceres plots
ceresPlots(fit)
# Test for Autocorrelated Errors
durbinWatsonTest(fit)

