#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library(maps)
region_map <- map_data("italy")
library(deldir)
library(tripack)
library(gridExtra)
library('corrplot')


cs <- read.csv("raw/overlapMaxMara.csv",stringsAsFactor=F)
cs$Second.Segment = cs$Second.Segment %>% gsub("Banzai - ","",.) %>% gsub("[NAVIGAZ]","",.) %>% gsub("Analytics ","",.) %>% gsub("GM ","",.) %>% gsub("[DECLARED]","",.) %>% gsub("I - ","",.) %>% gsub("Banzai","",.) 
cs = cs[!grepl("K_",cs$Second.Segment),]
cs = cs[!grepl("XXX_",cs$Second.Segment),]
breakN = unique(c(0,quantile(cs$Overlap.Population,seq(1,15)/15,na.rm=T)))
cs$Index <- as.numeric(cut(cs$Overlap.Population,breaks=breakN,labels=1:(length(breakN)-1)))



cs$Index
head(cs)
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

cs1 <- ddply(cs,.(Index),summarise,sVisitor=sum(Visitors,na.rm=T))
cs <- merge(cs,cs1)
cs$percent <- cs$Visitors/cs$sVisitor
cs$Index <- max(cs$Index)-cs$Index
cs <- cs[order(cs$Index),]
cs[,"pos"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.))))[2]
cs[,"posL"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
cs$angle <- 0# 180-cs$posL*360

##cs$posL <- cs$posL/cs$Volume
lim <- quantile(cs$posL,probs=c(.35,.65))
lim <- quantile(cs$posL,probs=c(.45,.55))
set <- (cs$posL > lim[1] & cs$posL < lim[2]) & (cs$Index < quantile(cs$Index,0.9))

gLabel = c("\nCategory","Visitors",paste("Category Affinity"),"Name")
pie <- ggplot(cs[set,]) +
##    geom_bar(aes(x=Index,y=percent,fill=Category.Name),width = 1,stat="identity") +
    geom_point(aes(x=Index,y=posL,color=Category.Name,size=Volume),stat="identity",alpha=0.5) +
    geom_point(aes(x=Index,y=posL,color=Category.Name,size=Visitors),stat="identity",alpha=0.5) +
    theme_bw() +
    geom_text(aes(x=Index,y=posL,angle=angle,label=Category.Name),size=4) + 
    scale_size(range = c(0, 30)) +
    theme(
        panel.border = element_blank(),
        text = element_text(size = gFontSize),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks=element_blank(),
        legend.position="none",
        plot.background=element_blank(),
        panel.background = element_blank()
    ) +
    coord_polar("y",start=0) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
pie



 
