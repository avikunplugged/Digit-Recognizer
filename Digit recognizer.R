#Data Import
digitdata=read.csv("train.csv",header = TRUE)
digitdata

dim(digitdata)
summary(digitdata)
names(digitdata)
#train data divided in train and test data

#digit_tr train data
train=sample(nrow(digitdata),0.5*nrow(digitdata),replace=FALSE)
digit_tr=digitdata[train,]
str(digit_tr)
summary(digit_tr)
digit_tr$label=as.factor(digit_tr$label)

#digit_va  validation data
digit_va=digitdata[-train,]
digit_va$label=as.factor(digit_va$label)
summary(digit_va)
str(digit_va)

## install.packages("e1071")
library(e1071)


# SVM with Polynomial Kernel and digit_tr
digit_polFit <- svm(label ~ .,          
              data = digit_tr,      
              kernel = "polynomial", 
              gamma = 1,             
              coef0 = 1,             
              degree = 5,            
              cost = 10,             
              scale = FALSE)         

#predict with train validation set

predict_trva=predict(digit_polFit,digit_va)
table= table(predict_trva,truth=digit_va$label)
table
sum(diag(prop.table(table)))

#Import Test set
digitdata_test=read.csv("test.csv",header = TRUE)
digitdata_test

#prediction on test set
predict_testdata=predict(digit_polFit,digitdata_test)
predict_testdata
#Write prediction in sample_submission.csv in R
write.csv(predict_testdata, file = "sample_submission.csv")