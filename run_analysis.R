# To run the script and fulfill the tasks we have used RStudio.
# First we are loading required libraries 
# If you have not then please install them using package.install('package name')
# I have tried results with different packages 
library(dplyr)
library(tidyr)
library(reshape2)
library(files)
# We will try to download the data from given URL 
# "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# From above URL we have downloaded the data and unzip it. 

# 1. get data-set from web
rawDataDir <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename <- "rawData.zip"
rawDataDFile <- paste(rawDataDir, "/", "rawData.zip", sep = "")
dataDir <- "./data"

# Downloading data and creating folder in case there is no such directory
# you can check the directory created in the current working environment:getwd()

if (!file.exists(rawDataDir)) {
  dir.create(rawDataDir)
  download.file(url = rawDataUrl, destfile = rawDataDFile)
}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = rawDataDFile, exdir = dataDir)
}


# 2. merge {train, test} data set
# Loading train and test data
# We would like to store them as below 
x_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
x_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))

y_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
y_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))

s_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))
s_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))



# We are merging the train and test data-set using the merge command 
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)


# 3. load feature & activity info
# feature info
feature <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/features.txt"))

# activity labels
a_labels <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
a_labels[,2] <- as.character(a_labels[,2])

# extract feature cols & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


# 4. Extracting data for the specific columns
x_data <- x_data[selectedCols]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = a_labels[,1], labels = a_labels[,2])
allData$Subject <- as.factor(allData$Subject)


# 5.generate tidy data set applying melt and dcast 
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

# saving the tidy set in current folder by name 'tidy_dataset.txt'
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)


# Thank you :)