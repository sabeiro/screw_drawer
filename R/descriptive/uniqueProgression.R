#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library(dplyr)
library(stats)

fs <- read.csv("raw/uniqueProgression.csv",stringsAsFactor=F)
fs$imps = as.numeric(fs$imps)
editL = ddply(fs,.(editore),summarise,imps=sum(imps))
fs = fs[fs$editore %in% editL[editL$imps > sum(fs$imps)/100,"editore"],]
exitC = NULL
exitN = NULL
for(i in unique(fs$editore)){
    set = fs$editore == i & fs$span < 40
    cs = fs[set,]
    cs$ratio_imps = cs$unique/cs$imps
    mod = tryCatch(nls(ratio_imps ~ a+c*exp(-b*span),data=cs[,],start=list(a=min(cs$ratio_imps),b=0.16,c=1.)),error=function(e) NULL)
    if(is.null(mod)){next}
    cs$fit = predict(mod,list(span=cs$span))
    cs$exit = (cs$ratio_imps - cs$fit)*cs$imps
    exitC <- cbind(exitC,cs$exit)
    exitN <- c(exitN,i %>% gsub("Aggregato ","",.))
}
colnames(exitC) <- exitN
exitC = as.data.frame(exitC)
##exitC = exitC %>% mutate_each(funs(./max(.)))
meanC = rowSums(exitC)/ncol(exitC)
exitC$span <- seq(1,nrow(exitC))
smooth = data.frame(span=seq(nrow(exitC)*10)/10)
smooth[,'mean'] = as.numeric(spline(meanC,n=length(meanC)*10)$y)
smooth <- melt(smooth,id="span")
smooth[,"value"] <- (smooth[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(.-min(.,na.rm=T))))[2]
smooth[,"value"] <- (smooth[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.,na.rm=T))))[2]

melted = melt(exitC,id="span")
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(.-min(.))))[2]
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.))))[2]

histS =2 smooth$value-min(smooth$value)
meanV = c(sum(histS*smooth$span)/sum(histS),smooth$span[findInterval(sum(histS)/2,cumsum(histS))])
head(fs)

gLabel = c("time span (days)","norm values",paste("mean",round(meanV[1],2),"median",round(meanV[2],2),"days"),"","")
p <- ggplot(melted,aes(x=span,color=variable,y=value)) +
    geom_violin(alpha=.5) +
    geom_jitter(height=0) +
    geom_boxplot(alpha=.5) + 
    geom_line(alpha=.5) + 
    geom_line(data=smooth,size=2) + 
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) +
    ## scale_y_log10() +
    ## scale_x_log10() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p
ggsave(file="intertino/fig/cookieLifetime.jpg", plot=p, width=gWidth, height=gHeight)

##---------------------------------------------------------------------------

fs <- read.csv("raw/uniqueProgression.csv",stringsAsFactor=F)
fs = fs[fs$editore=="mediaset",]
fs$imps = fs$imps/fs$span
fs$unique = fs$unique/fs$span
fs[fs==Inf] = NA
fs$ratio_imps = fs$unique/fs$imps
#fs$ratio_visit= fs$unique/fs$visit
## fs$ratio = fs$ratio - min(fs$ratio)
## mod <- nls(ratio_imps ~ a+c*exp(-b*span),data=fs[,],start=list(a=min(fs$ratio_imps),b=0.16,c=.33))
mod1 <- nls(unique ~ a/span,data=fs[,],start=list(a=1.8*max(fs$unique,na.rm=T)))
mod2 <- nls(unique ~ c*exp(-b*span),data=fs[,],start=list(b=1/87,c=max(fs$unique,na.rm=T)))
mod3 <- nls(unique ~ (a + c*exp(-b*span))/span,data=fs[,],start=list(a=coef(mod1)[1],b=coef(mod2)[1],c=coef(mod2)[2]))
fs$fit_ip = predict(mod1,list(span=fs$span))
fs$fit_exp = predict(mod2,list(span=fs$span))
fs$fit_poi = predict(mod3,list(span=fs$span))
fs[fs==Inf] = NA
fs$exit = -(fs$unique - fs$fit_poi)

## mod1 <- nls(unique ~ a+c*exp(-b*span),data=fs[0:20,],start=coef(mod1))
## fs$fit = predict(mod1,list(span=fs$span))
## fs$exit_20 = -(fs$unique - fs$fit)#*fs$imps
## mod1 <- nls(unique ~ a+c*exp(-b*span),data=fs[0:30,],start=coef(mod1))
## fs$fit = predict(mod1,list(span=fs$span))
## fs$exit_30 = -(fs$unique - fs$fit)#*fs$imps
## mod1 <- nls(unique ~ a+c*exp(-b*span),data=fs[0:40,],start=coef(mod1))
## fs$fit = predict(mod1,list(span=fs$span))
## fs$exit_40 = -(fs$unique - fs$fit)#*fs$imps
mod2 <- nls(imps ~ b*span,data=fs[,],start=list(b=fs[1,"imps"]))
fs$deriv = predict(mod1,list(span=fs$imps/coef(mod2)[1]))
fs$fit_lin = predict(mod2,list(span=fs$span))
fs$ratio_fit = fs$fit/fs$fit_lin
fs$ratio_fit[1] = NA
fs$transfer = Re(fft(fft(fs$fit)/fft(fs$fit_lin)))
fs$transfer[c(1,nrow(fs)-1,nrow(fs))] = NA

melted = melt(fs[,!colnames(fs) %in% c("editore","visit")],id="span")
set <- melted$variable %in% c("ratio","fit")
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(.-min(.,na.rm=T) )))[2]
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.,na.rm=T))))[2]

gLabel = c("time span","norm values",paste("cookie population time:",round(1/coef(mod1)[2],2),"days"),"","")
p <- ggplot(melted,aes(x=span,color=variable)) +
    geom_line(aes(y=value)) + 
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) +
    ## scale_y_log10() +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p
ggsave(file="intertino/fig/cookieLifetime1.jpg", plot=p, width=gWidth, height=gHeight)

fs1 <- read.csv("raw/uniqueProgressionDaily.csv",stringsAsFactor=F)
fs1$Days <- as.Date(fs1$Days)
fs1 <- fs1[fs1[,"Livello1...Editore"]=="mediaset",]
fs1 <- fs1[,colnames(fs1) %in% c("Days","Page.Impressions","Visits","Browsers")]
colnames(fs1) <- c("date","imps","visit","unique")
##sp <- spectrum(fs$imps,plot=F)
fs1$psf = Re(fft(fft(fs1$unique)/fft(fs1$imps)))
if(FALSE){
    ccf(fs1$imps,fs1$unique) 
    acf(fs1$imps) 
    acf(fs1$unique) 
    pacf(fs1$unique)
}

melted = melt(fs1,id="date")
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.))))[2]

gLabel = c("time span","norm values",paste("cookie decay time:",round(1/coef(mod)[2],2),"days"),"","")
p <- ggplot(melted,aes(x=date,color=variable)) +
    geom_line(aes(y=value)) + 
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p

##specx <- spec.pgram(fs$imps, plot = FALSE)

head(fs)
fs$date <- as.Date(as.Date(min(fs1$date)) + fs$span)
fs2 <- merge(fs[,c("date","imps")],fs1[,c("date","unique")],all=F,by="date")
fs2$psf = Re(fft(fft(fs2$unique)/fft(fs2$imps)))

melted = melt(fs2,id="date")
melted[,"value"] <- (melted[,c("variable","value")] %>% group_by(variable) %>% mutate_each(funs(./max(.))))[2]

gLabel = c("time span","norm values",paste("cookie decay time:",round(1/coef(mod)[2],2),"days"),"","")
p <- ggplot(melted,aes(x=date,color=variable)) +
    geom_line(aes(y=value)) + 
    scale_color_manual(values=gCol1) + 
    scale_fill_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4],fill=gLabel[5])
p




