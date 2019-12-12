corrMat <- function(view,fExt){
    corrField <- t(view) %*% (view)
    corrField = corrField[rowSums(corrField)!=0,colSums(corrField)!=0]
    ##corrField[corrField > 1] = 1
    ##m1dist = dist(corrField, method="fJaccard")
    m1dist = dist(corrField)
    clus1 = hclust(m1dist, method="ward")
    ## plot dendrogram
    svg("fig/Comm",fExt,"Dendrogram.svg")
    plot(clus1, cex=0.7)
    dev.off()

    corrField[is.na(corrField)] <- 0
    ## remove columns (docs) with zeroes
    ##corrField = corrField[rowSums(corrField)!=0,colSums(corrField)!=0]
    diag(corrField) = 0
    corrField = corrField + t(corrField)
    wc = rowSums(corrField)
    for(i in seq(1:length(colnames(corrField)))){
        corrField[i,i] = wc[[i]]
    }
    ## word counts
    ## get those words above the 3rd quantile
    lim = quantile(wc, probs=comm_prob)
    lim = 40
    ## get those words above the 3rd quantile
    good <- corrField
    ##good = corrField[wc > lim,wc > lim]
    adja_matrix <- good
    diag(adja_matrix) <- 0
    affi_matrix <- good
    ## Create a graph
    gp_graph = graph.adjacency(adja_matrix, weighted=TRUE,
                               ##    mode=c("directed", "undirected", "max","min", "upper", "lower", "plus"),
                               mode = "max",
                               add.rownames=TRUE)

    ## coordinates for visualization
    ##posi_matrix = layout.fruchterman.reingold(graph=gp_graph,list(weightsA = weights))
    ##posi_matrix = layout.drl(gp_graph, list(weightsA=E(gp_graph)$weight))
    posi_matrix = layout.spring(gp_graph, list(weightsA=E(gp_graph)$weight))
    posi_matrix = cbind(V(gp_graph)$name, posi_matrix)
    ## create a data frame
    gp_df = data.frame(posi_matrix, stringsAsFactors=FALSE)
    names(gp_df) = c("word", "x", "y")
    gp_df$x = as.numeric(gp_df$x)
    gp_df$y = as.numeric(gp_df$y)
    ## size effect
    se = diag(affi_matrix) / max(diag(affi_matrix))
    ## plot
    ##svg("fig/CommCorrProperties.svg",width=gWidth,height=gHeight)
    par(bg = "gray15")
    with(gp_df, plot(x, y, type="n", xaxt="n", yaxt="n", xlab="", ylab="", bty="n"))
    with(gp_df, text(x, y, labels=word, cex=log10(diag(affi_matrix)),
                     col=hsv(0.95, se, 1, alpha=se)))
    ## k-means with 7 clusters
    words_km = kmeans(cbind(as.numeric(posi_matrix[,2]), as.numeric(posi_matrix[,3])), k_cluster)
    ## add frequencies and clusters in a data frame
    w_size <- diag(affi_matrix)^(0.1)
    gp_df = transform(gp_df, freq=w_size, cluster=as.factor(words_km$cluster))
    row.names(gp_df) = 1:nrow(gp_df)
    ## graphic with ggplot
    gp_words = ggplot(gp_df, aes(x=x, y=y)) +
        geom_text(aes(size=freq, label=gp_df$word, alpha=.90, color=as.factor(cluster))) +
        labs(x="", y="") +
        scale_size_continuous(breaks = c(10,20,30,40,50,60,70,80,90), range = c(1,8)) +
        ##scale_colour_manual(values=brewer.pal(8, "PuBu")) +
        scale_colour_manual(values=skillPal) +
        scale_x_continuous(breaks=c(min(gp_df$x), max(gp_df$x)), labels=c("","")) +
        scale_y_continuous(breaks=c(min(gp_df$y), max(gp_df$y)), labels=c("","")) +
        theme(panel.grid.major=element_blank(),
              legend.position="none",
              ##panel.background=element_rect(fill="gray10", colour="gray10"),
              panel.background = element_rect(fill="transparent",colour=NA),
              panel.grid.minor=element_blank(),
              axis.ticks=element_blank(),
              title = element_text("Segment clustering"),
              plot.title = element_text(size=12))
    plot(gp_words)
    ##dev.off()
    ## save the image in pdf format
    ggsave(plot=gp_words, filename="fig/Comm",fExt,"Corr.svg", height=gHeight, width=gWidth)
}

comCloud <- function(tAd){
    comm_corpus <- Corpus(VectorSource(names(tAd)))
    tdm = TermDocumentMatrix(comm_corpus,
                             control = list(removePunctuation = TRUE,
                                            stopwords = comm_stopWords,
                                            removeNumbers = TRUE, tolower = TRUE))
    mTdm = as.matrix(tdm)
    print("----cloud");
    word_freqs = sort(rowSums(mTdm), decreasing=TRUE)
    ## get those words above the 3rd quantile
    lim = max(cloud_lim,quantile(word_freqs, probs=comm_prob))
    significant = mTdm[word_freqs>= lim,]
    ## remove columns (docs) with zeroes
    significant = significant[,colSums(significant)!=0]
    ##---------------WordCloud------------------
    dm = data.frame(word=names(word_freqs), freq=word_freqs)
    ## save the image in png format
    svg("fig/Comm",fExt,"Cloud.svg")
    wordcloud(dm$word, dm$freq, min.freq=cloud_lim,max.words=cloud_max,random.order=FALSE, colors=luftPal)
    dev.off()
}

