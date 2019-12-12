#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
##fName <- paste("out/dotImprDevFormat",fSect,month,".csv",sep="")
print(fName)
siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])

viewTot <-  sum(siteGrp2[,grepl("view",colnames(siteGrp2))],na.rm=TRUE)/sum(siteGrp2[,grepl("imps",colnames(siteGrp2))],na.rm=TRUE)
set <- TRUE
if(fSect=="section"){set <- set & grepl(editor,siteGrp2[,fSect])}
if(isChiara){set <- set & (grepl("TGCOM",siteGrp2[,fSect]) | grepl("SPORT",siteGrp2[,fSect]) | grepl("METEO",siteGrp2[,fSect]))}
siteGrp3 <- siteGrp2[set,]
siteGrp3 <- siteGrp3[order(-siteGrp3$imps),]
tot <-  colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)
siteGrp3 <- siteGrp3[1:NSect,]
if(fSect=="section"){
    ## channelL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',1)
    ## siteL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',2)
    ## siteL <- gsub("MEDIASET","",siteL)
    ## siteGrp3[,fSect] <- paste(channelL,siteL,sep="_")
}
rest <- colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)

siteGrp <- data.frame(section = siteGrp3[,fSect])
siteGrp$section <- gsub("  "," ",siteGrp$section)
siteGrp$section <- gsub("DONNAMODERNA","DM",siteGrp$section)
vGrp <- as.matrix(siteGrp3[,grepl("view",colnames(siteGrp3))])
rownames(vGrp) <- siteGrp3[,fSect]
iGrp <- as.matrix(siteGrp3[,grepl("imps",colnames(siteGrp3))])
rownames(iGrp) <- siteGrp3[,fSect]
cGrp <- as.matrix(vGrp / iGrp)
colnames(cGrp) <- gsub("view","ctr",colnames(cGrp))
tot <- colSums(vGrp)/colSums(iGrp)
rest <- colSums(vGrp)/colSums(iGrp)# (colSums(vGrp) - colSums(vGrp[1:NSect,]))/(colSums(iGrp) - colSums(iGrp[1:NSect,]))
cGrp <- cGrp[order(-rowSums(iGrp)),]
rName <- rownames(cGrp)
cGrp <- rbind(cGrp,c(rest))
cGrp <- rbind(cGrp,c(tot))
cGrp[is.nan(cGrp)] <- 0
rownames(cGrp) <- c(rName,"rest","total")
melted <- melt(cGrp)
melted$Var1 <- as.ordered(melted$Var1)
melted$Var1 <- factor(melted$Var1,levels=melted$Var1 )
##melted$Var2 <- gsub("ctrs","",melted$Var2)
melted$Var2 <- gsub("ctr\\.","",melted$Var2)
melted$Var2 <- as.ordered(melted$Var2)
melted$Var2 <- factor(melted$Var2,levels=melted$Var2)
melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
melted <- na.omit(melted)
melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
dat <- melted
colnames(dat) <- c("y","x","value")
dat$x <- as.integer(factor(dat$x))
dat$y <- as.integer(factor(dat$y))
dat$value <- round(dat$value*100)
