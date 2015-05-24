# Package requirements
library(plyr)

################################
# Load Data 
################################
# Check if file doesn't exist, if it doesn't download.
if (!file.exists("projectdata.zip")) {
  download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "projectdata.zip", method = "curl")
}

# Check for unziped data, if it doesn't exist unzip.
if (!file.exists("UCI_HAR_Dataset")) {
  unzip("projectdata.zip", exdir = ".")
}

## Read adn load data to environment
subjectTrainData <- read.csv("UCI HAR Dataset/train/subject_train.txt", sep = "", header = FALSE)
subjectTestData <- read.csv("UCI HAR Dataset/test/subject_test.txt", sep = "", header = FALSE)

################################
# Merge Data Label and Choose 
################################
# From Subject
subjectData <- rbind(subjectTrainData, subjectTestData)
names(subjectData) <- c("subject")

# From Labels
activityLabels <- read.csv("UCI HAR Dataset/activity_labels.txt", header = FALSE, sep="")
names(activityLabels) <- c("activityKey", "activity")

# Get Y data
yTrain <- read.csv("UCI HAR Dataset/train/Y_train.txt", sep = "", header = FALSE)
yTest <- read.csv("UCI HAR Dataset/test/Y_test.txt", sep = "", header = FALSE)
yData <- rbind(yTrain, yTest)
names(yData) <- c("activityKey")
yData <- join(yData, activityLabels, by="activityKey")

## Get X data
features <- read.csv("UCI HAR Dataset/features.txt", header = FALSE, sep="\n")[,1]
xTrain <- read.csv("UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
xTest <- read.csv("UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
xData <- rbind(xTrain, xTest)
names(xData) <- features

## Means adn sd
meanOrStd <- grepl('mean()', features) | grepl('std()', features)
xData <- xData[,which(meanOrStd)]

## Merge to Data Object
data <- cbind(subjectData, yData, xData)

## Aggregate by subject and activity
tidyData <- aggregate(data[4:ncol(data)], list(ActivityName=data$activity, SubjectId=data$subject), FUN=mean)

## Tidy Dta Export
# write.table(tidyData, file="tidy_data.csv")  I kinda like lokking at this one but the following one is 
# the requered output
write.table(tidyData, file="tidy_data.txt", row.name=FALSE)