
##
library('tm')
source('script/CommLibrary.R')




fs$PC.Gross.Impressions <- fs$Gross.Impressions - fs$Non.PC.Impressions
fs$Mobile.Impressions <- fs$Non.PC.Impressions - fs$Mobile.App.Impressions
fs$Mobile.App.Measured.Impressions <- fs$Mobile.App.Impressions
fs$Mobile.App.Measured.Views <- fs$Measured.Views - fs$PC.Measured.Views - fs$Mobile.Measured.Views
fs$impressions <- fs$PC.Measured.Impressions + fs$Mobile.App.Measured.Impressions + fs$Mobile.Measured.Impressions
fs$views <- fs$PC.Measured.Views + fs$Mobile.App.Measured.Views + fs$Mobile.Measured.Views
fs$x <- fs$Month
month <-names(table(fs$Month))
nMonth <- length(month)
##"Human.Impressions"
##fs$bot <- fs$Spider...Bot.Impressions + fs$Invalid.Browser.Impressions + fs$Non.Human.Traffic.Impressions
##sum(fs$bot,na.rm=TRUE)/sum(fs$impressions,na.rm=TRUE)
##colSums(fs[,c("Spider...Bot.Impressions","Invalid.Browser.Impressions","Non.Human.Traffic.Impressions","PC.Measured.Impressions","Mobile.Measured.Impressions","PC.Measured.Views","Mobile.Measured.Views","bot")])


fs$Placement <- gsub("#N/A","",fs$Placement)
fs$site <- gsub("[~|][A-z]*","",fs$Placement)
## fs$Placement <- gsub("#N/A","",fs$Posizionamento)
## fs$site <- gsub("~[A-z]*","",fs$Posizionamento)
fs$site <- gsub("_[A-z]*","",fs$site)
fs$site <- gsub("TGCOM[A-z]*","TGCOM",fs$site)
fs$site <- gsub("PANORAMA[A-z]*","PANORAMA",fs$site)
fs$site <- gsub("METEO.IT[A-z]*","METEO.IT",fs$site)
fs$site <- gsub("IL GIORNALE[A-z]*","IL GIORNALE",fs$site)
fs$site <- gsub("SPORT MEDIASET[A-z]*","SPORT MEDIASET",fs$site)
fs$site <- gsub("UNA DONNA[A-z]*","UNA DONNA",fs$site)
fs$site <- gsub("[0-9]","",fs$site)
##fs$site <- tryTolower(fs$site)
#fs$Placement <- gsub("#N/A","",fs$Placement)

fs$taxonomy <- gsub("^(([^:]+)~)?(*)","",fs$Placement)
fs$taxonomy <- gsub("IL GIORNALE","",fs$taxonomy)
fs$taxonomy <- gsub("TGCOM","",fs$taxonomy)
fs$taxonomy <- gsub("METEO.IT","",fs$taxonomy)
fs$taxonomy <- gsub("SPORT MEDIASET","",fs$taxonomy)
fs$taxonomy <- gsub("UNA DONNA","",fs$taxonomy)
fs$taxonomy <- gsub("PANORAMA","",fs$taxonomy)
taxonomy <- strsplit(fs$taxonomy,split="_")
fs$editor <- unlist(lapply(taxonomy,function(x) x[1]))
fs$siteshort <- unlist(lapply(taxonomy,function(x) x[2]))
fs$section <- paste(unlist(lapply(taxonomy,function(x) x[3])),"|",fs$site,"|",fs$editor,sep="")
fs$subsection <- unlist(lapply(taxonomy,function(x) x[4]))
fs$format <- unlist(lapply(taxonomy,function(x) x[5]))
fs$position <- unlist(lapply(taxonomy,function(x) x[6]))

fs$adv <- clean.text(fs$Creative)

sWords <- as.character(read.csv("raw/advStop.csv",header=FALSE)[,1])
sWords <- c(sWords,as.character(read.csv("raw/advTime.csv",header=FALSE)[,1]))
sWords <- c(sWords,as.character(read.csv("raw/advFormat.csv",header=FALSE)[,1]))
sWords <- c(sWords,as.character(read.csv("raw/advProperty.csv",header=FALSE)[,1]))
sWords <- c(sWords,as.character(read.csv("raw/advType.csv",header=FALSE)[,1]))
sWords <- c(sWords,as.character(read.csv("raw/advContent.csv",header=FALSE)[,1]))
sWords <- c(sWords,as.character(read.csv("raw/advChannel.csv",header=FALSE)[,1]))
##sWords <- c(sWords,stopwords("italian"))
fs$adv  <- removeWords(as.character(fs$adv), sWords)
cWords <- table(unlist(strsplit(fs$adv,split=" ")))
cWords <- cWords[order(-cWords)]
comm_prob = 0.70
lim = quantile(cWords, probs=comm_prob)
##    lim = 1
good <- names(cWords[cWords>lim][-1])
##fs$adv <- as.vector(unlist(sapply(fs$adv,function (y) good[sapply(good,function(x) grepl(x,y))][1])))


##fs <- fs[,!(names(fs) %in% c("Delivery.Partner","Domain","Category.Grouping","Tier.1.Category","Tier.2.Category","External.Creative.ID","Human.Impressions","IFramed.Impressions","X.Viewed","X.PCViewed","X.MobileViewed","Engaged","Engaged.Rate","Blocks","Exceptions","CDIW.Impression","Pixel.Impressions","Filtered.Impressions","Spider...Bot.Impressions","Invalid.Browser.Impressions","Internal.Traffic","Non.Human.Traffic.Impressions","NHT.Category..Invalid.User.Characteristics","NHT.Category..Non.Human.Behavior","NHT.Category..Anomalous.Traffic.Trends","Network.Server.Domain.Impressions"))]


##c("Month","Campaign","External.Campaign.ID","Placement","External.Placement.ID","Delivery.Partner","Domain","Category.Grouping","Tier.1.Category","Tier.2.Category","Creative","External.Creative.ID","Gross.Impressions","Human.Impressions","IFramed.Impressions","X.Viewed","X.PCViewed","X.MobileViewed","Engaged","Engaged.Rate","Blocks","Measured.Views","Measured.Impressions","PC.Measured.Views","PC.Measured.Impressions","Mobile.Measured.Views","Mobile.Measured.Impressions","Exceptions","CDIW.Impressions","Pixel.Impressions","Non.PC.Impressions","Direct.View.Time.1.5s","Direct.View.Time.5.60s","Direct.View.Time....60s","Filtered.Impressions","Spider...Bot.Impressions","Invalid.Browser.Impressions","Internal.Traffic","Non.Human.Traffic.Impressions","NHT.Category..Invalid.User.Characteristics","NHT.Category..Non.Human.Behavior","NHT.Category..Anomalous.Traffic.Trends","Network.Server.Domain.Impressions","Mobile.App.Impressions")

