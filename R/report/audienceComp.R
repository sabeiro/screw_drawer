#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')
library('svglite')
require(stats)
library(grid)
library('rjson')
library('jsonlite')
library('RJSONIO')
library(RCurl)

fs <- read.csv("raw/audReach.csv",stringsAsFactor=F)
## fs <- read.csv("raw/audienceReachElab.csv")
fs$reach <- fs$reach/1000
fs$group <- substring(fs$name,first=1,last=3)
fs$group <- tryTolower(fs$group)
fs1 <- read.csv("raw/audClusterMapBluekai.csv",stringsAsFactor=F)
for(i in 1:length(fs1$target)){
    set <-  match(fs$name,fs1$target[i])
    if(any(!is.na(set))){
        fs[!is.na(set),"group"] = fs1$cluster[i]
    }
}
fs = fs[!grepl("analisi",fs$group),]
fs$name <- fs$name %>% gsub("s-d ","",.) %>% gsub("[iI]-t ","",.) %>% gsub("[iI]-b ","",.) %>% gsub("pub ","",.) %>% gsub("g-o ","",.) %>% gsub("an ","",.) %>% gsub("brand","",.)
fs$dmp = "bk"
fs2 <- read.csv("raw/audReachBanzai.csv",stringsAsFactor=F)
fs2$reach = as.numeric(gsub("[[:punct:]]","",fs2$Devices))/1000
fs2$group = fs2$Type
fs2$name = fs2$Label
fs2$dmp = "kx"
fs1 <- read.csv("raw/audClusterMapBanzai.csv",stringsAsFactor=F)
for(i in 1:length(fs1$target)){
    set <-  match(fs2$name,fs1$target[i])
    if(any(!is.na(set))){
        fs2[!is.na(set),"group"] = fs1$cluster[i]
    }
}
fs2$name <- fs2$name %>% gsub("Travel ","",.) %>% gsub("eCommerce ","",.) %>% gsub("Studenti ","",.) %>% gsub("Cooking ","",.) %>% gsub("Età ","",.)

fs = rbind(fs[,c("name","reach","group","dmp")],fs2[,c("name","reach","group","dmp")])
fs = fs[order(fs$group),]
fs$label = paste("",round(ifelse(fs$reach > 100,fs$reach/1000,fs$reach),1),ifelse(fs$reach > 100,"M","k")  )
##melted <- fs[fs$group=="i-t",]
##melted <- melt(fs[grepl("SOCIODEMO",fs$Tier),-1],id="Segmento")
view = c(16,9)
view = c(view,sqrt(view[1]^2+view[2]^2))
grpSel <- c("abbigliamento","acquisti","animali","benessere","brand","casa","cucina","cultura","eventi","finanza","genitori","geo","istruzione","lifestyle","media","motori","socio-demo","sport","tech","viaggi")
fs = fs[fs$group %in% grpSel,]

grpL <- ddply(fs,.(group),summarise,n=length(reach),size=sum(reach))
grpL$img = paste("fig/ico_",grpL$group,".svg",sep="")
grpL$size = view[3]*grpL$size/sum(grpL$size)
grpL = grpL[order(-grpL$size),]
## var i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
## var k = diameter / v[2]; view = v;
## node.attr("transform", function(d) { return "translate(" + (d.x - v[0]) * k + "," + (d.y - v[1]) * k + ")"; });
grpL$x = cumsum(4*view[1]/1:nrow(grpL))
grpL$y = cumsum(grpL$size)
gCol1[1] = "#97003F"
grpL$color = gCol1[1:nrow(grpL)]

melted <- fs
melted <- merge(fs,grpL,by="group",all=T)
melted$x = melted$x + (melted$size/2 - runif(nrow(melted),0,melted$size))*4
melted$y = (melted[,c("group","n")] %>% group_by(group) %>% mutate_each(funs(cumsum(.)/.)))[2]
melted <- melted[order(melted$group,melted$name),]
melted1 <- melted

plotBubble <- function(i,melted1){
    melted1$x = runif(nrow(melted1),0,1.)#runif(nrow(melted1),0,melted1$size)/2
    melted1$y = runif(nrow(melted1),0,1.)#runif(nrow(melted1),0,melted1$size)/2
    grpL1 = grpL[grpL$group==grpL$group[i],]
    gLabel = c(NULL,NULL,NULL,NULL)
    xAv = .5#mean(melted1$x) + mean(melted1$x)/2
    yAv = .5#mean(melted1$y) + mean(melted1$y)/2
    p <- ggplot(melted1,aes(x=x,y=y,color=color)) +
        geom_point(aes(size=reach),alpha=0.4) +
        ##    geom_point(aes(size=imps),alpha=0.4) +
        geom_text(aes(label=name),hjust=1,size=3) +
        geom_text(aes(label=label),hjust=1,vjust=-0.5,size=4) +
        geom_text(data=grpL1,aes(x=xAv,y=yAv,label=group),hjust=1,size=15) +
        ##scale_size_area() +
        scale_size(range = c(0,20)) +
        ## scale_color_manual(values=melted1$color) +
        xlim(-.1,1.1) +
        ylim(-.1,1.1) +
        ##ylim(-2,2) +
        blankTheme +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
    p
}

i <- 2
polyP = list()
for(i in 1:nrow(grpL)){
    print(grpL[i,"group"])
    melted1 = melted[melted$group==grpL$group[i],]
    polyP[[i]] = plotBubble(i,melted1)
    polyP[[i]]$color = gCol1[i]
}

svg("intertino/fig/audCompRaw.svg",width=2*gWidth,height=2*gHeight)
grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3)
#            ,top=textGrob(refIds[i+1],gp=gpar(fontsize=20,font=3))
dev.off()




circL = list()
normF = view[3]/sum(fs$reach)
for(i in 1:nrow(grpL)){
    subL = list()
    gs = fs[fs$group == grpL[i,"group"],]
    for(j in 1:nrow(gs)){
        subL[[j]] = list(name=gs[j,"label"],size=gs[j,"reach"]*normF,label=paste(round(gs[j,"reach"]),"k"),color=gCol1[i])
    }
    circL[[i]] = list(name=grpL[i,"group"],size=grpL[i,"size"],children=subL,color=gCol1[i],img=grpL[i,"img"])
}
write(toJSON(list(name="audience offer",title="",children=circL),color="#ffffff"),"intertino/data/audience_offer.json")

##install.packages(c('beanplot','vioplot','digest'))
require('beanplot')
require(vioplot)
require(devtools)
require(digest)
##source_gist("https://gist.github.com/mbjoseph/5852613")

plot(x=NULL, y=NULL,xlim = c(0.5, 2.5), ylim=c(min(melted$reach), max(melted$reach)),type="n", ann=FALSE, axes=F)
axis(1, at=c(1, 2),  labels=c("A", "B"))
axis(2)
for (i in unique(melted$Gender)) {
    for (j in unique(melted$variable)){
        vioplot(melted$value[which(melted$Gender == i & melted$variable  == j)],at = ifelse(i == "Female", 1, 2),side = ifelse(j == "Zwoman", "left", "right"),col = ifelse(j == "Zwoman" , "purple", "lightblue"),add = T)
    }
}
title("Violin plot", xlab="Treatment")
legend("bottomright", fill = c("purple", "lightblue"),legend = c("Group 1", "Group 2"), box.lty=0)


labelN <- unique(melted$variable)
plot(x=NULL, y=NULL,xlim = c(0.5, 2.5), ylim=c(min(melted$value), max(melted$value)),type="n", ann=FALSE, axes=F)
axis(1, at=1:length(labelN),  labels=labelN)
axis(2)
for (j in 1:length(labelN)){
    vioplot(melted$value[melted$variable %in% labelN[j]],at=j,side=2,add=TRUE)
}





