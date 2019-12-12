#!/usr/bin/env Rscript
##https://docs.google.com/spreadsheets/d/1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c/edit?pref=2&pli=1#gid=274965455
##https://docs.google.com/spreadsheets/d/11ALr9PE2fFlmsZ6bADEpnlybaN_t8JTA9XnFK_kzWZE/edit
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
source('script/graphEnv.R')

##source('script/inventoryIngombriLoad.R')


ingombriW <- read.csv('raw/ingombri2016.csv',stringsAsFactor=FALSE)
ingombriW$imps <- ingombriW$imps/1000000
ingombriW$date <- as.Date(ingombriW$date)
ingombriW <- ingombriW[!is.na(ingombriW$date),]

ingombriW <- ingombriW[-1,]

fs <- read.csv('raw/inventoryWeek13-16.csv',sep=",")
melted <- fs[,c("Data","Totale.inventory")]
melted$Totale.inventory <- as.numeric(gsub("[[:punct:]]","",melted$Totale.inventory))
melted$Data <- as.Date(melted$Data)
melted <- melted[order(melted$Data),]
melted <- melted[!is.na(melted$Totale.inventory),]
melted$Totale.inventory <- melted$Totale.inventory/1000000
melted$group <- "measured"
mSpline <- as.data.frame(spline(x=melted$Data,y=melted$Totale.inventory))
mSpline$x <- as.Date(mSpline$x,origin="1970-01-01")
## melted <- rbind(melted,ingombriW)
## melted[melted$group=="ingombri","Totale.inventory"] <- NA

model <- lm("Totale.inventory ~ Data",data=melted)
timeAll <- merge(melted,ingombriW,by.x="Data",by.y="date",all=TRUE)
pred <- predict(model,timeAll)

gLabel = c("data","impression (Mio/settimana)",paste("evoluzione bacino video"),"-")
p <- ggplot(melted,aes(x=Data,y=Totale.inventory))+
    geom_point(size=2,color=gCol1[3]) +
    geom_line(data=mSpline,aes(x=x,y=y,color="inventory"),size=1) +
##    geom_smooth(data=melted,method = "glm",family = gaussian(link="log"),aes(colour = "Exponential")) +
    stat_smooth(aes(color="polynomial fit",fill="polynomial"),method=lm,formula=y~poly(x,8),size=1,alpha=.1,show.legend=TRUE,linetype="solid") +
    stat_smooth(aes(color="spline fit",fill="spline"),method=lm,formula=y~splines::bs(x, 6),size=1,alpha=.1,show.legend=TRUE,linetype="solid") +
    geom_line(data=ingombriW,aes(x=date,y=imps,color="ingombri"),size=1) +
    geom_point(data=ingombriW,aes(x=date,y=imps,color="ingombri"),size=2) +
    theme(
        panel.background = element_blank(),
        legend.position="bottom"
    ) +
    guides(colour=guide_legend(title=""),fill="none") +
    scale_color_manual(values=c(gCol1[2],gCol1[5],gCol1[7],gCol1[9])) +
    scale_fill_manual(values=c(gCol1[5],gCol1[7])) +
    scale_x_date( limits=as.Date(c("2015-12-01","2016-08-01")) ) +
    scale_y_continuous( limits=c(0,70) ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p



## ##time series
## impr.ts = ts(melted$Totale.inventory, frequency=52,start=c(2013,10),end=c(2016,05))
## impr2 = window(impr.ts, start=c(2013,10), end=c(2015, 12))
## fit = stl(impr2, s.window="periodic")
## plot(fit)
## impr3 <- decompose(impr.ts)
## plot(impr3)
## spline(x=melted$Totale.inventory)

