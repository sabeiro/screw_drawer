#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
source('script/graphEnv.R')
library(gtools)
library(shiny)
library(plotly)



cumprob=c(0.04,0.96)
##--------------------------------load file direct
fs <- read.csv('raw/priceQ1.csv')
set <- grepl("WIDESPACE",fs$AdvertiserName) || grepl("PUBMATIC",fs$AdvertiserName) || grepl("GOOGLE",fs$AdvertiserName) || grepl("XAXIS",fs$AdvertiserName) || grepl("PRIME",fs$AdvertiserName) || grepl("GROUPM PLUS",fs$AdvertiserName)
sum(fs[set,"FlightPrice"],na.rm=TRUE)
fs <- fs[!set,]
fs$Size <- as.character(fs$Size)
fs$Size[grepl("APP",fs$Size)] <- "APP"
fs <- fs[fs$Size %in% c("RECTANGLE","SPOT","STRIP SKIN MASTHEAD","APP"),]
fs <- fs[fs$AdvertiserType %in% c("Paganti"),]
##--------------------------------load file pubmatic
## fs1 <- read.csv('raw/priceQ1Prog.csv')
## colnames(fs1) <- c("Size","DealId","AdvertiserName","Imps","FlightPrice")
## fs <- smartbind(fs,fs1)
##calc cpm
fs$cpm <- fs$FlightPrice / fs$Imps * 1000
fs <- do.call(data.frame,lapply(fs, function(x) replace(x, is.infinite(x),NA)))
fs <- do.call(data.frame,lapply(fs, function(x) replace(x, is.na(x),NA)))
##View(fs)
filter <- !fs$cpm<0.0001##commercial
filter <- TRUE##effective
fCost <- ddply(fs[filter,],.(Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE))
fCost <- fCost[!is.na(fCost$Size),]
##fCost <- ddply(fs[filter,],.(AdvertiserName),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE))
##fCost <- ddply(fs[fs$Size=="RECTANGLE",],.(AdvertiserName,AdvertiserType),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE))
rownames(fCost) <- as.character(fCost$Size)
fCost <- fCost[,-1]
fCost$cpmAv <- fCost$price / fCost$imps * 1000
fCost[,c("imps","price")] <- fCost[,c("imps","price")]/3000000
fCost$cpm <- c(3.7,3,13,4.5)
##cpmTot <- c(weighted.mean(fCost$cpm,fCost$imps),weighted.mean(fCost$markup,fCost$imps),weighted.mean(fCost$cost,fCost$imps),weighted.mean(fCost$margin,fCost$imps))
## fCost <- rbind(fCost,colSums(fCost))
## fCost[length(fCost$imps),c("cpm","markup","cost","margin")] <- cpmTot
##write.csv(fCost,"out/priceRevVodaCommercial.csv")
##write.csv(fCost,"out/priceRevVodaEffective.csv")
##View(fCost)
##--------------------------------------const------------------------
cpmT <- weighted.mean(fCost$cpm[set],fCost$imps[set])
markup <- 1.2
shareD <- 0.03
revF <- function(x,y){
    rev <- (cpmT*(y-1) - x)
    rev
}
fCost$even <- (markup-1.)*fCost$cpm
fCost$imps*shareD
even <- data.frame(markup=seq(1,1.5,by=0.1))
for(f in rownames(fCost)){
    even$y = even$markup
}

##-------------------------------margin-growth-----------------------
set <- TRUE##all format
set <- c(2)##only rectangle
xC <- seq(0.30,1,by=0.01)##cost
YR <- seq(1.1,1.5,by=0.05)##markup
zR <- data.frame(x = xC)##rev
slope <- sum(fCost$imps[set]*1000)
intercept <- sum(fCost$cpm[set]*fCost$imps[set]*1000)
for(y in YR){
    t <-  xC*slope
    t <- (y-1)*intercept - t
    zR <- cbind(zR,t/1000)
}
names(zR) <- c("x",percent(YR-1) )
tLab <- data.frame(x=0.05,y=t(zR[1,-1]),l=names(zR[,-1]))
tLab <- data.frame(x=((YR-1)*intercept)/slope,X1=0,l=names(zR[,-1]))
melted <- melt(zR,id="x")
dRibb <- melted$value[1]-melted$value[2]
ref <- data.frame(x=xC,y=0)
actual <- data.frame(x=c(.25,.75),y=rep(sum(fCost$price)*shareD,2))
pd <- position_dodge(0.2)

##---------------------------cost-table----------------------------
costP <- seq(0.80,0.60,by=-0.05)
impsP <- 5*(1:5)^2 + 15*1:5

bCost <- data.frame(imps=c(0,impsP))
bCost$cost  <- c(0,costP)
bCost$imps1 <- c(0,5*(1:5)^2 + 5*1:5)
bCost$cost1 <- c(0,costP-.1)
bCost$imps2 <- c(0,5*(1:5)^2 + 1:5)
bCost$cost2 <- c(0,costP-0.2)
bCost[nrow(bCost),grepl("imps",colnames(bCost))] <- 200

x <- bCost$cost[-1] ;y <- bCost$imps[-1] ;fit <- lm(formula=y~poly(x,2,raw=TRUE))
cont = data.frame(x=xC,y=predict(fit, list(x=xC))*(cpmT*(1-markup)-xC))
x <- bCost$cost1[-1];y <- bCost$imps1[-1];fit <- lm(formula=y~poly(x,2,raw=TRUE))
cont1 = data.frame(x=xC,y=predict(fit, list(x=xC))*(cpmT*(1-markup)-xC))
x <- bCost$cost2[-1];y <- bCost$imps2[-1];fit <- lm(formula=y~poly(x,2,raw=TRUE))
cont2 = data.frame(x=xC,y=predict(fit, list(x=xC))*(cpmT*(1-markup)-xC))

tmp <- cont2
plot(x,y*(cpmT*(1-markup)-x))
lines(tmp$x,tmp$y, col="red")
##---------------------------rev-table----------------------------
bImps <- data.frame(share=seq(0.05,0.2,by=0.025))
bImps$vol <- bImps$share*sum(fCost$imps[set])
bImps$cost  <- as.numeric(as.character(cut(bImps$vol,bCost$imps ,labels=bCost$cost[-1] )))
bImps$cost1 <- as.numeric(as.character(cut(bImps$vol,bCost$imps1,labels=bCost$cost1[-1])))
bImps$cost2 <- as.numeric(as.character(cut(bImps$vol,bCost$imps2,labels=bCost$cost2[-1])))
bImps$y  <- bImps$vol*(cpmT*.2-bImps$cost )
bImps$y1 <- bImps$vol*(cpmT*.2-bImps$cost1)
bImps$y2 <- bImps$vol*(cpmT*.2-bImps$cost2)
bImps[,grepl("y",names(bImps))]

bLab <- data.frame(name=c("voda",seq(1,4,by=1)))
bLab$x[1] <- mean(bImps$cost);bLab$x[2] <- mean(bImps$cost1);bLab$x[3] <- mean(bImps$cost2);bLab$x[4] <- mean(bImps$cost3);bLab$x[5] <- mean(bImps$cost4)
bLab$y[1] <- mean(bImps$y); bLab$y[2] <- mean(bImps$y1); bLab$y[3] <- mean(bImps$y2); bLab$y[4] <- mean(bImps$y3); bLab$y[5] <- mean(bImps$y4);

lines <- melt(bImps[,grepl("y",names(bImps))])
lines <- cbind(lines,x=melt(bImps[,grepl("cost",names(bImps))])$value)
##--------------------------graph-rev-cost----------------------------
gLabel = c("cost","revenue kE",paste("profitability lines"),"margin")
p <- ggplot() +
    ## geom_line(data=melted,aes(x=x,y=value,color=variable),size=2,alpha=.5,show.legend=FALSE) +
    ## geom_ribbon(data=melted,aes(x=x,ymin=value-dRibb,ymax=value+dRibb,fill=variable,color=variable),size=.2,alpha=.05) +
    ## geom_text(data=tLab,aes(x=x,y=X1,label=l),color=gCol[1],size=6) +

    guides(fill = guide_colorbar(ticks = FALSE)) +
    geom_line(data=ref,aes(x=x,y=y,group=1,color="break even"),alpha=.8,size=2) +
    geom_line(data=actual,aes(x=x,y=y),color=gCol[1],alpha=.5,size=2) +
    geom_point(data=lines,aes(x=x,y=value,color=as.factor(x)),alpha=.5,size=8) +
    geom_line(data=lines,aes(x=x,y=value,color=variable),alpha=1,size=2) +

    geom_line(data=cont,aes(x=x,y=y),color=gCol1[1],alpha=.8,size=2) +
    geom_line(data=cont1,aes(x=x,y=y),color=gCol1[4],alpha=.8,size=2) +
    geom_line(data=cont2,aes(x=x,y=y),color=gCol1[5],alpha=.8,size=2) +

    geom_text(data=bLab,aes(x=x,y=y,label=name),color=gCol[1],size=8) +

    geom_text(data=lines,aes(x=x,y=value,label=round(value)),alpha=1,size=4) +
    scale_y_continuous(limits = c(-10, 25)) +
    scale_x_continuous(limits = c(0.25, .85)) +
    guides(color=FALSE) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
p

##(gg <- ggplotly(p))


fName <- paste("fig/profitabilityVodaAllEffective",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

## fs <- fs[fs$cpm>lim[1],]
## fs <- fs[fs$cpm<lim[2],]
##-----------------------------------anomalie
sum(fs[fs$cpm>3.,"Imps"],na.rm=TRUE)/3
lim <- quantile(fs$cpm,cumprob)
View(fs[fs$cpm<0.0001,])
sum(fs[fs$cpm<0.0001,"Imps"],na.rm=TRUE)
##costDir <- ddply(fs,.(AdvertiserName),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
costDir <- ddply(fs,.(AdvertiserName),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE))
costDir$cpm <- costDir$price / costDir$imps * 1000
costDir <- do.call(data.frame,lapply(costDir, function(x) replace(x, is.infinite(x),NA)))
costDir <- do.call(data.frame,lapply(costDir, function(x) replace(x, is.na(x),NA)))
lim = quantile(costDir$cpm,cumprob,na.rm=TRUE)
## costDir <- costDir[costDir$cpm > lim[1],]
## costDir <- costDir[costDir$cpm < lim[2],]
adNo <- costDir[costDir$cpm <= lim[1],]
adNo <- rbind(adNo,costDir[costDir$cpm >= lim[2],])
write.csv <- write.csv(adNo,"out/anomalieAdvertiser.csv")
fs <- fs[!fs$AdvertiserName %in% adNo$AdvertiserName,]
costDir <- ddply(fs,.(Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
costDir$cpm <- costDir$price / costDir$imps * 1000
costDir <- do.call(data.frame,lapply(costDir, function(x) replace(x, is.infinite(x),NA)))
costDir <- do.call(data.frame,lapply(costDir, function(x) replace(x, is.na(x),NA)))
sum(costDir[grepl("VIDEO",costDir$Size),"imps"]) + sum(costDir[grepl("Video",costDir$Size),"imps"])
sum(costDir[costDir$cpm>3.,"imps"])
write.csv(costDir[costDir$cpm>3.,],"out/priceSize.csv")
fs$int <- cut(fs$Imps,breakImps*1000)
fs[is.na(fs$int),c("int","Imps")]
volAd <- as.data.frame(table(fs$int))
volAd$price <- c(0.80,0.75,0.70,0.65,0.60)
volAd$volM <- ddply(fs[,c("Imps","int")],.(int),summarise,imps=sum(Imps/1000,na.rm=TRUE))$imps
volAd$rev <- volAd$price*volAd$volM

##---------------------------------cum-prob-----------------------------
maxC <- 30
bin <- seq(0,maxC,by=0.5)
fs$bin <-  as.numeric(as.character(cut(fs$cpm,bin ,labels=bin[-1] )))
breakImps <- c(0,20,50,90,140,200,5000000)
sizeL <- names(table(fs$Size))
pCum <- data.frame(bin = bin)
pImps <- data.frame(bin = bin)
for(i in sizeL){
    set <- (fs$Size == i)##rectangle
    imps <- ddply(fs[set,],.(bin),summarise,imps=sum(Imps,na.rm=TRUE))
    imps <- imps[match(pCum$bin,imps$bin),"imps"]
    imps[imps==NA] <- 0
    imps[is.na(imps)] <- 0
    cum <- cumsum(imps)
    pCum <- cbind(pCum,cum)
    pImps <- cbind(pImps,imps)
}
colnames(pCum) <- c("bin",sizeL)
colnames(pImps) <- c("bin",sizeL)
pCum$bin <- as.numeric(pCum$bin)

gridC <- data.frame(y=c(rep(0,5),rep(200*1000,5)),vodafone = rep(c(0.80,0.75,0.700,0.65,0.60),2),mediamond =  rep(c(0.70,0.65,0.60,0.55,0.50),2))

gridI <- data.frame(x=c(rep(0,5),rep(maxC,5)),vodafone = rep(c(20,50,90,140,200)*1000,2),mediamond =  rep(c(20,40,70,110,200)*1000,2))

melted <- melt(pCum,id="bin")
meltedC <- melt(gridC,id="y")
meltedI <- melt(gridI,id="x")

gLabel = c("cpm","imps",paste("profitability"),"format")
ggplot() +
    geom_line(data=melted,aes(x=bin,y=value,color=variable),size=2) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
geom_line(data=melted,aes(x=bin*1.2,y=value,color=variable),size=2) +
    geom_line(data=melted,aes(x=bin+0.60,y=value,color=variable),size=2)# +
    ## geom_line(data=meltedC,aes(x=value,y=y,color=variable),size=2) +
    ## geom_line(data=meltedI,aes(x=x,y=value,color=variable),size=2)

melted <- melt(pImps,id="bin")
ggplot(melted,aes(x=bin,y=value,color=variable)) + geom_line(size=2)








fs1 <- read.csv('raw/priceQ1Prog.csv')

fs1 <- read.csv('raw/priceERP2016Q1.csv')
str(fs1)
set <- c(1,5,6)
set <- c(8,14,15)
weighted.mean(fs1[set,"CPM"],fs1[set,"Valore.Netto"])


