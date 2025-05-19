

if (!require("dplyr")) install.packages("dplyr")
library(dplyr)


fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("dataset.zip")) {
  download.file(fileUrl, destfile = "dataset.zip", method = "curl")
}
if (!file.exists("UCI HAR Dataset")) {
  unzip("dataset.zip")
}


features <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")


xTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")

xTest <- read.table("UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")


xData <- rbind(xTrain, xTest)
yData <- rbind(yTrain, yTest)
subjectData <- rbind(subjectTrain, subjectTest)


colnames(xData) <- features[, 2]
colnames(yData) <- "Activity"
colnames(subjectData) <- "Subject"


meanStdCols <- grepl("mean\\(\\)|std\\(\\)", features[, 2])
xData <- xData[, meanStdCols]


selectedData <- cbind(subjectData, yData, xData)


selectedData$Activity <- factor(selectedData$Activity,
                                levels = activityLabels[, 1],
                                labels = activityLabels[, 2])

names(selectedData) <- gsub("^t", "Time", names(selectedData))
names(selectedData) <- gsub("^f", "Frequency", names(selectedData))
names(selectedData) <- gsub("Acc", "Accelerometer", names(selectedData))
names(selectedData) <- gsub("Gyro", "Gyroscope", names(selectedData))
names(selectedData) <- gsub("Mag", "Magnitude", names(selectedData))
names(selectedData) <- gsub("BodyBody", "Body", names(selectedData))


tidyData <- selectedData %>%
  group_by(Subject, Activity) %>%
  summarise_all(mean)


write.table(tidyData, "tidy_dataset.txt", row.name = FALSE)
