comm_prob = 0.96
cloud_lim = 2
cloud_max = 500
luftPal = c("#EE9900","#FFCC00","#AAAAAA","#999999","#5A5a5a","#007ACC","#003399","#000099");



clean.text = function(x){
    ## tolower
    x = tryTolower(x)
    ## remove rt
    ##x = gsub("rt", "", x)
    ## remove retweet entities
    ##x = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", x)
    ## remove at
    ##x = gsub("@\\w+", "", x)
    ## remove punctuation
    x = gsub("[[:punct:]]", " ", x)
    ## remove numbers
    x = gsub("[[:digit:]]", " ", x)
    ## remove single char
    x = gsub(" [a-z] ", " ", x)
    ## remove links http
    ##x = gsub("http\\w+", "", x)
    ## remove cleontrol characters
    ##x = gsub("[[:cntrl:]]", "", x)
    ## remove digits?
    ##x = gsub('\\d+', '', x)
    ## remove tabs
    ##x = gsub("[ |\t]{2,}", "", x)
    ## remove blank spaces at the beginning
    ##x = gsub("^ ", "", x)
    ## remove blank spaces at the end
    ##x = gsub(" $", "", x)
    ## remove unnecessary spaces
    x = gsub("^\\s+|\\s+$", "", x)
    ## remove at people
    ##x = gsub("@\\w+", "", x)
    return(x)
}
clean.s = function(x){
                                        # remove final s
    x = gsub("([[:alpha:]])(s)([[:space:]])", "\\1\\3", x)
    x = gsub("ies","y",x)
    return(x)
}
join.words = function(x){
    x = gsub("prices","price",x)
}
stopw_en = c("times","t","didnt","ive","i","doesnt","that","this","now","says", "get", "anything", "working", "will", "even", "able", "just", "also", "want", "can", "site", "able", "need", "dont", "let", "just", "please", "work", "use", "tried", "much", "done", "online", "know", "anything", "try", "one", "time", "wont", "several", "make", "way", "another", "etc", "take", "put", "never", "either", "fly", "last", "internet", "better", "top", "booking", "flight", "flights","lufthansa","cant","don","doesn","page","website","web","able","get","just","help","ever","well","possible","nothing","therefore","still","without","already","per","absolut","sorry",stopwords("english"))
stopw_de = c("wurde","wäre","mal","freudlichen","funktioniert","frage","gestern","damen","herren","dass","obwohl","bitte","immer","einfach","warum","danke","kommt","schade","ganz","allerdings","erst","kommen","echt","leider","bleibt","oft","angeblich","gibt","schon","seit","möglich","flüge","mehr","Jetzt"," will"," wollte"," versuche"," versucht","brauche"," bekommt"," bekomme"," werde"," wird"," sogar"," überhaupt"," kann"," seite"," site"," nicht"," kann"," konnte"," geht"," ging"," viel"," online"," mehrere"," andere"," nie"," ich"," wir"," besser"," flug"," flüge",stopwords("german"))
                                        # define error handling function when trying tolower
tryTolower = function(x){
                                        # create missing value
    y = NA
                                        # tryCatch error
    try_error = tryCatch(tolower(x), error=function(e) e)
    if (!inherits(try_error, "error"))
        y = tolower(x)
    return(y)
}
toString <-  content_transformer(function(x, from, to) gsub(from, to, x))
                                        # use tryTolower with sapply
                                        #sentence = sapply(sentence, tryTolower)
                                        #      word.list = str_split(sentence, "\\s+")
                                        #      words = unlist(word.list)

                                        # This is a text processing function, which I
                                        # borrowed from a CMU Data mining course professor.
strip.text <- function(txt) {
                                        # remove apostrophes (so "don't" -> "dont", "Jane's" -> "Janes", etc.)
                                        #  txt <- gsub("'","",txt)
                                        # convert to lowercase
                                        #  txt <- tolower(txt)
                                        # change other non-alphanumeric characters to spaces
                                        #  txt <- gsub("[^a-z0-9]"," ",txt)
                                        # change digits to #
                                        #  txt <- gsub("[0-9]+"," ",txt)
                                        # split and make one vector
    txt <- unlist(strsplit(txt," "))
                                        # remove empty words
    txt <- txt[txt != ""]
    return(txt)
}

                                        # Words within 1 transposition.
Transpositions <- function(word = FALSE) {
    N <- nchar(word)
    if (N > 2) {
        out <- rep(word, N - 1)
        word <- unlist(strsplit(word, NULL))
                                        # Permutations of the letters
        perms <- matrix(c(1:(N - 1), 2:N), ncol = 2)
        reversed <- perms[, 2:1]
        trans.words <- matrix(rep(word, N - 1), byrow = TRUE, nrow = N - 1)
        for(i in 1:(N - 1)) {
            trans.words[i, perms[i, ]] <- trans.words[i, reversed[i, ]]
            out[i] <- paste(trans.words[i, ], collapse = "")
        }
    }
    else if (N == 2) {
        out <- paste(word[2:1], collapse = "")
    }
    else {
        out <- paste(word, collapse = "")
    }
    return(out)
}

                                        # Single letter deletions.
                                        # Thanks to luiscarlosmr for partial correction in comments
Deletes <- function(word = FALSE) {
    N <- nchar(word)
    out<-mat.or.vec(1,N)
    word <- unlist(strsplit(word, NULL))
    for(i in 1:N) {
        out[i] <- paste(word[-i], collapse = "")
    }
    return(out)
}

                                        # Single-letter insertions.
Insertions <- function(word = FALSE) {
    N <- nchar(word)
    out <- list()
    for (letter in letters) {
        out[[letter]] <- rep(word, N + 1)
        for (i in 1:(N + 1)) {
            out[[letter]][i] <- paste(substr(word, i - N, i - 1), letter,
                                      substr(word, i, N), sep = "")
        }
    }
    out <- unlist(out)
    return(out)
}

                                        # Single-letter replacements.
Replaces <- function(word = FALSE) {
    N <- nchar(word)
    out <- list()
    for (letter in letters) {
        out[[letter]] <- rep(word, N)
        for (i in 1:N) {
            out[[letter]][i] <- paste(substr(word, i - N, i - 1), letter,
                                      substr(word, i + 1, N + 1), sep = "")
        }
    }
    out <- unlist(out)
    return(out)
}
                                        # All Neighbors with distance "1"
Neighbors <- function(word) {
    neighbors <- c(word, Replaces(word), Deletes(word),
                   Insertions(word), Transpositions(word))
    return(neighbors)
}

                                        # Probability as determined by our corpus.
Probability <- function(word, dtm) {
                                        # Number of words, total
    N <- length(dtm)
    word.number <- which(names(dtm) == word)
    count <- dtm[word.number]
    pval <- count/N
    return(pval)
}

                                        # Correct a single word.
Correct <- function(word, dtm) {
    neighbors <- Neighbors(word)
                                        # If it is a word, just return it.
    if (word %in% names(dtm)) {
        out <- word
    }
                                        # Otherwise, check for neighbors.
    else {
                                        # Which of the neighbors are known words?
        known <- which(neighbors %in% names(dtm))
        N.known <- length(known)
                                        # If there are no known neighbors, including the word,
                                        # look farther away.
        if (N.known == 0) {
            print(paste("Having a hard time matching '", word, "'...", sep = ""))
            neighbors <- unlist(lapply(neighbors, Neighbors))
        }
                                        # Then out non-words.
        neighbors <- neighbors[which(neighbors %in% names(dtm))]
        N <- length(neighbors)
                                        # If we found some neighbors, find the one with the highest
                                        # p-value.
        if (N >= 1) {
            P <- 0*(1:N)
            for (i in 1:N) {
                P[i] <- Probability(neighbors[i], dtm)
            }
            out <- neighbors[which.max(P)]
        }
                                        # If no neighbors still, return the word.
        else {
            out <- word
        }
    }
    return(out)
}

                                        # Correct an entire document.
CorrectDocument <- function(document, dtm) {
    by.word <- unlist(strsplit(document, " "))
    N <- length(by.word)
    for (i in 1:N) {
        by.word[i] <- Correct(by.word[i], dtm = dtm)
    }
    corrected <- paste(by.word, collapse = " ")
    return(corrected)
}
