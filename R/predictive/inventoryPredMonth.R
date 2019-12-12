#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('/home/sabeiro/lav/media/')

source('src/R/graphEnv.R')
require('forecast')
library(splines)
library(gtools)
library('psd')
library('RSEIS')
##install.packages('sqldf')
library(sqldf)
comprob <- .98
##install.packages("forecastHybrid")
library(forecastHybrid)
library('dplyr')

timeSeq  <- read.table("out/invVideoTimeSeqTot.csv",row.names=1,header=TRUE,sep=",")

##timeSeq  <- read.table("out/invVideoTimeSeqTel.csv",row.names=1,header=TRUE,sep=",")

sectN <- length(colnames(timeSeq))
sectL <- colnames(timeSeq)

histS <- melt(cbind(date=rownames(timeSeq),timeSeq),id.vars="date")
histS$date <- as.Date(histS$date)
histS$month <- format(histS$date,"%y-%m")
head(histS)
histD <- ddply(histS,.(date),summarise,imps=sum(value,na.rm=T))
histD$date <- as.Date(histD$date)
histD$week <- format(histD$date,format="%y-%W")
histD$month <- format(histD$date,format="%y-%m")
histW <- ddply(histD,.(week),summarise,imps=sum(imps,na.rm=T),date=head(date,1))
histM <- ddply(histD,.(month),summarise,imps=sum(imps,na.rm=T),date=head(date,1))
histSM <- ddply(histS,.(month,variable),summarise,imps=sum(value,na.rm=T),date=head(date,1))
##write.csv(histW[,c(3,2)],"raw/inventoryVideoWeekly1.csv",row.names=F)

##timeSeq  <- as.matrix(read.table("out/invVideoTimeSeqPartner.csv",row.names=1,header=TRUE,sep=","))


melted <- melt(cbind(date=rownames(timeSeq),timeSeq))
melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
melted$value <- melted$value/1000000
mImps <- ddply(melted,.(variable),summarise,imps=sum(value,na.rm=TRUE))
mImps <- mImps[order(-mImps$imps),]
melted$variable <- factor(melted$variable,levels=mImps$variable)
nVar <- length(colnames(timeSeq))
colD <- data.frame(name=colnames(timeSeq),col=gCol1[1:nVar])
ymin <- quantile(melted$value,0.1,na.rm=T)

gLabel = c("category","impressions (Mio/day)",paste("category dispersion"),"category")
p <- ggplot(melted,aes(x=variable,y=value,group=variable,color=variable)) +
    ##geom_violin(position = "dodge") +
    geom_jitter(height = 0,alpha=0.3) +
    geom_boxplot(size=2,alpha=0) +
    geom_text(data=mImps,aes(x=variable,y=ymin,label=round(imps,0)),color="black") +
    scale_color_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
ggsave(file="intertino/fig/invBoxplot.jpg",plot=p,width=gWidth,height=gHeight)

monthSeq <- as.data.frame(timeSeq)
freqSeq <- colwise(spectrum(timeSeq[,1]))
monthSeq$date <- format(as.Date(rownames(timeSeq)),"%W")
meltedMonth <- melt(monthSeq,by=date)
aggr1 <- ddply(meltedMonth,.(date,variable),summarise,imps=sum(value,na.rm=TRUE),count=sum(!is.na(value)))
aggr1$imps = aggr1$imps/aggr1$count
aggr1$imps <- aggr1$imps/1000000
aggr1$variable <- factor(aggr1$variable,levels=mImps$variable)

aggr1 <- arrange(aggr1,desc(variable))

gLabel = c("year-month","relative impressions",paste("seasonal history"),"section")
p <- ggplot(aggr1,aes(x=date,y=imps,group=(variable))) +
    geom_area(aes(fill=factor(variable),color=factor(variable)),position="stack",size=1,alpha=.3) +
    ##geom_point(aes(color=factor(variable)),position="stack",size=1) +
    ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1,guide=F) +
    facet_grid(variable ~ .,scales="free") + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file="intertino/fig/invSeasMonth.jpg",plot=p,width=gWidth,height=gHeight)


monthSeq$date <- substring(rownames(timeSeq),3,7)
meltedMonth <- melt(monthSeq,by=date)
aggr1 <- ddply(meltedMonth,.(date,variable),summarise,imps = sum(value,na.rm=TRUE))
aggr1$imps <- aggr1$imps/1000000
aggr1$variable <- factor(aggr1$variable,levels=mImps$variable)
aggr1 <- arrange(aggr1,desc(variable))

gLabel = c("year-month","impressions (Mio/month)",paste("video basin evolution"),"section")
p <- ggplot(aggr1,aes(x=date,y=imps,group=(variable))) +
    geom_area(aes(fill=factor(variable),color=factor(variable)),position="stack",size=1,alpha=.3) +
    ##geom_point(aes(color=factor(variable)),position="stack",size=1) +
    ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1,guide=F) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
p
ggsave(file="intertino/fig/invHistMonth.jpg",plot=p,width=gWidth,height=gHeight)


gLabel = c("year-month","impressions relative",paste("fractional basin evolution"),"section")
p <- ggplot(aggr1,aes(x=date,y=imps,group=variable)) +
    ##geom_point(aes(color=variable),position="fill",show.legend=FALSE) +
    geom_bar(aes(fill=variable,color=variable),stat="identity",position="fill",size=1,alpha=.3) +
    ##geom_area(aes(fill=variable,color=variable),stat="identity",position="fill",size=1,alpha=.5) +
    scale_fill_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
ggsave(file="intertino/fig/invHistMonthFill.jpg",plot=p,width=gWidth,height=gHeight)


##----------------------decomposizione-segnale----------------------------------
relGrowth <- NULL
for(i in unique(aggr1$variable)){
    y <- aggr1[aggr1$variable==i,"imps"]
    impr = ts(y,frequency=12,start=c(2012,7))
    dog <- stl(impr,"per")
    growth <- as.vector(as.matrix(dog$time.series)[,2])
    relGrowth <- rbind(relGrowth,data.frame(ch=i,growth=sum(diff(growth))/sum(growth)))
}

aggr2 <- ddply(meltedMonth,.(date),summarise,imps = sum(value,na.rm=TRUE)/1000000)

impr = ts(aggr2[,"imps"], frequency=12, start=c(2012,7))
dog <- stl(impr,"per")
plot(dog)
png("fig/invDecomp.png",width=pngWidth,height=pngHeight)
plot(dog)
dev.off()

trend <- data.frame(date=as.Date(time(dog$time.series)),senza_partner=as.vector(as.matrix(dog$time.series)[,2]))

trend <- data.frame(date=as.Date(time(dog$time.series)),spline=smooth.spline(1:nrow(aggr2),aggr2$imps,df=4)$y)
trend <- cbind(trend,trend=as.vector(as.matrix(dog$time.series)[,2]))
aggr2$n <- 1:nrow(aggr2)
bsp <- lm(imps ~ bs(n,df=4),data=aggr2)
ht <- seq(1,nrow(aggr2))
trend <- cbind(trend,bspline=predict(bsp,newdata=aggr2))
trendP <- data.frame(date=as.Date(time(dog$time.series)),hist=aggr2[,"imps"])
trendP$hist <-trendP$hist/sum(trendP$hist)
    
melted <- melt(trend,id="date")
melted$diff <- 0
for(i in unique(melted$variable)){
    print(i)
    y <- melted[melted$variable==i,"value"]
    melted[melted$variable==i,"diff"] = c(0,diff(y))
    melted[melted$variable==i,"diff"] <-melted[melted$variable==i,"diff"]/sum(abs(melted[melted$variable==i,"diff"]))
    melted[melted$variable==i,"value"] <-melted[melted$variable==i,"value"]/sum(abs(melted[melted$variable==i,"value"]))
}
gLabel = c("year-month","normalized value",paste("relative growth"),"regression","relative growth")
p1 <- ggplot(melted,aes(x=date))+
    geom_point(data=trendP,aes(x=date,y=hist,color="historical"),position="identity",size=3,shape=2) + 
    geom_line(data=trendP,aes(x=date,y=hist,color="historical"),position="identity",size=1) + 
    geom_bar(aes(y=diff,fill=variable),stat="identity",alpha=0.2,position="identity",size=1.5) + 
    geom_line(aes(y=value,color=variable,group=variable),position="identity",size=1.5) + 
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) +
##    scale_y_continuous(limits = quantile(melted$diff,c(0.05,0.9))) +
    scale_x_date(labels=date_format("%y-%m"),breaks = date_breaks("3 month")) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
##p1

gLabel = c("section","normalized value",paste("relative growth"),"regression","relative growth")
p2 <- ggplot(relGrowth) +
    geom_bar(aes(x=ch,y=growth,fill=ch),stat="identity",show.legend=F) + 
    geom_text(aes(x=ch,y=growth/2,label=percent(growth)),size=3,show.legend=F) + 
    geom_text(aes(x=ch,y=ifelse(growth>0,-0.01,0.01),label=ch),angle=45,size=3,show.legend=F) + 
    scale_fill_manual(values=gCol1) +
    theme(
        ## panel.background = theme_rect(fill = "transparent",colour = NA),
        ## plot.background = theme_rect(fill = "transparent",colour = NA),
        axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        panel.grid.major = element_blank(),
        axis.ticks=element_blank(),
        panel.grid.minor = element_blank()
    ) + 
    labs(x="",y="",title="",color=gLabel[4],fill=gLabel[5])
p2
vp <- viewport(width=0.5,height=0.4,x=0.6,y=0.8)
jpeg("intertino/fig/invHistGrowth.jpg",width=pngWidth,height=pngHeight)
print(p1)
print(p2, vp = vp)
dev.off()



##------------------------------prediction-errors-month----------------------------------
nAhead <- 5
weekY <- unique(histD$month)
weekY <- weekY[(length(weekY)-nAhead):length(weekY)]
cW <- weekY[length(weekY)]
cW <- as.numeric(substring(weekY[length(weekY)],first=4,last=5))
library(lubridate)

## futureS <- rbind(histS,futureS)
## futureS <- futureS[order(futureS$date),]
## futureS$date <- as.factor(futureS$date)
i <- sectL[2]
w <- weekY[4]
predDiff <- NULL
for(i in sectL){
    print(i)
    for(w in weekY){
        singleS <- histSM[grepl(i,histSM$variable),]
        singleS <- singleS[1:grep(w,singleS$date),]
        plot(singleS$imps,type="l")
        impr = ts(singleS$imps,frequency=12,start=7)##, start=c(2012,07,01), end=c(2016,07,03))
        impr2 = window(impr)##, start=c(2013,10), end=c(2015, 12))
        if( is.na(sd(impr2)) | sd(impr2) == 0){next;}
        ##fit <- arima(impr2,order=c(1,0,1))
        fc <- hybridModel(impr2, models = "aet", weights = "equal")
        if(FALSE){
            par(mfrow = c(3, 1), bty = "l")
            plot(fc)
            plot(fc$ets)
            plot(fc$auto.arima)
        }
        wAhead <- as.Date(paste("20",w,"-01",sep=""),format="%Y-%m-%d") %m+% months(1:nAhead)
        wAhead <-  format(wAhead,"%y-%m")
        predDiff1 <- data.frame(
            ref=rep(w,nAhead),
            date=wAhead,
            ##arima=as.data.frame(forecast(fit,nAhead))[,1],
            ##hybrid=as.data.frame(forecast(fc$hybrid,nAhead))[,1],
            ets=as.data.frame(forecast(fc$ets,nAhead))[,1],
            tbats=as.data.frame(forecast(fc$tbats,nAhead))[,1],
            autoarima=as.data.frame(forecast(fc$auto.arima,nAhead))[,1])
        predDiff1$ch <- i
        predDiff <- rbind(predDiff,predDiff1)
    }
}

predDiff$ref <- as.character(predDiff$ref)
predDiff$date <- as.character(predDiff$date)
checkDiff <- predDiff[predDiff$date %in% weekY,]
checkDiff$hist <- histSM[match(checkDiff$date,histSM$month),"imps"]

predDiff$diff <- as.numeric(lapply(strsplit(as.character(predDiff$date),split="-"),'[[',2)) - as.numeric(lapply(strsplit(as.character(predDiff$ref),split="-"),'[[',2))
predDiff$diff[predDiff$diff<0] <- 12 + predDiff$diff[predDiff$diff<0]

m <- 1
s <- colnames(timeSeq)[1]
nextMonth <- paste("17",sprintf("%02d",(cW+1):(cW+nAhead)%%12),sep="-")
wAhead <- as.Date(paste("20",weekY[length(weekY)],"-01",sep=""),format="%Y-%m-%d") %m+% months(1:nAhead)
wAhead <-  format(wAhead,"%y-%m")
bestM <- NULL
for(s in colnames(timeSeq)){
    set2 <- grepl(s,checkDiff$ch)
    mDiff <- colSums(abs(checkDiff[set2,"hist"] - checkDiff[set2,c("autoarima","ets","tbats")]))
    bestM1 <- data.frame(date=wAhead[m],ch=s,method=as.character(names(mDiff)[which(min(mDiff)==mDiff)]))
    bestM <- rbind(bestM,bestM1)
}
futureS <- data.frame(date=max(histM$date) %m+% months(1:nAhead),variable=rep(sectL,nAhead),diff=1:5)
futureS$week <- format(futureS$date,"%y-%m")
futureS$week <- as.character(futureS$week)
futureS$variable <- as.character(futureS$variable)
futureS$diff <- as.numeric(futureS$diff)
futureS <- futureS[order(futureS$date,futureS$variable),]
futureS <- merge(futureS,bestM,by.x="variable",by.y="ch")

futureS <- sqldf("SELECT * FROM futureS AS t LEFT JOIN predDiff AS s ON (t.variable = s.ch) AND (t.diff = s.diff) AND (t.week = s.date)") 


futureS$imps = NA
for(i in 1:nrow(futureS)){
    futureS$imps[i] <- futureS[i,as.character(futureS$method[i])]
##    futureS$imps[i] <- futureS[i,"ets"]
}
ddply(futureS[,c("week","imps")],.(week),summarise,imps=sum(imps)/30*7)
##ddply(histSM,.(date),summarise,imps=sum(imps)/4)
predDiff[predDiff$ch=="banzai",]

write.csv(futureS,"out/inventoryPredictionMonth.csv")

## mAheadPlot <- 5
## melted <- melt( ddply(predDiff[predDiff$diff==mAheadPlot,],.(date),summarise,hist=sum(hist),tbats=sum(tbats),ets=sum(ets),autoarima=sum(autoarima)))
## histS15 <- histS[grepl("15-",histS$date),]
## histS15$date <- substring(gsub("15-","16-",histS15$date),first=3,last=7)
## melted1 <- ddply(histS15,.(date),summarise,imps=sum(value))
## histS16 <- futureS
## histS16$date <- substring(histS16$date,first=3,last=7)
## melted2 <- ddply(histS16,.(date),summarise,imps=sum(imps))
## gLabel = c("year-month","impressions (Mio)",paste("historical vs prediction ",mAheadPlot," months ahead"),"section")
## p <- ggplot(melted,aes(x=date,y=value,color=variable,group=(variable))) +
##     ##geom_point(aes(color=variable),position="identity",size=2) +
##     geom_line(aes(color=variable),position="identity",size=1.5) +
##     geom_line(data=melted1,aes(x=date,y=imps,group=1,color="2015"),stat="identity",size=1.5) +
##     geom_line(data=melted2,aes(x=date,y=imps,group=1,color="2016"),stat="identity",size=1.5) +
##     ##geom_area(aes(fill=(variable)),position="identity",size=1,alpha=.5) +
##     ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
##     ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
##     labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
## p
## ggsave(file="fig/invPredDiff.png",plot=p,width=gWidth,height=gHeight)


##--------------------------previsioni-plot---------------------------------
futureS1 <- futureS[,c("week","variable","imps","date.x")]
ddply(futureS1[,c("week","imps")],.(week),summarise,imps=sum(imps)/30*7)

colnames(futureS1) <- colnames(histSM)
melted <- rbind(histSM,futureS1)
melted <- melted[order(melted$month,melted$variable),]
melted$variable <- factor(melted$variable,levels=mImps$variable)
melted$imps <- melted$imps/30000000*7
futureL <- ddply(futureS1,.(month),summarise,imps=sum(imps)/30000000*7,date=head(date,1))
gLabel = c("year-month","impressions (Mio/sett)",paste("previsione bacino video"),"section")
p <- ggplot(melted,aes(x=date,y=imps,color=(variable),group=(variable))) +
    ##geom_point(aes(color=variable),position="stack",show.legend=FALSE) +
    geom_rect(aes(xmin=futureS1[1,"date"],xmax=futureS1[nrow(futureS1),"date"],ymin=0,ymax=max(aggr1$imps)),color="red",fill="red",size=1.5,alpha=.1,show.legend=FALSE) +
##    geom_line(aes(color=(variable)),position="stack",size=1,alpha=.7) +
    geom_area(aes(fill=(variable),color=variable),position="stack",size=1,alpha=.7) +
    geom_label(data=futureL,aes(label=round(imps),color="black",group=1),show.legend=FALSE) + 
    scale_color_manual(values=gCol1,guide=FALSE) + 
    scale_fill_manual(values=gCol1) +
    scale_x_date(date_breaks = "4 month",labels=date_format("%y-%m")) + ##, date_labels = "%W") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
ggsave(file="intertino/fig/invPrev.jpg",plot=p,width=gWidth,height=gHeight)
write.csv(melted,"out/inventoryPredictionMonthEts.csv")


write.csv(predDiff,"out/predictionRollingArimaDaily.csv")
head(predDiff)
melted <- melt(predDiff[,c(1,2,7,8,9)],id=="date")
gLabel = c("data","devizione relativa",paste("rapporto tra previsione e storico"),"canale")
p <- ggplot(predDiff,aes(x=date,group=channel,color=channel)) +
    ## geom_line(aes(y=imps),size=1.5) +
    ## geom_line(aes(y=fore),size=1.5) +
    geom_line(aes(y=ratio),size=1.5) +
    ##scale_color_discrete(breaks=gCol1) +
    xlim(dateFore-108,dateFore+7) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

##-------------------------spettro-------------------------

data(magnet)
names(magnet)
subset(magnet,abs(mdiff)>0)
psdr <- pspectrum(magnet$raw)
psdc <- pspectrum(magnet$clean)
psdc_recovered <- psd_envGet("final_psd")
all.equal(psdc, psdc_recovered)

spec.pgram(timeSeq[,1],pad=1,taper=0.2,detrend=FALSE,demean=FALSE,plot=TRUE)
spec.pgram(timeSeq[,1],pad=1,taper=0.2,detrend=FALSE,demean=TRUE,plot=TRUE)
spec.pgram(timeSeq[,1],pad=1,taper=0.2,detrend=TRUE,demean=TRUE,plot=TRUE)
ntap <- psdc[["taper"]]
i <- colnames(timeSeq)[1]
for(i in colnames(timeSeq)){
    fName <- paste("fig/invSpect",i,".png")
    png(fName,width=pngWidth,height=pngHeight)
    psdcore(timeSeq[,i],ntaper=ntap,refresh=TRUE,plot=TRUE)
    dev.off()
}

melted <- melt(timeSeq)
melted <- ddply(melted,.(Var1),summarise,imps=sum(value,na.rm=TRUE))
head(melted)
psdcore(melted$imps,ntaper=ntap,refresh=TRUE,plot=TRUE)

melted <- melt(timeSeq)
melted <- melted[grepl("sport",melted$Var2),]
head(melted)
psdcore(melted$value,ntaper=ntap,refresh=TRUE,plot=TRUE)



dt = 1
summary(prewhiten(mc <-ts(timeSeq[,i] + 1000, deltat = dt) +seq_along(timeSeq[,i]),plot = FALSE))
summary(atsar <- prewhiten(mc,AR.max=100,plot=FALSE))
str(atsar[["lmdfit"]])
ats_lm <- atsar[["prew_lm"]]
str(atsar[["ardfit"]])
ats_ar <- atsar[["prew_ar"]]

plot(ts.union(orig.plus.trend = mc, linear = ats_lm, ar = ats_ar), yax.flip = TRUE,
     main =sprintf("Prewhitened Project MAGNET series"), las = 0)
mtext(sprintf("linear and linear+AR(%s)", atsar[["ardfit"]][["order"]]),line=1.1)

a <- rnorm(32)
all.equal(psdcore(a,1),psdcore(a,-1))

tapinit <- 10
Mspec <- mtapspec(ats_lm,deltat(ats_lm),MTP=list(kind=2,inorm=3,nwin=tapinit,npi=0))
str(Mspec)


Xspec <- spec.pgram(ats_lm,pad=1,taper=0.2,detrend=TRUE,demean=TRUE,plot=FALSE)
Pspec <- psdcore(ats_lm,ptaper=tapinit)
Aspec <- pspectrum(ats_lm,ntap.init=tapinit)
class(Mspec)
nt <- seq_len(Mspec[["numfreqs"]])
mspec <- Mspec[["spec"]][nt]
class(Xspec)
Xspec <- normalize(Xspec,dt,"spectrum")
##https://cran.r-project.org/web/packages/psd/vignettes/psd_overview.pdf 12

library(RColorBrewer)
cols <-c("dark grey",brewer.pal(8, "Set1")[c(5:4, 2)])
lwds <-c(1, 2, 2, 5)
plot(Xspec, log = "dB", ylim = 40 *c(-0.4, 1), ci.col = NA, col = cols[1],lwd = lwds[1], main = "PSD Comparisons")
pltf <- Mspec[["freq"]]
pltp <-dB(mspec)
lines(pltf, pltp, col = cols[2], lwd = lwds[2])
plot(Pspec, log = "dB", add = TRUE, col = cols[3], lwd = lwds[3])
plot(Aspec, log = "dB", add = TRUE, col = cols[4], lwd = lwds[4])
legend("topright",c("spec.pgram", "RSEIS::mtapspec", "psdcore", "pspectrum"),title = "Estimator", col = cols, lwd = lwds, bg = "grey95", box.col = NA,cex = 0.8, inset =c(0.02, 0.03))


    
## am – ASCOLTO MEDIO = numero di persone diverse tra loro presenti su un canale tv in ciascun minuto nell’intervallo di tempo considerato (programma, fascia oraria, ecc..) -> #users @ vtr 100%
## %sh  percentuale share -> reach universale
## %pe – AM/Universo di riferimento (popolazione) -> GRP?????
## co – COPERTURA = numero di persone diverse tra loro che hanno visto almeno un minuto (della fascia/programma/ecc..) -> page views
## mv minuti visti --> durata sessione
## pr – permanenza: minuti visti/durata totale -> durata 


