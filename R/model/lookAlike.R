#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
library('dplyr')

cs <- read.csv("raw/campRoadhouseAud.csv")

cs <- read.csv("raw/lookAlikeTvLovers.csv")
cs <- cs[!grepl("Televisione",cs$Category.Path),]
cs <- cs[!grepl("Filippi",cs$Category.Name),]
cs <- cs[!grepl("TGCom",cs$Category.Name),]
cs <- cs[!grepl("TGCom",cs$Category.Name),]
cs <- cs[!grepl("Mediaset",cs$Category.Name),]
cs <- cs[!grepl("Mediaset",cs$Category.Path),]
cs <- cs[cs$Index > (min(names(tail(table(cs$Index),7)))),]
cumprob = 0.90

cs <- read.csv("raw/lookAlikeDonnamoderna.csv")
cs <- cs[!grepl("Donnamoderna",cs$Category.Name),]
cumprob = 0.90


cs <- read.csv("raw/lookAlikeZalando.csv")
cs <- cs[!grepl("ret",cs$Category.Path),]
cs <- cs[!grepl("ret",cs$Category.Name),]
cumprob = 0.90

cs <- read.csv("raw/lookAlikeMno.csv")
cs <- cs[!grepl("mno",cs$Category.Path),]
cs <- cs[!grepl("mno",cs$Category.Name),]
cumprob = 0.90

cs <- cs[grepl("RTI",cs$Category.Path),]
cs <- cs[!grepl("Geo",cs$Category.Path),]
cs <- cs[!grepl("Log",cs$Category.Path),]
cs <- cs[!grepl("Log",cs$Category.Name),]
cs <- cs[!grepl("percentili",cs$Category.Name),]
cs <- cs[!grepl("Hobby e Interessi",cs$Category.Name),]
cs <- cs[!grepl("Consumo Media",cs$Category.Name),]
cs <- cs[!grepl("Dati Personali",cs$Category.Name),]
cs <- cs[!grepl("Italia",cs$Category.Name),]
cs <- cs[!grepl("Televisione",cs$Category.Name),]
cs <- cs[!grepl("Web",cs$Category.Name),]
cs <- cs[!grepl("Internet",cs$Category.Name),]
cs <- cs[!grepl("Nielsen",cs$Category.Name),]
cs <- cs[!grepl("Age",cs$Category.Name),]

cs[,"lim"] <- (cs[,c("Index","Volume")] %>% group_by(Index) %>% mutate_each(funs(quantile(.,cumprob))))[2]
cs <- cs[cs$Volume >= cs$lim,]

cs$bkIndex <- cs$Index
table(cs$bkIndex)
cs <- cs[order(cs$Index),]
cs1 <- ddply(cs,.(Index),summarise,sVisitor=sum(Visitors),cVisitor=length(Visitors))
cs <- merge(cs,cs1)
cs$percent <- cs$Visitors/cs$cVisitor
cs$percent <- cs$Visitors/cs$sVisitor
cs$Index <- max(cs$Index)-cs$Index
cs$x <- cs$Index*cs$posL
##cs[nrow(cs)+1,] <- list(0,0,audN,"",1,1,0,0,1,1,1,0)
cs <- cs[order(cs$Index),]
cs[,"pos"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.))))[2]
cs[,"posL"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
cs$angle <- 0# 180-cs$posL*360

gLabel = c("\nCategory","Visitors",paste("Category Affinity"),"Name")
pie <- ggplot(cs) +
##    geom_bar(aes(x=Index,y=percent,fill=Category.Name),width = 1,stat="identity") +
    geom_point(aes(x=x,y=posL,color=Category.Name,size=Volume),stat="identity",alpha=0.5) +
    geom_point(aes(x=x,y=posL,color=Category.Name,size=Visitors),stat="identity",alpha=0.5) +
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




