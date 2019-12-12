#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media')
source('src/R/graphEnv.R')
library(twitteR)
library(RSentiment)
library(wordcloud)
library(XML)
library("wordcloud")
pal2 <- brewer.pal(8,"Dark2")
## require('devtools')
## install_github('mananshah99/sentR')
require('sentR')
lapply(c('twitteR','lubridate','network','sna','qdap','tm','rjson'),library, character.only = TRUE)
set.seed(95616)

cred <- fromJSON(paste(readLines("credenza/twitter.json"),collapse=""))

download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
options(httr_oauth_cache=T) #This will enable the use of a local file to cache OAuth access credentials between R sessions.
setup_twitter_oauth(cred$consumer_key,cred$consumer_secret,cred$access_token,cred$access_secret)
##r_stats <- searchTwitter("#Rstats", n=1500, cainfo="cacert.pem")
startDate <- '2016-12-13'
r_stats <- NULL
r_stats <- rbind(r_stats,searchTwitter(" @TemptationITA ‏ ", n=1500,since = starDate))
r_stats <- rbind(r_stats,searchTwitter("#TemptationIsland", n=1500,since = startDate))

## saveRDS(r_stats, 'raw/Tweets.RDS')
## r_stats= readRDS('raw/Tweets.RDS')
twitD = twListToDF(r_stats)
twitD$text <- sapply(r_stats, function(x) x$getText())
twitD$text <- iconv(twitD$text, to = "ascii",sub="") 
twitD <- twitD[!is.na(twitD$text),]
twitD$text <- tryTolower(twitD$text)
twitD$text <- gsub('(http.*\\s*)[^[:blank:]]+', '',twitD$text)
##twitD$text <- gsub('(@|#)[^[:blank:]]+', '',twitD$text)
##gsub(" ?(f|ht)tp(s?)://(.*)[.][a-z]+", "", x)
twitD$text <- gsub("uominiedonne","",twitD$text)
twitD$text <- gsub("gf","",twitD$text)
twitD$text <- gsub("gfvip","",twitD$text)
twitD$text <- gsub("grandefratello","",twitD$text)
twitD$text <- gsub('(\\.|!|\\?)\\s+|(\\++)',' ',twitD$text) 
twitD$text <- gsub("[[:punct:]]","",twitD$text)
twitD$text <- gsub("[[:digit:]]","",twitD$text)
twitD$text <- gsub("\\n","",twitD$text)
write.csv(twitD,"raw/twitterTempt.csv")

stopwordsIt <- read.csv("out/train/stopwords_it.csv",header=F)$V1
twitD$text = removeWords(twitD$text, stopwordsIt)
sentIt <- read.csv("out/train/sentiment_it.csv")

# Zoom in on conference day
p = ggplot(twitD, aes(created)) + 
    geom_density(aes(fill = isRetweet), alpha = .5) +
    scale_fill_discrete(guide = 'none') +
    xlab('All tweets')
p
if(TRUE){##polarity
# Split into retweets and original tweets
sp = split(twitD, twitD$isRetweet)
orig = sp[['FALSE']]
# Extract the retweets and pull the original author's screenname
rt = mutate(sp[['TRUE']], sender = substr(text, 5, regexpr(':', text) - 1))

pol = polarity(orig$text,negators=c("no","non"),amplifiers=unique(sentIt$positive),deamplifiers=unique(sentIt$negative))

head(pol$all$neg.words,200)

out <- classify.aggregate(twitD$text, unique(sentIt$positive), unique(sentIt$negative))
out <- classify.naivebayes(twitD$text)
write.csv(out,"raw/twitterTemptation.csv")


orig$emotionalValence = sapply(pol, function(x) x$all$polarity)
# As reality check, what are the most and least positive tweets
orig$text[which.max(orig$emotionalValence)]
## [1] "Hey, this Open Science Framework sounds like a great way to  collaborate openly! Where do I sign up? Here: https://t.co/9oAClb0hCP #MSST2016"
orig$text[which.min(orig$emotionalValence)]
## [1] "1 Replications are boring 2 replications are attack 3 reputations will suffer 4 only easy ones will be done 5 bad studies are bad #MSST2016"
# How does emotionalValence change over the day?
ggplot(orig,aes(created, emotionalValence)) +
    geom_point() + 
    geom_smooth(span = .5)


ggplot(orig, aes(x = emotionalValence, y = retweetCount)) +
    geom_point(position = 'jitter') +
    geom_smooth()




polWordTables = 
    sapply(pol, function(p) {
        words = c(positiveWords = paste(p[[1]]$pos.words[[1]], collapse = ' '), 
                  negativeWords = paste(p[[1]]$neg.words[[1]], collapse = ' '))
        gsub('-', '', words)  # Get rid of nothing found's "-"
    }) %>%
    apply(1, paste, collapse = ' ') %>% 
    stripWhitespace() %>% 
    strsplit(' ') %>%
    sapply(table)

par(mfrow = c(1, 2))
invisible(
    lapply(1:2, function(i) {
    dotchart(sort(polWordTables[[i]]), cex = .8)
    mtext(names(polWordTables)[i])
    }))




polSplit = split(orig, sign(orig$emotionalValence))
polText = sapply(polSplit, function(df) {
    paste(tolower(df$text), collapse = ' ') %>%
        gsub(' (http|@)[^[:blank:]]+', '', .) %>%
        gsub('[[:punct:]]', '', .)
    }) %>%
    structure(names = c('negative', 'neutral', 'positive'))
head(polSplit)


# remove emotive words
polText['negative'] = removeWords(polText['negative'], names(polWordTables$negativeWords))
polText['positive'] = removeWords(polText['positive'], names(polWordTables$positiveWords))

# Make a corpus by valence and a wordcloud from it
corp = make_corpus(polText)
col3 = RColorBrewer::brewer.pal(3, 'Paired') # Define some pretty colors, mostly for later
wordcloud::comparison.cloud(as.matrix(TermDocumentMatrix(corp)), 
                            max.words = 100, min.freq = 2, random.order=FALSE, 
                            rot.per = 0, colors = col3, vfont = c("sans serif", "plain"))
}



if(TRUE){##wordcloud
text_corpus <- Corpus(VectorSource(twitD$text))
##text_corpus <- tm_map(text_corpus, removeWords, stopwordsIt)
text_corpus <- tm_map(text_corpus,stemDocument)
##twitD$text_corpus = tm_map(twitD$text_corpus, str_replace_all,"[^[:alnum:]]", " ")
dtm <- DocumentTermMatrix(text_corpus)
##Terms(dtm)
twitW = data.frame(words=colnames((dtm)),freq=colSums(as.matrix(dtm)))
lim = quantile(twitW$freq,0.70)
twitW <- twitW[twitW$freq > lim,]
wordcloud(twitW$words,twitW$freq,max.words=300,colors=brewer.pal(10,"Dark2"),scale=c(3,0.5),random.order=F)
}


class_emo = classify_emotion(twitD$text, algorithm="bayes", prior=1.0)
emotion = class_emo[,7]
emotion[is.na(emotion)] = "unknown"

# classify polarity
class_pol = classify_polarity(twitD, algorithm="bayes")
# get polarity best fit
polarity = class_pol[,4]
# data frame with results
sent_df = data.frame(text=twitD, emotion=emotion,polarity=polarity, stringsAsFactors=FALSE)
# sort data frame
sent_df = within(sent_df, emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))


# plot distribution of emotions
ggplot(sent_df, aes(x=emotion)) +
geom_bar(aes(y=..count.., fill=emotion)) +
scale_fill_brewer(palette="Dark2") +
labs(x="emotion categories", y="number of tweets") +
opts(title = "Sentiment Analysis of Tweets about Starbucks\n(classification by emotion)",
     plot.title = theme_text(size=12))

# plot distribution of polarity
ggplot(sent_df, aes(x=polarity)) +
geom_bar(aes(y=..count.., fill=polarity)) +
scale_fill_brewer(palette="RdGy") +
labs(x="polarity categories", y="number of tweets") +
opts(title = "Sentiment Analysis of Tweets about Starbucks\n(classification by polarity)",
     plot.title = theme_text(size=12))

# separating text by emotion
emos = levels(factor(sent_df$emotion))
nemo = length(emos)
emo.docs = rep("", nemo)
for (i in 1:nemo){
   tmp = some_txt[emotion == emos[i]]
   emo.docs[i] = paste(tmp, collapse=" ")
}

# remove stopwords
emo.docs = removeWords(emo.docs, stopwords("english"))
# create corpus
corpus = Corpus(VectorSource(emo.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emos

# comparison word cloud
comparison.cloud(tdm, colors = brewer.pal(nemo, "Dark2"),
   scale = c(3,.5), random.order = FALSE, title.size = 1.5)















twitD_corpus <- tm_map(twitD$text_corpus, function(x)removeWords(x,stopwords("italian")))
inspect(twitD$text_corpus)
wordcloud(twitD_corpus,min.freq=2,max.words=100, random.order=T, colors=pal2)




lucaspuente <- getUser("lucaspuente")
location(lucaspuente)
lucaspuente_follower_IDs<-lucaspuente$getFollowers(retryOnRateLimit=180)




user <- getUser("sabeiro_")
location(user)




library(RWeka)
data(crude)
BigramTokenizer <- function(x) {RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 2, max = 2))}










library(RTextTools);

data <- read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/breast-cancer-wisconsin.data",header=FALSE)
data <- data[-1]
thick <- as.vector(apply(as.matrix(data[1], mode="character"),1,paste,"clump",sep="",collapse=""))
size <- as.vector(apply(as.matrix(data[2], mode="character"),1,paste,"size",sep="",collapse=""))
shape <- as.vector(apply(as.matrix(data[3], mode="character"),1,paste,"shape",sep="",collapse=""))
adhesion <- as.vector(apply(as.matrix(data[4], mode="character"),1,paste,"adhesion",sep="",collapse=""))
single <- as.vector(apply(as.matrix(data[5], mode="character"),1,paste,"single",sep="",collapse=""))
nuclei <- as.vector(apply(as.matrix(data[6], mode="character"),1,paste,"nuclei",sep="",collapse=""))
chromatin <- as.vector(apply(as.matrix(data[7], mode="character"),1,paste,"chromatin",sep="",collapse=""))
nucleoli <- as.vector(apply(as.matrix(data[8], mode="character"),1,paste,"nucleoli",sep="",collapse=""))
mitoses <- as.vector(apply(as.matrix(data[9], mode="character"),1,paste,"mitoses",sep="",collapse=""))
training_data <- cbind(data[10],thick,size,shape,adhesion,single,nuclei,chromatin,nucleoli,mitoses)
training_data <- training_data[sample(1:699,size=600,replace=FALSE),]
training_codes <- training_data[1]
training_data <- training_data[-1]
matrix <- create_matrix(training_data, language="english", removeNumbers=FALSE, stemWords=FALSE, removePunctuation=FALSE, weighting=weightTfIdf)

str(models)
head(training_data)
container <- create_container(matrix,t(training_codes),trainSize=1:200, testSize=201:600,virgin=FALSE)
models <- train_models(container, algorithms=c("MAXENT","SVM","GLMNET","SLDA","TREE","BAGGING","BOOSTING","RF"))
results <- classify_models(container, models)
analytics <- create_analytics(container, results)
analytics@ensemble_summary
