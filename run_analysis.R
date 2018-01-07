## set working directory
setwd ("C:/Users/Edward/Documents/Analysis of Data/Cleaning Project")

## specifying location of download file
fileUrl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## download the file and specify destination location and file name
download.file(fileUrl,destfile="C:/Users/Edward/Documents/Analysis of Data/Cleaning Project/Dataset.zip")

## download file is zipped. Unzip and put in temporary directory
unzip(zipfile="./Dataset.zip",exdir="./tempfile")

## create tables for all relevant data from Text files
xtraining <- read.table("./tempfile/UCI HAR Dataset/train/X_train.txt")
ytraining <- read.table("./tempfile/UCI HAR Dataset/train/y_train.txt")
subjecttraining <- read.table("./tempfile/UCI HAR Dataset/train/subject_train.txt")
xtest <- read.table("./tempfile/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./tempfile/UCI HAR Dataset/test/y_test.txt")
subjecttest <- read.table("./tempfile/UCI HAR Dataset/test/subject_test.txt")
features <- read.table('./tempfile/UCI HAR Dataset/features.txt')
activityLabels = read.table('./tempfile/UCI HAR Dataset/activity_labels.txt')

## Name the columns in the tables just created
colnames(xtraining) <- features[,2] 
colnames(ytraining) <-"activityId"
colnames(subjecttraining) <- "subjectId"
colnames(xtest) <- features[,2] 
colnames(ytest) <- "activityId"
colnames(subjecttest) <- "subjectId"
colnames(activityLabels) <- c('activityId','activityType')

## Merge the training tables - Merge the Test tables
mergetrain <- cbind(ytraining, subjecttraining, xtraining)
mergetest <- cbind(ytest, subjecttest, xtest)

## Merge the merged test and merged training tables into one table
mergeall <- rbind(mergetrain, mergetest)
colNames <- colnames(mergeall)

## create a vector that identifies variables that contain mean and std deviation
## information as "TRUE" or "FALSE"
findmean_std <- (grepl("activityId" , colNames)| 
                         grepl("subjectId" , colNames) | 
                         grepl("mean.." , colNames) |
                         grepl("std.." , colNames) )

## creates a table with mean and std (deviation) variables
Mean_StdTbl <- mergeall[ , findmean_std == TRUE]

##add activity labels to merged data table
AddActivityNames <- merge(Mean_StdTbl, activityLabels,
                              by='activityId',
                              all.x=TRUE)

## Create a tidy dataset from the merged tables  
TidySetData <- aggregate(. ~activityId + subjectId, AddActivityNames, mean)

## modify the tidy dataset to have only mean data eliminating Std variables
TidySetData <- select(TidySetData,subjectId,activityId,activityType,contains("-mean()") )

## write the tidy dataset out as a text file for additional analysis
write.table(TidySetData, "TidySetData.txt", row.name=FALSE)
