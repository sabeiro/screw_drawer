#!/usr/bin/env Rscript
#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
rm(list=ls())



fs <- read.csv('raw/placementTable1.csv')
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable2.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable3.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable4.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable5.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable6.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable7.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
fs <- read.csv('raw/placementTable8.csv')
fs <- rbind(ds,fs)
ds <- ddply(fs,.(Placement.ID),head,1)
nrow(ds)
ds <- ds[-nrow(ds),]
ds$Placement.Name <- as.character(ds$Placement.Name)

ds$editor <- unlist(lapply(strsplit(ds$Placement.Name,split="_"),'[[',1))
ds$site <- unlist(lapply(strsplit(ds$Placement.Name,split="_"),'[[',2))
ds$section <- unlist(lapply(strsplit(ds$Placement.Name,split="_"),'[[',3))
ds$channel <- unlist(lapply(strsplit(ds$Placement.Name,split="_"),'[[',4))
ds$format <- unlist(lapply(strsplit(ds$Placement.Name,split="_"),'[[',5))
trx <- ds$Placement.Name
drx <- NULL
for(i in trx){
    drx <- c(drx,tryCatch(unlist(lapply(strsplit(i,split="_"),'[[',6)),error=function(e) NA) )
}
ds$position <- drx
ds$Site.Name <- tryTolower(ds$Site.Name)
head(ds)

ds$position2 <- ds$position
ds$position2[as.numeric(ds$position2)>3] <- 3


write.csv(ds,'raw/placementTable.csv')

