Flare[c(1,2)]
Flare[name=="body"]
names(Flare[4])
Flare[4]$children

gender <- mapply("[",Flare,lapply(Flare,function(x) !x %in% "Gender"))


yapply <- function(X,FUN, ...) {
  index <- seq(length.out=length(X))
  namesX <- names(X)
  if(is.null(namesX))
    namesX <- rep(NA,length(X))

  FUN <- match.fun(FUN)
  fnames <- names(formals(FUN))
  if( ! "INDEX" %in% fnames ){
    formals(FUN) <- append( formals(FUN), alist(INDEX=) )
  }
  if( ! "NAMES" %in% fnames ){
    formals(FUN) <- append( formals(FUN), alist(NAMES=) )
  }
  mapply(FUN,X,INDEX=index, NAMES=namesX,MoreArgs=list(...))
}

listToXml <- function(item, tag) {
  # just a textnode, or empty node with attributes
  if(typeof(item) != 'list') {
    if (length(item) > 1) {
      xml <- xmlNode(tag)
      for (name in names(item)) {
        xmlAttrs(xml)[[name]] <- item[[name]]
      }
      return(xml)
    } else {
      return(xmlNode(tag, item))
    }
  }

  # create the node
  if (identical(names(item), c("text", ".attrs"))) {
    # special case a node with text and attributes
    xml <- xmlNode(tag, item[['text']])
  } else {
    # node with child nodes
    xml <- xmlNode(tag)
    for(i in 1:length(item)) {
      if (names(item)[i] != ".attrs") {
        xml <- append.xmlNode(xml, listToXml(item[[i]], names(item)[i]))
      }
    }
  }

  # add attributes to node
  attrs <- item[['.attrs']]
  for (name in names(attrs)) {
    xmlAttrs(xml)[[name]] <- attrs[[name]]
  }
  return(xml)
}



yapply(Flare,paste)

do.call(paste, list(toto, names(toto) ))

mydata2 <- mapply("[", mydata, lapply(mydata, function(x) !x %in% A))

which(sapply(Flare, FUN=function(X) "name" %in% X))


## # Create fake data
## src <- c("A", "A", "A", "A",
##         "B", "B", "C", "C", "D")
## target <- c("B", "C", "D", "J",
##             "E", "F", "G", "H", "I")
## networkData <- data.frame(src, target)
## simpleNetwork(networkData)
## # Load data
## data(MisLinks)
## data(MisNodes)
## forceNetwork(Links = MisLinks, Nodes = MisNodes,
##             Source = "source", Target = "target",
##             Value = "value", NodeID = "name",
##             Group = "group", opacity = 0.8)
## sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
##              Target = "target", Value = "value", NodeID = "name",
##              units = "TWh", fontSize = 12, nodeWidth = 30)
#as.dendrogram(fs)
