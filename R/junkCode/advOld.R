if(1==0){##binary matrix
    commIn <- data.frame(order = 1:length(comm_field))
    for(i in 1:length(inVar)){
        commIn$var <- rep(0,length(comm_field))
        colnames(commIn)[colnames(commIn)=='var'] <- inVar[i]
    }
    commOut <- data.frame(order = 1:length(comm_field))
    for(i in 1:length(outVar)){
        commOut$var <- rep(0,length(comm_field))
        colnames(commOut)[colnames(commOut)=='var'] <- outVar[i]
    }
    commIn <- commIn[,-1]
    commOut <- commOut[,-1]
    for(i in 1:length(comm_field)){
        for(j in 1:length(inVar)){if(any(inVar[j]==sWord[[i]])){commIn[i,inVar[j]] <- 1}}
        for(j in 1:length(outVar)){if(any(outVar[j]==sWord[[i]])){commOut[i,outVar[j]] <- 1}}
    }
    commIn <- as.matrix(commIn)
    commOut <- as.matrix(commOut)
    view = t(commIn) %*% (commOut)
    tLabel <- inVar
    view = t(view) %*% view
}
if(1==1){##word count
    assoc <- data.frame(var1 = as.character(advList[,varList[iN]]))
    assoc$var2 <- as.character(advList[,varList[oN]])
    aggr1 <- aggregate(var1 ~ var2,paste,collapse=" ",data=assoc)
    ##    head (aggr1)
    ## cast(assoc,commIn~commOut,count)
    view <- data.frame(segment = outVar)
    for(i in seq(1:length(inVar))){
        view[,inVar[1]] <- rep(0,length(outVar))
        ## view$var <- rep(0,length(outVar))
        ## colnames(view)[colnames(view)=='var'] <- inVar[i]
    }
##    i <- 6
    for(i in seq(1:length(outVar))){
        cTab <- table(strsplit(aggr1[i,"var1"],split=" "))
        jName <- names(cTab)
        for(j in 1:length(cTab)){view[i,names(view)==jName[j]] <- cTab[j]}
    }
    view <- view[,-1]
    ## view[view==FALSE] = 0.0
    ## view[view==TRUE] = 1.0
    ## view[is.na(view)] <- 0
    view <- as.matrix(view)
    view = t(view) %*% view
    ## tLabel <- outVar
    ## view = view*t(view)
    ## tLabel <- inVar
    ## colnames(view) <- tLabel
    ## rownames(view) <- tLabel
}

if(1==0){
    assoc <- data.frame(var1 = as.character(advList[,varList[iN]]))
    assoc$var2 <- as.character(advList[,varList[oN]])
    assoc$imps <- as.numeric(advList[,"Imps"])
    assoc$click <- as.numeric(advList[,"Click"])
    aggr1 <- aggregate(var1 ~ var2,count,data=assoc)
    o <- 4
    for(o in 1:length(aggr1$var2)){
        iList <- aggr1[o,2][[1]]
        iCount <- aggr1[o,2][[2]]
        iMatch <- match(colnames(view),iList)
        set <- !is.na(iMatch)
        oCol <- match(aggr1$var2[o],rownames(view))
        view[oCol,set] <- iCount
    }
}
if(1==1){
        for(i in 1:length(inVar)){
        fs <- advList[advList[,varList[iN]] == inVar[i],c(varList[oN],"Imps","Click")]
        for(o in 1:length(outVar)){
            set <- fs[,varList[oN]] == outVar[o]
            fs1 <- fs[set,c("Imps","Click")]
            imps <- sum(fs1$Imps,na.rm=TRUE)
            click <- sum(fs1$Click,na.rm=TRUE)
            view[o,i] <- imps
            viewCtr[o,i] <- if(imps>0){click/imps}else{0}
        }
    }
}




view = t(view) %*% view

## sWord <- strsplit(inVar,split=" ")
## tWord <- table(unlist(sWord))
## tWord <- tWord[order(-tWord)]
## head(tWord,n=100)
##write.csv(gp_df[order(-as.numeric(gp_df$cluster)),],"out/advWordCluster.csv")


advList$x <- advList[,varList[iN]]
perf <- ddply(advList[,c("x","Imps","Click")],.(x),summarise,click=sum(Click,na.rm=TRUE),imps=sum(Imps,na.rm=TRUE))
perf$ctr <- perf$click/perf$imps
