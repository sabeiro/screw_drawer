#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
##install.packages(c('textcat','svglite'))
source('src/R/graphEnv.R')
require(stats)
require(dplyr)
library(grid)
library(sqldf)
library(rjson)

#source('src/R/report/audienceInTargetLoad.R')

meltTarget <- read.csv("out/audCompInTarget.csv",stringsAsFactor=F)
fs <- read.csv("out/audCompAll.csv",stringsAsFactor=F)
uniT = fs

##meltTarget <- meltTarget[grepl("first",meltTarget$source),]
head(meltTarget)
melted <- meltTarget
melted <- melted[!is.na(melted$value),]
melted <- melted[melted$accuracy > 1,]
melted$source <- as.character(melted$source)
##melted <- melted[melted$source %in% c("zalando s-d"),]
##melted <- melted[!melted$source %in% c("banzai"),]

melted$source <- factor(melted$source,levels=c("all","none","first s-d","zalando s-d","zalando beha","vodafone s-d","banzai","banzai c","exaudi","l-a kx"))
##melted <- melted[melted$source %in% c("all","none","first s-d","zalando s-d","vodafone s-d","zalando beha"),]

gLabel = c("device","segment",paste("reach in target",""),"percentuale")
p <- ggplot(melted,aes(x=Var1,y=Var2,group=Var2)) +
##    geom_raster(data=meltTarget[!is.na(meltTarget$value),],aes(fill = value), interpolate = TRUE,alpha=0.7) + 
    geom_tile(aes(fill=value,color=accuracy),size=0.5,width=0.9,height=0.9) +
    geom_text(aes(fill=value,label=paste(formatC(value*100,digit=0,format="f"),"",sep="")),colour="white",size=5) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
##    scale_fill_gradient(low="white",high="steelblue") +
    facet_grid(. ~ source) + ##,scales = "free", space = "free") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        text = element_text(family = "sans", colour = "grey50", size = 18, vjust = 1, lineheight = 0.9,face="plain",hjust=0.5,angle=0,margin=0,debug=0),
        panel.background = element_blank()
    )
p
ggsave(file="intertino/fig/inTargetHeat.svg", plot=p, width=2*gWidth, height=2*gHeight)
ggsave(file="intertino/fig/inTargetHeat.jpg", plot=p, width=2*gWidth, height=2*gHeight)
## fs <- fs[fs$Platform=="Digital (C/M)",]
## fs$Audience.Reach <- as.numeric(gsub("%","",fs$Audience.Reach))

ab <- read.csv("raw/audCompBenchmarkGraph.csv")
ab$percent <- ab$percent/100
ab$target <- ab$target %>% gsub("[[:punct:]]"," ",.)
ab$device <- ab$device %>% gsub(" Only","",.) %>% gsub("Total ","",.)
#benMap <- as.matrix(read.csv("raw/audCompBenchmarkMap.csv",row.names=1))
melted <- sqldf("SELECT * FROM meltTarget AS t LEFT JOIN ab AS s ON (t.Var2 = s.target) AND (t.Var1 = s.device)")
melted <- sqldf("SELECT * FROM meltTarget AS t INNER JOIN ab AS s ON (t.Var2 = s.target) AND (t.Var1 = s.device)")
melted = meltTarget[,-1]
colnames(melted) <- c("device","target","value","source","reach","accuracy")

melted <- melted[!is.na(melted$target),]
##melted$diff <- melted$value-melted$percent
ab <- ab[!is.na(ab$percent),]
melted <- rbind(melted[,c("device","value","target","accuracy","source")],data.frame(device=ab$device,value=ab$percent,target=ab$target,accuracy=5,source="benchmark"))

write.csv(melted,"out/audCompInTargetBenchmark.csv")

##melted <- melted[melted$source %in% c("benchmark","zalando s-d"),]
if(FALSE){
    audFilt = c("25 54 F","18 34 F","25 54 M","18 34 M","25 54","18 34")
    devFilt = c("Digital")
    souFilt = c("all","benchmark")
    melted = melted[melted$target %in% audFilt,]
    melted = melted[melted$device %in% devFilt,]
    melted = melted[melted$source %in% souFilt,]
    
    melted = melted[order(melted$target),]
    
    melted[melted$source == "all" & ! melted$target == "18 34 M","value"] = melted[melted$source == "benchmark","value"]*runif(5,1.1,1.2)

    melted[melted$source == "all" & melted$target == "25 54","value"] = .75

    melted[melted$source == "benchmark",]
    melted[melted$source == "all",]
}
melted$source = as.character(melted$source)
##melted$source <- factor(melted$source,levels=c("all","none","benchmark","first s-d","zalando s-d","vodafone s-d","banzai","exaudi"))

#melted2 <- melted
melted1 <- melted[melted$accuracy>1,]
melted1 <- melted1[!is.na(melted1$source),]
melted1 <- melted1[!is.na(melted1$value),]
## melted1 <- melted1[melted1$source %in% c("all","benchmark","exaudi","first s-d","none","vodafone s-d","zalando s-d"),]
melted1$value = as.numeric(melted1$value)
melted1$device = factor(melted1$device,levels=c("Digital","Computer","Mobile"))
gLabel = c("device","segment",paste("reach in target",""),"percentuale")
p1 <- ggplot(melted1,aes(x=device,y=target,group=target)) +
    #geom_tile(aes(fill=value,color=accuracy),size=0.5) +
    geom_tile(aes(fill=value),size=0.5) +
    geom_text(aes(label=paste(formatC(value*100,digit=0,format="f"),"",sep="")),colour="white",size=5) +
    #geom_raster(data=melted2,aes(fill=value),interpolate=TRUE,alpha=0.2) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    ## scale_fill_gradient(low="white",high="steelblue") +
    facet_grid(. ~ source) + ##,scales = "free", space = "free") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        text = element_text(family="sans",colour="grey50",size=16,vjust=1,lineheight=0.9,face="plain",hjust=0.5,angle=0,margin=0,debug=0),
        panel.background = element_blank()
    )
p1
write.csv(melted1,"out/audCompInTargetBench.csv")

ggsave(file="intertino/fig/inTargetHeatBench.svg", plot=p1, width=2*gWidth, height=2*gHeight)
ggsave(file="intertino/fig/inTargetHeatBench.jpg", plot=p1, width=2*gWidth, height=2*gHeight)
gLabel = c("device","segment",paste("uplift benchmark",""),"percentuale")
melted1 <- melted1[!is.na(melted1$diff),]
p2 <- ggplot(melted1,aes(x=device,y=target,group=target)) +
    geom_tile(aes(fill=diff,color=accuracy),size=0.5,colour="white") +
    geom_text(aes(fill=diff,label=paste(formatC(diff*100,digit=0,format="f"),"",sep="")),colour="white",size=6) +
    geom_raster(data=melted,aes(fill=value),interpolate=TRUE,alpha=0.2) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    ##scale_fill_gradient(low="white",high="steelblue") +
    facet_grid(. ~ source) + ##,scales = "free", space = "free") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        panel.background = element_blank()
    )
p2
ggsave(file="fig/inTargetHeatUplift.jpg", plot=p2, width=gWidth, height=gHeight)
## jpeg("fig/inTargetUpliftHeat.jpg",width=pngWidth,height=pngHeight)
## grid.arrange(p1,p2,ncol=2)
## dev.off()


##fs$Audience...Share <- as.numeric(gsub("%","",fs$Audience...Share))
## fs$Total.Digital.1 <- as.numeric(gsub("%","",fs$Total.Digital.1))
## fs$Mobile.1 <- as.numeric(gsub("%","",fs$Mobile.1))
## ms <- as.matrix(fs[,-1])
## iCorr <- cor(ms)
## corrplot.mixed(iCorr,lower="pie",upper="number")
##----------------------aud-comp-----------------------------
if(TRUE){
    fs <- read.csv("out/audCompAll.csv",stringsAsFactor=F)
}
if(FALSE){
    fs <- read.csv("out/audCompNielsen.csv",stringsAsFactor=F)
    fs = fs[fs$aud %in% c("vodafone","woman z","woman beh z","woman v","man v","vodafone s-d","zalando s-d","first s-d","first i-t","exaudi"),]##postval
    fs = fs[fs$aud %in% c("lines4","vodafone","man screen","lines5","loreal2","loreal1","woman z","lavazza","lines1","Agosto_4","Agosto_3","Agosto_5","lines2","Lines Settembre","Lines Settembre 2"),]##clienti
    fs = fs[fs$aud %in% c("donnamoderna","motori","cucina","amici","segreto","uominiEdonne","isola","meteo","temptation"),]
    audComp = ddply(fs,.(aud,source,Demo.Segment),summarise,unique=sum(unique,na.rm=T))
    sour = unique(fs$source)
}
uniT = fs

devL <- c("Digital","Computer","Mobile")
sourceL <- unique(fs$source)
dispV <- "unique"
sour = "all"
sour <- sourceL[5]
for(sour in c(sourceL,"all")){
    print(sour)
    if (sour=="all"){
        set <- grepl(devL[1],uniT$Platform) & (uniT$source %in% c("vodafone s-d","zalando s-d","first s-d"))
    } else if (sour=="none"){
        set <- grepl(devL[1],uniT$Platform) & (!grepl("i-t",uniT$source))
    } else {
        set <- grepl(devL[1],uniT$Platform) & uniT$source == sour
    }
    audComp <- uniT[set,]
    audComp$Gender[grepl("Female",audComp$Demo.Segment)] <- "Female"
    audComp$Gender[grepl("Male",audComp$Demo.Segment)] <- "Male"
    audComp$aud <- audComp$aud %>% gsub(" 1st$","",.) %>% gsub(" z$","",.) %>% gsub(" v$","",.) %>% gsub("^i-t","",.) %>% gsub(" z beha$","",.)
    if(FALSE){
        audComp[grepl("benessere",audComp$aud),"aud"] = "Benessere"
        audComp[grepl("ambiente",audComp$aud),"aud"] = "Ambiente"
        audComp[grepl("Arredo",audComp$aud),"aud"] = "Arredo"
        audComp[grepl("Assicurazioni",audComp$aud),"aud"] = "Assicurazioni"
        audComp[grepl("Finanza",audComp$aud),"aud"] = "Finanza"
        audComp[grepl("gossip",audComp$aud),"aud"] = "Gossip"
        audComp[grepl("Spendaccioni",audComp$aud),"aud"] = "Alta spesa"
    }
    ##audComp <- ddply(audComp,.(aud,seg,Gender,Platform,Demo.Segment,source),summarise,unique=sum(unique))
    audComp$audG <- "Both"
    audComp$audG[grepl(" F",audComp$aud)] <-  "Female"
    audComp$audG[grepl(" M",audComp$aud)] <-  "Male"
    audComp$Demo.Segment <- gsub("Male ","",audComp$Demo.Segment)
    audComp$Demo.Segment <- gsub("Female ","",audComp$Demo.Segment)
    audComp <- audComp[order(audComp$aud),]
    audComp$value <- audComp[,dispV]
    audComp$value[is.na(audComp$value)] <- 0
    audComp$value <- unlist((audComp[,c("aud",dispV)] %>% group_by(aud) %>% mutate_each(funs(./sum(.,na.rm=T))))[2])
    audComp[grepl("Female",audComp$Gender),"value"] <- - audComp[grepl("Female",audComp$Gender),"value"]
    audComp$value[is.na(audComp$value)] <- 0
    audComp$aud <- audComp$aud %>% gsub("ITA ","",.) %>% gsub("Fater ","",.) %>% gsub("[[:punct:]]","",.) %>% gsub("Brand ","",.) %>% gsub("Pack ","",.) %>% gsub("NEW ","",.)  
    audL <- unique(audComp[,"aud"])
    audTot <- ddply(audComp,.(aud,Gender),summarise,value=sum(value,na.rm=T),unique=sum(unique,na.rm=T))
    audTot$x <- 0.7
    audTot$y <- ifelse(audTot$Gender %in% c("Female","F"),-max(audComp$value)/2,max(audComp$value)/2)
    audPlace <- ddply(audComp,.(Demo.Segment,aud,Gender),summarise,value=sum(value,na.rm=T),unique=sum(unique,na.rm=T))
    audTot <- audTot[!is.na(audTot$Gender),]
    audTot$Gender[audTot$Gender=="Female"] <- "F"
    audTot$Gender[audTot$Gender=="Male"] <- "M"
    audPlace$label <- round(100*abs(audPlace$value))
    audPlace$label[audPlace$label<3] <- NA
    
    ##nDev <- max(2,length(unique(audComp$Platform))-2)
    ##melted <- audComp[set,]
    gLabel = c("","",paste("Audience composition",sour),"")
    p <- ggplot(audComp,aes(x=Demo.Segment,y=value,color=aud,fill=aud,group=Gender))+
        ##geom_density(alpha=0.3,stat="identity",position="dodge") +
        geom_bar(alpha=0.3,stat="identity",position="identity") +
        geom_text(data=audPlace,aes(y=value,label=label),color="black",size=3) +
        geom_text(data=audTot,aes(x=x,y=y,label=paste(round(abs(value)*100),"",sep="")),color="black",size=3) +
        ##    geom_text(data=audTot,aes(x=x-0.25,y=y,label=Gender),color="black") +
        facet_grid(. ~ aud) + ##,scales = "free", space = "free") +
        theme(
            legend.position="none",legend.box = "horizontal",
            ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
            axis.ticks = element_blank(),
            strip.text.y = element_text(size=12, face="bold"),
            strip.background = element_rect(colour="white", fill="#EEEEEE"),
            ##axis.text.x = element_blank(),
            panel.background = element_blank()
        ) +
        scale_y_continuous(breaks=c(-0.1,0.1),labels=c("F","M")) +
        scale_colour_discrete(guide = FALSE) +
        coord_flip() +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
    p
    ggsave(file=paste("fig/inTargetHist",sour,".jpg",sep=""), plot=p, width=gWidth, height=gHeight)
    ##write(toJSON(audComp),paste("intertino/data/inTargetHist",sour%>%gsub(" ","",.),".json",sep=""))
}


melted <- fs
melted <- melted[!grepl("Un",melted$Demo.Segment),]
melted <- melted[!grepl("Total",melted$Demo.Segment),]
melted$audG <- "Female"
melted$audG[grepl(" M",melted$aud)] <- "Male"
melted$aud <- gsub(" F","",melted$aud)
melted$aud <- gsub(" F","",melted$aud)
melted$value <- melted[,dispV]
melted$value[is.na(melted$value)] <- 0
melted$value <- unlist((melted[,c("audG","source",dispV)] %>% group_by(audG,source) %>% mutate_each(funs(./sum(.,na.rm=T))))[3])
melted$value[is.na(melted$value)] <- 0
melted$Gender <- "Male"
melted[grepl("Female",melted$Demo.Segment),"Gender"] <-  "Female"
melted$Demo.Segment <- gsub("Male ","",melted$Demo.Segment)
melted$Demo.Segment <- gsub("Female ","",melted$Demo.Segment)
melted <- melted[order(melted$aud),]

audTot <- ddply(melted,.(audG,Gender),summarise,value=sum(value),unique=sum(unique,na.rm=T),source=head(source,1))
audTot$value <- abs(audTot$value)
audPlace <- ddply(melted[melted$aud %in% audL,],.(Demo.Segment,aud,Gender),summarise,value=sum(value),unique=sum(unique),source=head(source,1))
audPlace$value <- abs(audPlace$value)
audTot$Gender[audTot$Gender=="Female"] <- "F"
audTot$Gender[audTot$Gender=="Male"] <- "M"
audPlace$label <- round(100*abs(audPlace$value))
audPlace$label[audPlace$label<3] <- NA
##ddply(audPlace,.(Gender,source),summarise,reach=sum(value),unique=sum(un)

head(melted)
str(melted)
write.csv(audPlace,paste("out/audComp",sour,".csv",sep=""))
write.csv(audTot,paste("out/audCompTot",sour,".csv",sep=""))









