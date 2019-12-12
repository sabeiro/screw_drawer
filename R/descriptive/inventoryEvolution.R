#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library(dplyr)
## Programmi con relativo bacino generato
## Pre vs mid vs post roll (potenzialmente con relative performance di CTR e VTR)
## Full episode vs snack

## Trend stagionali
## Corrispondenze con il palinsesto tv
## Invenduto e periodi a invenduto 0 (potenzialmente in cui il bacino non bastava), incidenza dei partner

## fs0 <- read.csv('raw/inventoryVideo2016.csv',stringsAsFactor=F)
## sum(as.numeric(fs0$Imps))
fs1 <- read.csv('raw/inventoryVideo2016Position.csv',stringsAsFactor=F)
fs1$pos <- tryCatch(unlist(lapply(strsplit(fs1$Position,split="_"),'[[',1)),err=function(e) NA)
fs1$Dataf <- as.Date(fs1$Data)
fs2 <- read.csv('raw/inventoryVideo2016Site.csv',stringsAsFactor=F)
fs2 <- fs2[!fs2$Site=="VIDEOEXTRA",]
sum(as.numeric(fs2$Imps))
fs2$Data <- as.Date(fs2$Data)
fs3 <- read.csv('raw/inventoryVideo2016Actions.csv',stringsAsFactor=F)
fs3$Data <- as.Date(fs3$Data)
fs4 <- read.csv('raw/inventoryVideo2016Unique.csv',stringsAsFactor=F)
fs4$Data <- as.Date(strptime(fs4$Data,format="%Y%m%d"))
fs5 <- read.csv('raw/inventoryVideoDaily.csv',stringsAsFactor=F)
fs5$Data <- as.Date(fs5$Data)
##fs5 = fs5[fs5$Data >= as.Date("2016-01-01") & fs5$Data <= as.Date("2016-12-31"),]
fsw <- read.csv('raw/inventoryVideoWeekly.csv',stringsAsFactor=F)
fsw$Data <- as.Date(fsw$Data)
##fsw = fsw[fsw$Data >= as.Date("2016-01-01") & fsw$Data <= as.Date("2016-12-31"),]
fse <- read.csv("raw/storicoERP2016.csv",stringsAsFactor=F)
fse$Data <- as.Date(fse$Data.Prenotazione)
formatL = c("Half Page","Masthead","Overlayer","Pre-Roll Video","PromoBox","Rectangle","Rectangle Exp-Video","Skin")
cpmL <- NULL
impsL <- NULL
revL <- NULL
i <- "Pre-Roll Video"
for(i in formatL){
    set <- fse$Formato == i
    cpmL <- c(cpmL,sum(fse[set,"Valore.Netto"])/sum(fse[set,"Quantità.Ordine"]+fse[set,"Quantità.Gratis"])*1000)
    impsL <- c(impsL,sum(fse[set,"Quantità.Ordine"]+fse[set,"Quantità.Gratis"])/1000000)
    revL <- c(revL,sum(fse[set,"Valore.Netto"]))
}
cpmD = data.frame(format=formatL,cpm=round(cpmL,2),imps=impsL,rev=revL)
round(revL/1000000,3)
##--------------------position
evPosition = ddply(fs1,.(Data,pos),summarise,imps=sum(Imps,na.rm=T),click=sum(Click,na.rm=T))
evPosition$ctr = evPosition$click/evPosition$imps
evPosition$Data = as.Date(evPosition$Data)
##evPosition <- evPosition[!evPosition$pos %in% c("7","8","9"),]
##--------------------site
evSite = ddply(fs2,.(Data,Site),summarise,imps=sum(Imps,na.rm=T),click=sum(Click,na.rm=T))
evSite$ctr = evSite$click/evSite$imps
lim = quantile(evSite$imps,0.80)
evSite = evSite[evSite$imps > lim,]
evSite$pos = evSite$Site
summary(evSite)
##--------------------action
evAction = fs3[fs3$Action > quantile(fs3$Action,0.5,na.rm=T),]
colnames(evAction) <- c("Data","Size","pos","imps")
evAction <- merge(evAction,evAction[evAction$pos=="start",c("Data","pos","imps")],by="Data")
evAction$ctr <- evAction$imps.x/evAction$imps.y
evAction$pos <- evAction$pos.x
evAction$imps <- evAction$imps.x
ddply(evAction,.(pos),summarise,imps=sum(as.numeric(imps),na.rm=T))
##-------------------unique
evUnique = fs4[fs4$imps > quantile(fs4$imps,0.99),]
colnames(evUnique) <- c("Data","Size","pos","ctr","imps")
evUnique$ctr <- evUnique$imps/evUnique$ctr
##-------------------unsold
evUnsold <- melt(fs5[,c("Data","Invenduto","Totale.inventory","Totale.partner")],id="Data")
evUnsold$value <- as.numeric(evUnsold$value)
set <- evUnsold$variable == "Invenduto"
set1 <- evUnsold$variable == "Totale.inventory"
evUnsold[set1,"percentage"] = 1
evUnsold[set,"percentage"] = evUnsold[set,"value"]/evUnsold[set1,"value"]
set <- evUnsold$variable == "Totale.partner"
evUnsold[set,"percentage"] = evUnsold[set,"value"]/evUnsold[set1,"value"]
colnames(evUnsold) <- c("Data","pos","imps","ctr")
evUnsold$pos = as.character(evUnsold$pos)


metricL <- c("Site","Position","Action","Unique","Unsold")
i <- metricL[5]
for(i in metricL){
    print(i)
    eval(parse(text=paste("evTmp=ev",i,sep="")))
    wTab <- ddply(evTmp,.(pos),summarise,imps=sum(as.numeric(imps),na.rm=T),N=length(ctr),mean=mean(ctr,na.rm=T),median=median(ctr,na.rm=T),sd=sd(ctr,na.rm=T),se=sd/sqrt(N))
    if(FALSE){
        con <- pipe("xclip -selection clipboard -i", open="w")
        write.table(wTab,con,row.names=F,col.names=T,sep=",")
        close(con)
    }
    lim <- quantile(evTmp$ctr,c(.06,.94),na.rm=T)
    evTmp <- evTmp[evTmp$ctr > lim[1] & evTmp$ctr < lim[2],]
    evTmp <- evTmp[!is.na(evTmp$pos),]
    evTmp <- evTmp[!is.na(evTmp$ctr),]
    evTmp$pos <- as.factor(evTmp$pos)
    evTab <- as.data.frame.matrix(xtabs("ctr ~ Data + pos",evTmp))
    evSum <- summary(evTab)

    metSx = "pos"
    metSy = "ctr"

    melted <- evTmp
    melted$imps <- melted$imps/1000000
    melted$week <- format(melted$Data,"%y-%W")
    melted2 <- ddply(melted,.(week,pos),summarise,imps2=sum(imps,na.rm=T),ctr2=weighted.mean(ctr,imps,na.rm=T),Data=head(Data,1))
    meltS <- wTab
    meltS$lab <- paste("Σ",round(meltS$imps/1000000),"M","\n","av",round(meltS$mean,2))
    meltS[,"y"] <- quantile(melted[,metSy],0.02)#(melted[,c("pos","imps")] %>% group_by(pos) %>% mutate_each(funs(median(.))))[2]
    meltS = meltS[order(-meltS[,"imps"]),]
    meltS <- transform(meltS,w=strwidth(lab,'inches')+0.25,h=strheight(lab,'inches')+0.25)
    meltS$pos <- factor(meltS$pos,levels=meltS$pos)
    melted$pos <- factor(melted$pos,levels=meltS$pos)
    
    gLabel = c(metSx,metSy,paste(i,"dispersion"),i)
    gLabel = c("section","imps/unique",paste(i,"dispersion"),i)
    p <- ggplot(melted,aes_string(x=metSx,y=metSy,group=metSx,color=metSx)) +
        ##geom_violin(position = "dodge") +
        geom_jitter(height = 0,alpha=0.3) +
        geom_boxplot(size=2,alpha=0) +
        ##geom_rect(data=meltS,aes(x=1:4,xmin=1:4-w/2,xmax=1:4+w/2,ymin=y-h/2,ymax=y+h/2,y=y,label=lab)fill="white") +
        geom_text(data=meltS,aes(y=y,label=lab),color="black",size=4) +
        ##scale_y_log10() + 
        scale_color_manual(values=gCol1) + 
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
    p
    ggsave(file=paste("fig/invPosBoxplot",i,".jpg",sep=""),plot=p,width=gWidth,height=gHeight)
    gLabel = c("imps","ctr",paste(i,"evolution"),i)
    p <- ggplot(melted2) +
        geom_line(aes(x=Data,y=ctr2,color=pos,group=pos),size=1) +
        scale_x_date(date_breaks="1 month") +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[4])
    p
    ggsave(file=paste("fig/invEvPosData",i,".jpg",sep=""),plot=p,width=gWidth,height=gHeight)
}
##-------------------logistic-regression------------------------

metricL <- c("Site","Position","Action","Unique","Unsold")
k <- metricL[5]
eval(parse(text=paste("evTmp=ev",k,sep="")))
lim <- quantile(evTmp$ctr,c(.1,.9),na.rm=T)
evTmp <- evTmp[evTmp$ctr > lim[1] & evTmp$ctr < lim[2],]
evTmp <- evTmp[!is.na(evTmp$pos),]
evTmp <- evTmp[!is.na(evTmp$ctr),]
evTmp$pos <- as.factor(evTmp$pos)

evTime = evTmp
evTime$week <- format(evTime$Data,"%W")
evTime$month <- format(evTime$Data,"%m")
evTime$wDay <- weekdays(evTime$Data)
evTime$dayY <- as.character(format(evTime$Data,"%d"))

metricL <- c("wDay","month","wDay+month")
i <- metricL[3]
dimensionL <- c("Invenduto","Totale.partner")
j <- dimensionL[2]
for(j in dimensionL){
    print(j)
    for(i in metricL){
        model <- glm(paste("ctr ~",i),evTime[evTime$pos==j,],family=gaussian())
        coefT <- model$qr$qr %>% as.matrix 
        logT <- log(coefT)
        logT[is.nan(logT)] <- 0
        depC1 <- model$coefficients[order(-abs(model$coefficients))]
        depC <- data.frame(site=names(depC1),ctr=depC1,group="train")
        depC$site <- depC$site %>% gsub("wDay","",.) %>% gsub("month","m-",.)
        depC <- depC[!grepl("Intercept",depC$site),]
        ##pcaT <- prcomp(logT,center = TRUE,scale. = TRUE)
        ##plot(melted[melted$pos=="Invenduto","ctr"],type="l")
        ##write.csv(depC,paste("out/train/coeff",varList[iN],varList[oN],".csv",sep=""))
        melted <- melt(depC)
        melted$site <- factor(melted$site,levels=melted$site)
        NShow <- 30
        melted <- melted[1:min(NShow,nrow(melted)),]
        gLabel = c("time","influence",paste("coefficient influence ",i," on",j),"group")
        p <- ggplot() +
            geom_bar(data=melted,aes(x=site,y=value,fill=value),stat="identity") +
            labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
        p
        fName <- paste("fig/invEvLogistic","Time",i,j,".jpg",sep="")
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    }
}





metricL <- c("dayY","dayW","month","week")
dimensionL <- c("Invenduto","Totale.partner")
for(j in dimensionL){
    print(j)
    for(i in metricL){
        melted1 <- evUnsold[evUnsold$pos==j,]
        melted1$dayY <- as.character(format(melted1$Data,"%d"))
        melted1$month <- as.character(format(melted1$Data,"%m"))
        melted1$week <- as.character(format(melted1$Data,"%W"))
        melted1$dayW <- weekdays(melted1$Data)
        model <- glm(paste("ctr ~",i),melted1,family=gaussian())
        binomial 	(link = "logit")
        ##gaussian,(link = "identity");Gamma,(link = "inverse");inverse.gaussian,(link = "1/mu^2");poisson,(link = "log");quasi,(link = "identity", variance = "constant");quasibinomial 	(link = "logit");quasipoisson 	(link = "log");
        depC1 <- model$coefficients[order(-abs(model$coefficients))]
        depC <- data.frame(site=names(depC1),ctr=depC1,group="train")
        depC$site <- depC$site %>% gsub(i,"",.)
        depC <- depC[!grepl("Intercept",depC$site),]
        ##pcaT <- prcomp(logT,center = TRUE,scale. = TRUE)
        ##plot(melted[melted$pos=="Invenduto","ctr"],type="l")
        ##write.csv(depC,paste("out/train/coeff",varList[iN],varList[oN],".csv",sep=""))
        melted <- melt(depC)
        melted$site <- factor(melted$site,levels=melted$site)
        melted <- melted[!grepl("intercept",melted$site),]
        NShow <- 30
        melted <- melted[1:min(NShow,nrow(melted)),]
        gLabel = c("time","influence",paste("coefficient influence ",i," on",j),"group")
        p <- ggplot() +
            geom_bar(data=melted,aes(x=site,y=value,fill=value),stat="identity") +
            labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
        p
        fName <- paste("fig/invEvLogistic","Time",i,j,".png",sep="")
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    }
}






