## timeRef <- data.frame(day=as.Date(1:365,format="%Y-%m-%d",origin="2016-01-01"))
## timeRef$week <- format(timeRef$day,"%W")
## monday <-ddply(timeRef,.(week),summarise,monday=head(day,1))[-1,]
## monday$saturday <- as.Date(monday$monday)+5
## set <- match(timeRef$day,monday$monday)
## set <- set | match(timeRef$day,monday$monday+1)
## set <- set | match(timeRef$day,monday$monday+2)
## set <- set | match(timeRef$day,monday$monday+3)
## set <- set | match(timeRef$day,monday$monday+4)
## set[is.na(set)] <- FALSE
## timeRef$working <- set
## fs <- read.csv(paste("raw/priceSection",month,".csv",sep=""),stringsAsFactor=FALSE)
## fs$Data <- as.Date(fs$Data)
## fs <- merge(fs,timeRef,by.x="Data",by.y="day",all.x=TRUE)
## unique(fs$DeviceType)
## head(fs)

formL <- c("SKYSCRAPER","Mobile Splash Page")

##formL <- c("RECTANGLE","STRIP SKIN MASTHEAD","OVERLAYER","PROMOBOX","Mobile Splash Page","SPOT","APP ANDROID BANNER","APP ANDROID OVERLAYER","APP IPAD BANNER","APP IPAD OVERLAYER","APP IPHONE BANNER","APP IPHONE OVERLAYER","APP TABLET ANDROID BANNER","APP TABLET ANDROID OVERLAYER","LEADERBOARD","APP ANDROID VIDEO","APP IPAD Video","APP IPHONE VIDEO","APP TABLET ANDROID VIDEO","APP IPAD inpage","SKYSCRAPER","APP ANDROID Background","APP IPHONE Background")

## chL <- ddply(fs,"Channel",summarise,imps=sum(Imps,na.rm=TRUE))
##chL <- chL[chL$imps>500,]

cs <- fs

cs$DeviceType[grepl("Tablet",cs$DeviceType)] <- "Mobile Device"
cs$DeviceType[grepl("Car Entertainment System",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("Console",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("Ebook",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("TV Device",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("Unknown",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("FonePad",cs$DeviceType)] <- "Rest"
cs$DeviceType[grepl("Mobile",cs$DeviceType)] <- "Mobile"

table(cs$Size)
cs$Size[grepl("APP",cs$Size)] <- "APP"
cs$Size[grepl("OVERLAYER",cs$Size)] <- "Rest"
cs$Size[grepl("LEADERBOARD",cs$Size)] <- "Rest"
cs$Size[grepl("Mobile",cs$Size)] <- "Rest"
cs$Size[grepl("PROMOBOX",cs$Size)] <- "Rest"
cs$Size[grepl("SKYSCRAPER",cs$Size)] <- "Rest"
cs$Size[grepl("RTG",cs$Size)] <- "Rest"
cs$Size[grepl("TRACKER",cs$Size)] <- "Rest"
cs$Size[grepl("SKIN FASTWEB",cs$Size)] <- "Rest"

cs[cs$Size=="RECTANGLE","Size"] <- paste("RECTANGLE",cs[cs$Size=="RECTANGLE","DeviceType"],sep="-")
cs[cs$Size=="STRIP SKIN MASTHEAD","Size"] <- paste("STRIP SKIN MASTHEAD",cs[cs$Size=="STRIP SKIN MASTHEAD","DeviceType"],sep="-")
##table(cs$Size)
