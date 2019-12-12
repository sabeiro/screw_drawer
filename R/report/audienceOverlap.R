#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library(gridExtra)

if(FALSE){
    cs <- read.csv("raw/campRoadhouseAud.csv",stringsAsFactor=F)
    cs <- cs[cs$Index<=7,]
    cs <- read.csv("raw/campRoadhouseAud2.csv",stringsAsFactor=F)
    cs$Visitors <- as.numeric(gsub(",","",cs$Visitors))
    cs$Index <- as.numeric(gsub(",","",cs$Index))
    cs <- cs[grepl("RTI",cs$Category.Path),]
    cs <- cs[!grepl("advertiser",cs$Category.Name),]
    cs <- cs[!grepl("Log",cs$Category.Path),]
    cs <- cs[!grepl("Log",cs$Category.Name),]
    cs <- cs[!grepl("Web",cs$Category.Name),]
    cs <- cs[!grepl("Televisione",cs$Category.Name),]
    cs <- cs[!grepl("Geo",cs$Category.Path),]
}
if(FALSE){
    cs <- read.csv("raw/overlapMaxMara.csv",stringsAsFactor=F)
    fs1 <- read.csv("raw/audClusterMapBanzai.csv",stringsAsFactor=F)
    cs$group = "rest"
    for(i in 1:length(fs1$target)){
        ##set <- match(cs$Second.Segment,fs1$target[i])
        ##if(any(!is.na(set))){cs[!is.na(set),"group"] = fs1$cluster[i]}
        set <-  grepl(fs1$target[i],cs$Second.Segment)
        cs[set,"group"] = fs1$cluster[i]
    }
    ## cs = merge(cs,fs1,by.x="Second.Segment",by.y="target") 
    cs$Second.Segment = cs$Second.Segment %>% gsub("Banzai - ","",.) %>% gsub("\\[NAVIGAZ\\]","",.) %>% gsub("Analytics ","",.) %>% gsub("GM ","",.) %>% gsub("\\[DECLARED\\]","",.) %>% gsub("I \\- ","",.) %>% gsub("Banzai","",.) %>% gsub("ACQUISTO ","",.) %>% gsub("CARRELLO","",.)  %>% gsub("C\\.NA","",.)   %>% gsub("Interesse ","",.)   %>% gsub("L\\.A\\. [[:digit:]]\\% ","",.) %>% gsub("Travel","",.) %>% gsub("_ALL","",.)  %>% gsub("SD"," Donna",.)  %>% gsub("SU","Uomo",.) %>% gsub("SE","Età",.)  %>% gsub("BK M v","Uomini",.)  %>% gsub("BK F v","Donne",.) 
    cs$Second.Segment = cs$Second.Segment %>% gsub("\\(.*\\)","",.) %>% gsub("\\[.*\\]","",.) %>% gsub("\\- ","",.) %>% gsub(" ./.","",.) %>% gsub("^ ","",.) %>% gsub("^ ","",.)
    cs = cs[!grepl("c.._",cs$Second.Segment),]
    cs = cs[!grepl("K_",cs$Second.Segment),]
    cs = cs[!grepl("XXX_",cs$Second.Segment),]
    cs = cs[!grepl("Uomo_",cs$Second.Segment),]
    cs = cs[!grepl("Donna_",cs$Second.Segment),]
    breakN = unique(c(0,quantile(cs$Overlap.Population,rev(seq(1,15))/15,na.rm=T)))
    cs$Index <- as.numeric(cut(cs$Overlap.Population,breaks=breakN,labels=1:(length(breakN)-1)))
    cs$Visitors = cs$Overlap.Population
    cs$Category.Name = cs$Second.Segment
    cs$Volume = cs$Second.Segment.Population
    cs = cs[cs$Index > 5,]
}

##-------------------------------blob-plot------------------------------
loadAff <- function(fName){
    cs <- read.csv(fName,stringsAsFactor=F)
    cs = cs[!cs$OR==cs$AND,]
    cs$group = "rest"
    fs1 <- read.csv('raw/audClusterMapBluekai.csv',stringsAsFactor=F)
    for(i in 1:length(fs1$target)){
        set <-  match(cs$name,fs1$target[i])
        if(any(!is.na(set))){cs[!is.na(set),"group"] = fs1$cluster[i]}
    }
    cs = cs[cs$group %in% c("cucina","sport","bellezza","media","eventi","lifestyle","benessere","motori","acquisti","viaggi","tech","socio-demo","genitori","finanza","animali","cultura","geo","casa"),]
    ## c("cucina","obsolete","sport","bellezza","rest","analisi","media","eventi","lifestyle","benessere","sync","motori","brand","acquisti","viaggi","tech","socio-demo","genitori","finanza","animali","second","cultura","geo","casa")
    cs$name = cs$name %>% gsub("i-t ","",.) %>% gsub("an ","",.) %>% gsub("i-b ","",.) %>% gsub("brand","",.) %>% gsub("g-o ","",.) 
    cs$affinity = cs$AND/cs$second
    breakN = as.vector(unique(c(0,quantile(cs$AND,rev(seq(1,15))/15,na.rm=T))))
    breakN = breakN[order(breakN)]
    cs$OR = cs$OR/max(cs$OR)
    cs$AND = cs$AND/max(cs$AND)
    cs <- cs[!(cs$AND>=1.0 | cs$AND<=0.0),]
    breakN = seq(0,10)/10*max(cs$affinity)
    cs$Index <- as.numeric(cut(cs$affinity,breaks=breakN,labels=1:(length(breakN)-1)))
    cs = cs[rev(order(cs$affinity)),]
    cs1 <- ddply(cs,.(Index),summarise,grpSum=sum(affinity,na.rm=T))
    cs <- merge(cs,cs1)
    cs
}
fName="raw/audReachOverlap0.csv"
cs = loadAff(fName)

lim <- quantile(cs$posL,probs=c(.35,.65))
lim <- quantile(cs$posL,probs=c(.15,.95))
set <- (cs$posL > lim[1] & cs$posL < lim[2]) & (cs$Index < quantile(cs$Index,0.9))
set = TRUE
melted = cs[set,]
melted$percent <- melted$affinity/melted$grpSum
melted$Index <- max(melted$Index)-melted$Index
melted <- melted[order(melted$Index),]
melted[,"pos"] <- (melted[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.))))[2]
melted[,"posL"] <- (melted[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
melted$angle <- 0# 180-cs$posL*360
##cs$posL <- cs$posL/cs$Volume
gLabel = c("\nCategory","Visitors",paste(""),"Name")
pie <- ggplot(melted) +
    ##    geom_bar(aes(x=Index,y=percent,fill=Category.Name),width = 1,stat="identity") +
    geom_point(aes(x=Index,y=posL,color=group,size=AND),stat="identity",alpha=.7) +
    geom_point(aes(x=Index,y=posL,color=group,size=OR),stat="identity",alpha=0.3) +
    geom_text(aes(x=Index,y=posL,angle=angle,label=name),size=4) + 
    scale_color_manual(values=c(brewer.pal(11,'Spectral'),brewer.pal(11,'RdBu'),gCol1)) +
    blankTheme +
    theme(legend.position="right") + 
    scale_size(range = c(0, 40),guide=FALSE) +
    coord_polar("y",start=0) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
pie
ggsave(plot=pie,filename="fig/audOverlap.svg", height=2*gHeight, width=2*gWidth)
ggsave(plot=pie,filename="fig/audOverlap.jpg", height=2*gHeight, width=2*gWidth)

##-------------------------------bar-plot------------------------------

melted <- cs[,]
melted = melted[rev(order(melted$AND)),]
melted$name <- factor(melted$name,levels=melted$name)
freqG = table(melted$group)
melted = melted[melted$group %in% names(freqG[freqG>3]),]
gLabel = c("category","affinity",paste("audience affinity"),"gruppo")
polyP = list()
nCol = 1
gLabel = c("","",paste(""),"")
for(chPoly in unique(melted$group)){
    melted1 = melted[melted$group==chPoly,]
    polyP[[chPoly]] = ggplot(melted1) + 
        geom_bar(aes(x=name,y=affinity,fill=group),width = 1,stat="identity") +
        theme(
            ## panel.border = element_blank(),
            axis.text.y = element_blank(),
            ## axis.title.y = element_blank(), 
            legend.position="none"
            ## plot.background=element_blank(),
            ## panel.background = element_blank()
        ) +
        labs(x=gLabel[1],y=gLabel[2],title=chPoly,color=gLabel[4],fill=gLabel[5])
    polyP[[chPoly]]$color = gCol1[nCol]
    nCol = nCol + 1
}
grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3)

##svg("fig/audOverlapBar.svg")
jpeg("fig/audOverlapBarTab.jpg",width=2*pngWidth,height=2*pngHeight)
grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3)
dev.off()

melted <- cs[set,]
melted = melted[rev(order(melted$AND)),]
melted$name <- factor(melted$name,levels=melted$name)
bar <- ggplot(melted) +
    geom_bar(aes(x=name,y=AND,fill=group),width = 1,stat="identity") +
    scale_size(range = c(0, 20)) +
    scale_fill_manual(values=gCol1) +
    theme(
        text = element_text(size = 10)
    ) +
    ## coord_polar("y",start=0) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
bar
ggsave(plot=bar,filename="fig/audOverlapAffinity.jpg",height=gHeight,width=gWidth)


##-------------------------------radar-plot------------------------------

refIds = c("mediaset","Radio","Reality","Talent","temptation island","video viewers","donnamoderna","isola","mediaset.it","segreto","uomini e donne")
refIds = c("Viaggi")
i=0
for(i in 0:10){
    print(refIds[i+1])
    cs <- loadAff(paste("fig/overlap/audReachOverlap",i,".csv",sep=""))
    melted <- cs[,c("name","group","affinity","AND")]
    colnames(melted) <- c("X","variable","value","value2")
    melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.))))[2]
    melted[,"value2"] <- (melted[,c("variable","value2")] %>% group_by(variable) %>% mutate_each(funs(./max(.))))[2]
    melted = melted[order(melted$X,melted$variable),]
    melted$X = melted$X %>% gsub(" ","\n",.)
    freqG = table(melted$variable)
    melted = melted[melted$variable %in% names(freqG[freqG>3]),]
    nCol = 1
    polyP = list()
    gLabel = c("","",paste(""),"")
    for(chPoly in unique(melted$variable)){
        melted1 = melted[melted$variable==chPoly,]
        polyP[[chPoly]] = ggplot(melted1,aes(x=X,y=value,group=variable)) + 
            geom_polygon(aes(color=variable,fill=variable),alpha=0.4,size=1) +
            ## geom_polygon(aes(y=value2,fill=variable),alpha=0.4,size=1) +
            RadarTheme +
            theme(axis.text.x=element_text(angle=0, hjust=1)) + 
            coord_radar() +
            scale_y_continuous(limits=c(0,1.)) +
            guides(fill=guide_legend(keywidth=rel(1.3),keyheight=rel(1.3))) + 
            labs(x=gLabel[1],y=gLabel[2],title=chPoly,color=gLabel[4],fill=gLabel[5])
        polyP[[chPoly]]$color = gCol1[nCol]
        nCol = nCol + 1
    }
    ## grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3)
    ##svg("intertino/fig/skillRadar.svg")
    jpeg(paste("fig/overlap/audOverlapRadar",i,".jpg",sep=""),width=pngWidth,height=pngHeight)
    ##grid.text(refIds[i], vp = viewport(layout.pos.row = 1, layout.pos.col = 1:3))
    grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3,top=textGrob(refIds[i+1],gp=gpar(fontsize=20,font=3)))
    dev.off()
    svg("intertino/fig/skillRadar.svg")
    grid.arrange(grobs=lapply(polyP,function(p,i){p + scale_color_manual(values=p$color) +  scale_fill_manual(values=p$color)}),ncol=3,top=textGrob(refIds[i+1],gp=gpar(fontsize=20,font=3)))
    dev.off()
}
