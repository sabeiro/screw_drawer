#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library(maps)
library(maptools)
library(RColorBrewer)
library(classInt)
## library(spam)
## library(maps)
## library(rworldmap)
## library(deldir)
## library(sp)
## library(rgdal)
## library(ggthemes)
## library(rgeos)
## library(htmltools)
## library(leaflet)


itPop <- read.csv("raw/itPopulation.csv")


data(italyMapEnv)

it <- map('italy', fill = TRUE, col="grey96")

itReg <- list()
itReg[["ValDAosta"]] <- it$names[15]
itReg[["Piemonte"]]   <- it$names[c(6,16,24,32,35,40)]
itReg[["Lombardia"]]   <- it$names[c(4,8,9,10,12,20,25,28,29)]
itReg[["Liguria"]]  <- it$names[c(44,51,46,42)]
itReg[["TrentinoAltoAdige"]] <- it$names[c(1,5)]
itReg[["Veneto"]] <-  it$names[c(2,11,14,17,18,23, 26,27, 30, 31, 33)]
itReg[["FriuliVeneziaGiulia"]] <-  it$names[c(3,7,13,22,19,21)]
itReg[["EmiliaRomagna"]] <- it$names[c(34,36,37,38,39,41,43,47)]
itReg[["Toscana"]] <- it$names[c(45,48,49,50,53,54,55,57,59,63,66,62,69,73,74)]
itReg[["Marche"]]  <- it$names[c(52,56,60,61)]
itReg[["Umbria"]]  <- it$names[c(58,64)]
itReg[["Abruzzo"]] <- it$names[c(65,70,71,72)]
itReg[["Molise"]]  <- it$names[c(76,79)]
itReg[["Lazio"]]   <- it$names[c(67,68,75,78,80,92)]
itReg[["Campania"]]<- it$names[c(81,82,84,88,91,96,99,100,101)]
itReg[["Basilicata"]] <- it$names[c(89,97)]
itReg[["Puglia"]]   <- it$names[c(77,83,94,98,102)]
itReg[["Calabria"]] <- it$names[c(104,106,111)]
itReg[["Sicilia"]]  <- it$names[c(108,109,110,112:133)]
itReg[["Sardegna"]]<- it$names[c(85,86,87,90,93,95,103,105,107)]
it$reg[15] <- "ValDAosta"
it$reg[c(6,16,24,32,35,40)] <- "Piemonte"
it$reg[c(4,8,9,10,12,20,25,28,29)] <- "Lombardia"
it$reg[c(44,51,46,42)] <- "Liguria"
it$reg[c(1,5)] <- "TrentinoAltoAdige"
it$reg[c(2,11,14,17,18,23, 26,27, 30, 31, 33)] <- "Veneto"
it$reg[c(3,7,13,22,19,21)] <- "FriuliVeneziaGiulia"
it$reg[c(34,36,37,38,39,41,43,47)] <- "EmiliaRomagna"
it$reg[c(45,48,49,50,53,54,55,57,59,63,66,62,69,73,74)] <- "Toscana"
it$reg[c(52,56,60,61)] <- "Marche"
it$reg[c(58,64)] <- "Umbria"
it$reg[c(65,70,71,72)] <- "Abruzzo"
it$reg[c(76,79)] <- "Molise"
it$reg[c(67,68,75,78,80,92)] <- "Lazio"
it$reg[c(81,82,84,88,91,96,99,100,101)] <- "Campania"
it$reg[c(89,97)] <- "Basilicata"
it$reg[c(77,83,94,98,102)] <- "Puglia"
it$reg[c(104,106,111)] <- "Calabria"
it$reg[c(108,109,110,112:133)] <- "Sicilia"
it$reg[c(85,86,87,90,93,95,103,105,107)] <- "Sardegna"



traffic <- read.csv("out/trafficRegione.csv")
nSlice <- length(traffic$imps)
traffic$imps <- as.numeric(traffic$imps)
tot <- sum(traffic$imps,na.rm=TRUE)
traffic$name <- as.character(traffic$IpRegione)
traffic$name <- gsub("[[:punct:]]","",traffic$name)
traffic$name <- gsub("Venezia Giulia","VeneziaGiulia",traffic$name)
traffic$name <- gsub("Alto Adige","AltoAdige",traffic$name)
traffic[grepl("Valle",traffic$name),"name"] = "ValDAosta"
traffic <- ddply(traffic,.(name),summarise,imps=sum(imps))
traffic <- traffic[order(-traffic$imps),]
traffic[1,"name"] <- "sconosciuto"

melted <- traffic[1:nSlice,c("name","imps")]
rest <- tot - sum(melted$imps,na.rm=TRUE)
melted <- rbind(melted,c("resto",rest))
##melted[nSlice+2,] <- c("total",tot)
melted$imps <- as.numeric(melted$imps)
pop <- itPop[match(melted$name,itPop$Regione),"Popolazione"]
melted$share <- melted$imps/pop
melted$percentage <- melted$imps/sum(melted$imps)
melted$name <- factor(melted$name , levels=melted$name )

colors <- brewer.pal(9, "YlOrRd") #set breaks for the 9 colors
brks <- classIntervals(melted$imps, n=9, style="quantile")
brks <- brks$brks #plot the map
melted$col <- colors[findInterval(melted$imps,brks,all.inside=TRUE)]
##as.numeric(cut(unemp$unemp, c(0, 2, 4, 6, 8, 10, 100)))
it$col <- melted[match(it$reg,melted$name),"col"]

## i <- 3
## provList <- data.frame(name=as.character(),col=as.character(),imps=as.numeric())
## ##colList <- data.frame(col=as.character())
## for(i in 1:length(melted$name)){
##     set <- melted$name[i]==names(itReg)
##     if(!any(set)){next}
##     reg <- itReg[set]
##     regList <- data.frame(name = reg[[1]])
##     ##colList <- rbind(colList,rep(melted$col[i],length(reg[[1]])))
##     regList$col <- melted$col[i]
##     regList$imps <- melted$imps[i]
##     regList$reg <- melted$name[i]
##     provList <- rbind(provList,regList)
##     ##map('italy', regions=reg, fill = TRUE, col=melted$col[i],add=TRUE)
## }
## provList$name <- as.character(provList$name)
## ##provList$name <- factor(provList$name , levels=provList[order(-provList$imps),"name"])
## set <- na.omit(match(provList$name,it$names))
## provList$col <- provList[set,"col"]

fName <- paste("fig/trafficRegionImps",".png",sep="")
png(fName,width=pngWidth,height=pngHeight)
map('italy', regions=it$names, fill = TRUE, col=it$col,resolution = 0,lty = 0, projection = "polyconic")
title("millions of impressions per month")
brks <- classIntervals(melted$imps, n=9, style="quantile")
leg.txt <- as.character(round(brks$brks/1000000,0))[-1]
leg.val <- melted$col[match(unique(melted$col),melted$col)]
leg.val <- leg.val[seq(9,1,-1)]
legend("bottom", leg.txt, horiz = TRUE, fill = leg.val,lty = 0)
dev.off()


colors <- brewer.pal(9, "YlOrRd") #set breaks for the 9 colors
brks <- classIntervals(melted$share, n=9, style="quantile")
brks <- brks$brks #plot the map
melted$col <- colors[findInterval(melted$share,brks,all.inside=TRUE)]
##as.numeric(cut(unemp$unemp, c(0, 2, 4, 6, 8, 10, 100)))
it$col <- melted[match(it$reg,melted$name),"col"]
fName <- paste("fig/trafficRegionShare",".png",sep="")
png(fName,width=pngWidth,height=pngHeight)
map('italy', regions=it$names, fill = TRUE, col=it$col,resolution = 0,lty = 0, projection = "polyconic")
title("impressions pro capita per month")
leg.txt <- as.character(round(brks,0))[-1]
leg.val <- melted$col[match(unique(melted$col),melted$col)]
leg.val <- leg.val[seq(9,1,-1)]
legend("bottom", leg.txt, horiz = TRUE, fill = leg.val,lty = 0)
dev.off()


                                        #6.630898 18.521835 35.489235 47.090942


legend(x=6298809, y=2350000, legend=leglabs(round(brks)), fill=colors, bty="n",x.intersp = .5, y.intersp = .5)

gLabel = c("","impression",paste("provider share",""),"provider")
pie <- ggplot(melted, aes(x = "",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    geom_text(aes(y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    theme_bw() +
    theme(
        panel.border = element_blank(),
        text = element_text(size = gFontSize),
        panel.background = element_blank()
    ) +
    coord_polar("y",start=0)
pie
fName <- paste("fig/trafficRegionShare",".png",sep="")
ggsave(file=fName, plot=pie, width=gWidth, height=gHeight,units="in",dpi=gRes)



library(rworldmap)
library(RColorBrewer)

                                        #get a coarse resolution map
sPDF <- getMap()

                                        #using your green colours
mapDevice('x11') #create a map shaped device
numCats <- 100 #set number of categories to use
palette = colorRampPalette(brewer.pal(n=9, name='Greens'))(numCats)
mapCountryData(sPDF,nameColumnToPlot="POP_EST",catMethod="fixedWidth",numCats=numCats,colourPalette=palette)



library(RColorBrewer)
library(maptools)
library(ggplot2)

data(wrld_simpl)

ddf = read.table(text="
                 country value
                 'United States' 10
                 'United Kingdom' 30
                 'Sweden' 50
                 'Japan' 70
                 'China' 90
                 'Germany' 100
                 'France' 80
                 'Italy' 60
                 'Nepal' 40
                 'Nigeria' 20", header=TRUE)

                                        # Pascal had a #spiffy solution that is generally faster

plotPascal <- function() {

    pal <- colorRampPalette(brewer.pal(9, 'Reds'))(length(ddf$value))
    pal <- pal[with(ddf, findInterval(value, sort(unique(value))))]

    col <- rep(grey(0.8), length(wrld_simpl@data$NAME))
    col[match(ddf$country, wrld_simpl@data$NAME)] <- pal

    plot(wrld_simpl, col = col)

}

plotme <- function() {

                                        # align colors to countries

    ddf$brk <- cut(ddf$value,
                   breaks=c(0, sort(ddf$value)),
                   labels=as.character(ddf[order(ddf$value),]$country),
                   include.lowest=TRUE)

                                        # this lets us use the contry name vs 3-letter ISO
    wrld_simpl@data$id <- wrld_simpl@data$NAME

    wrld <- fortify(wrld_simpl, region="id")
    wrld <- subset(wrld, id != "Antarctica") # we don't rly need Antarctica

    gg <- ggplot()

                                        # setup base map
    gg <- gg + geom_map(data=wrld, map=wrld, aes(map_id=id, x=long, y=lat), fill="white", color="#7f7f7f", size=0.25)

                                        # add our colored regions
    gg <- gg + geom_map(data=ddf, map=wrld, aes(map_id=country, fill=brk),  color="white", size=0.25)

                                        # this sets the scale and, hence, the legend
    gg <- gg + scale_fill_manual(values=colorRampPalette(brewer.pal(9, 'Reds'))(length(ddf$value)),
                                 name="Country")

                                        # this gives us proper coords. mercator proj is default
    gg <- gg + coord_map()
    gg <- gg + labs(x="", y="")
    gg <- gg + theme(plot.background = element_rect(fill = "transparent", colour = NA),
                     panel.border = element_blank(),
                     panel.background = element_rect(fill = "transparent", colour = NA),
                     panel.grid = element_blank(),
                     axis.text = element_blank(),
                     axis.ticks = element_blank(),
                     legend.position = "right")
    gg

}

system.time(plotme())
##  user  system elapsed
## 1.911   0.005   1.915

system.time(plotthem())
##  user  system elapsed
## 1.125   0.014   1.138
