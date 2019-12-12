#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
##install.packages(c('textcat','svglite'))
source('script/graphEnv.R')
library('corrplot') #package corrplot
library('svglite')
require(stats)
require(dplyr)
library(grid)
library(sqldf)
library('corrplot')
library(deldir)
library(tripack)
library(igraph)



fs <- read.csv('raw/audTvSuperposition.csv',stringsAsFactor=FALSE)
colnames(fs) <- colnames(fs) %>% gsub("FEDELI","",.)  %>% gsub("F\\.\\.","",.)
fs[row(fs) == (col(fs) - 1)] = 0
fs1 <- read.csv('raw/audTvSuperpositionTot.csv',stringsAsFactor=FALSE)

melted <- melt(fs)
melted$variable <- melted$variable %>% gsub("\\."," ",.)
melted$group <- "altri"
melted$group[grepl("RAI",melted$variable)] <- "RAI"
melted <- merge(melted,fs1,by.x="X",by.y="X",all.x=T)

gLabel = c("Canale","Fedeli",paste("sovrapposizione",""),"percentuale")
p <- ggplot(melted,aes(x=X,y=variable,group=variable)) +
    geom_raster(aes(fill = value), interpolate = TRUE,alpha=0.7) + 
    geom_tile(aes(fill=value,color=INDIVIDUI),size=1,width=0.9,height=0.9) +
    geom_text(aes(fill=value,label=paste(formatC(value,digit=0,format="f"),"",sep="")),colour="white",size=5) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
##    scale_fill_gradient(low="white",high="steelblue") +
##    facet_grid(. ~ group) + ##,scales = "free", space = "free") +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        panel.background = element_blank()
    )
p
ggsave(file="fig/audTvSuperpositionHeatmap.png", plot=p, width=gWidth, height=gHeight)

##correlation plot
corM <- as.matrix(fs[,-1])
corrplot.mixed(cor(corM),lower="pie",upper="number")
##voronoi
gp_graph = graph.adjacency(corM, weighted=TRUE,mode = "max",add.rownames=TRUE)
posi_matrix = layout.spring(gp_graph, list(weightsA=E(gp_graph)$weight))
posi_matrix = cbind(V(gp_graph)$name, posi_matrix)
gp_df = data.frame(posi_matrix, stringsAsFactors=FALSE)
names(gp_df) = c("word", "x", "y")
gp_df$x = as.numeric(gp_df$x)
gp_df$y = as.numeric(gp_df$y)
gp_df$z = fs1[-1,"INDIVIDUI"]
##se = diag(corM) / max(diag(corM))

corr_km = kmeans(corM,5)
corr_km = kmeans(cbind(as.numeric(posi_matrix[,2]), as.numeric(posi_matrix[,3])),5)
V <- voronoi.mosaic(corr_km$centers[,1],corr_km$centers[,2])
P <- voronoi.polygons(V)
voro <- deldir(corr_km$centers[,1],corr_km$centers[,2])


p = ggplot(gp_df, aes(x=x, y=y)) +
    geom_text(aes(size=z, label=gp_df$word, alpha=.90,)) + # color=as.factor(cluster))) +
    geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2),size = 1,data = voro$dirsgs,linetype = "dotted",color= "#FFB958") +
##scale_size_continuous(breaks = c(10,20,30,40,50,60,70,80,90), range = c(1,8)) +
    scale_colour_manual(values=skillPal) +
    scale_x_continuous(breaks=c(min(gp_df$x), max(gp_df$x)), labels=c("","")) +
    scale_y_continuous(breaks=c(min(gp_df$y), max(gp_df$y)), labels=c("","")) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
    theme(panel.grid.major=element_blank(),
          legend.position="none",
          panel.background = element_rect(fill="transparent",colour=NA),
          panel.grid.minor=element_blank(),
          axis.ticks=element_blank(),
          title = element_text("Skills clustering"),
          plot.title = element_text(size=12))
plot(p)

ggsave(plot=p,"fig/audTvSuperpositionVoronoi.png", width=gWidth,height=gHeight)



