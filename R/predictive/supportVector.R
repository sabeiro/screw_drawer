setwd('/home/sabeiro/lav/media/')
source('src/R/graphEnv.R')
library('tm')
library('SnowballC')

sms_data<-read.csv("train/sms_spam.csv",stringsAsFactors = FALSE,sep="\t")
str(sms_data)
sms_data$text = tryTolower(sms_data$text)
sms_data$text = sms_data$text %>% gsub("[[:punct:]]"," ",.) %>% gsub("[[:digit:]]"," ",.)
prop.table(table(sms_data$type))
simply_text<- Corpus(VectorSource(sms_data$text))
cleaned_corpus<-tm_map(simply_text, content_transformer(tolower))
cleaned_corpus<-tm_map(cleaned_corpus,removeWords,stopwords())
sms_dtm<-DocumentTermMatrix(cleaned_corpus)
n1 = floor((nrow(sms_data)*.8))
nT = nrow(sms_data)
sms_train<-cleaned_corpus[1:n1]
sms_test<-cleaned_corpus[n1:nT]

freq_term=(findFreqTerms(sms_dtm,lowfreq=10,highfreq=Inf))

sms_freq_train<-DocumentTermMatrix(sms_train,list(dictionary=freq_term))
sms_freq_test<-DocumentTermMatrix(sms_test,list(dictionary=freq_term))

print(NCOL(sms_freq_train))
print(NCOL(sms_freq_test))

y_train<-factor(sms_data$type[1:n1])
y_test<-factor(sms_data$type[n1:nT])
prop.table(table(y_train))
print(NCOL(sms_freq_train))
print(NCOL(sms_freq_test))

y<-((sms_data$type))
wts<-1/table(y)
print(wts)
library(e1071)
sms_freq_matrx<-as.matrix(sms_freq_train)
sms_freq_dtm<-as.data.frame(sms_freq_matrx)
sms_freq_matrx_test<-as.matrix(sms_freq_test)
sms_freq_dtm_test<-as.data.frame(sms_freq_matrx_test)
trained_model<-svm(sms_freq_dtm, y_train, type="C-classification", kernel="linear", class.weights = wts)

y_predict<-predict(trained_model, sms_freq_dtm_test)
library(gmodels)
CrossTable(y_predict,y_test,prop.chisq = FALSE)

trained_model2<-svm(sms_freq_dtm, y_train, type="C-classification", kernel="linear")
y_predict<-predict(trained_model2, sms_freq_dtm_test)
library(gmodels)
CrossTable(y_predict,y_test,prop.chisq = FALSE)
table(y_predict,y_test)

wts<-100/table(y)
print(wts)
wts<-10/table(y)
print(wts)


