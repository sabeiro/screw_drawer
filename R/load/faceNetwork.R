

token = "AAACEdEose0c..." # paste you
res = extract.FBNet(token)

                                        # Collect favorite musicians for each friends from info
all.music = lapply(res$info, function(x) x$music)
length(unique(unlist(all.music))) # 811 different values
sum(table(unlist(all.music))==1) # 83 musicians are only cited once
                                        # Let's see which musicians are the most popular
music.freq = sort(table(unlist(all.music)), decreasing=T)
best.music.freq = names(music.freq)[music.freq&gt;4]
best.music = substr((unlist(all.music))[unlist(all.music)%in%best.music.freq],1,15) # to shorten the names
num = as.numeric(as.factor(best.music))
best.music = data.frame("music"=best.music,"id"=factor(num))
qplot(id, data=best.music, geom="bar", fill=music)+labs(title="My friends' favorite music", xlab="")

V(res$network)$name[unlist(lapply(all.music,function(x) length(grep("Cure", x)) != 0))]

                                        # Number of favorite musicians for each friend
music.addict = unlist(lapply(all.music, function(x) length(x)))
summary(music.addict)
                                        #    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
                                        #   0.000   0.000   2.000   7.211   6.500  84.000

                                        # Who is having the largest number of favorite musicians in her/his profile?
head(sort(music.addict,decreasing=T))
                                        # [1] 84 81 79 71 55 45
V(res$network)[music.addict%in%c(84,81,79,71,55,45)]
                                        # Vertex sequence:
                                        # [1] "Matthieu V"  "fabien P"     "Clement D" "Paul C"
                                        # [5] "Abou E"        "Alexia A"

summary(book.addict)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
                                        #  0.0000  0.0000  0.0000  0.7415  0.0000 22.0000
summary(res$network)
# IGRAPH UN-- 147 547 --
                                        # attr: id (v/c), name (v/c), initials (v/c)
graph.density(res$network) # Number of connections between friends divided by the number of possible connections
# [1] 0.05097381
transitivity(res$network) # Probability that two friends who share a common relationship, except me, are also friends
                                        # [1] 0.5661737

# connected component analysis
connected.comp = clusters(res$network)
connected.comp$csize
# [1] 102   3   3  13   1   2   1   1   1   2   1   1   2   1   1   1   2   2   2
# [20]   1   1   1   1   1
# The largest connected component contains 102 friends.

# Throwing away unconnected people (goodbye my dear sis'...)
lcc = induced.subgraph(res$network, connected.comp$membership==1)
lcc
# IGRAPH UN-- 102 523 --
                                        # + attr: id (v/c), name (v/c), initials (v/c)
the.layout = layout.fruchterman.reingold(res$network)
the.colors = brewer.pal(9,"YlOrRd")
v.col = the.colors[1+cut(music.addict,c(-0.1,2,quantile(music.addict,probs=seq(0.6,1,length=7))),labels=F)][match(V(lcc)$name, V(res$network)$name)]
par(mar=c(0,0,0,0))
plot(lcc, layout=the.layout[match(V(lcc)$name, V(res$network)$name),], vertex.size=5, vertex.color=v.col, vertex.frame.color=v.col, vertex.label=V(lcc)$initials, vertex.label.cex=0.7, vertex.label.font=2, vertex.label.color="black")




facebook =  function( path = "me", access_token = token, options) {
    if( !missing(options) ){
        options = sprintf( "?%s", paste( names(options), "=", unlist(options), collapse = "&amp;", sep = "" ) )
    } else {
        options = ""
    }
    data = getURL( sprintf( "https://graph.facebook.com/%s%s&amp;access_token=%s", path, options, access_token ) )
    fromJSON( data )
}

extract.FBNet = function(token) {
                                        # outputs: igraph network ("network") and information on friends ("info" which is a list)

                                        # first, gather friends' list
    friends = facebook(path="me/friends", access_token=token)

                                        # basic friends' description
    friends.id = sapply(friends$data, function(x) x$id)
                                        # extract names
    friends.name = sapply(friends$data, function(x) iconv(x$name,"UTF-8","ASCII//TRANSLIT"))
                                        # short names to initials
    initials = function(x) {paste(substr(x,1,1), collapse="")}
    friends.initial = sapply(strsplit(friends.name," "), initials)
                                        # final data frame
    friends = data.frame("id"=friends.id, "name"=friends.name, "initial"=friends.initial, stringsAsFactors = FALSE)

                                        # Information on friends
    friends.info = list()
    for (ind in 1:length(friends.id)) {
        print(paste("information for friend number",ind,"..."))
        friends.info[[ind]] = list()
        friends.info[[ind]]$id = friends$id[ind]
        friends.info[[ind]]$name = friends$name[ind]
        tmp = facebook(path=paste(friends$id[ind],"/likes",sep=""))
        friends.info[[ind]]$likes = unique(unlist(lapply(tmp$data, function(x) x$name)))
        tmp = facebook(path=paste(friends$id[ind],"/books",sep=""))
        friends.info[[ind]]$books = unique(unlist(lapply(tmp$data, function(x) x$name)))
        tmp = facebook(path=paste(friends$id[ind],"/music",sep=""))
        friends.info[[ind]]$music = unique(unlist(lapply(tmp$data, function(x) x$name)))
        tmp = facebook(path=paste(friends$id[ind],"/movies",sep=""))
        friends.info[[ind]]$movies = unique(unlist(lapply(tmp$data, function(x) x$name)))
    }

                                        # friendship relation matrix
    N = length(friends.id)
    friendship.matrix = matrix(0,N,N)
    for (i in 1:N) {
                                        # For each friend, find the mutual friends to add edges to the graph
        tmp = facebook(path=paste("me/mutualfriends", friends.id[i], sep="/") , access_token=token)
        mutualfriends = sapply(tmp$data, function(x) x$id)
        friendship.matrix[i,friends.id %in% mutualfriends] = 1
    }
    colnames(friendship.matrix) = friends.id
    rownames(friendship.matrix) = friends.name

    mygraph = graph.adjacency(friendship.matrix,mode="undirected",add.colnames="id",add.rownames="name")
    V(mygraph)$initials = friends$initial

    list("network"=mygraph, "info"=friends.info)
}
