library(dplyr)
filename <- "Coursera_DS3_Final.zip"
# CHecking if file of that name exists
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method = "curl")
}  
# Checking if folder exists
if (!file.exists("UCI HAR Dataset")){
  unzip(filename)
}
# Creating and assigning all relevant dataframes
features <- read.table("UCI HAR Dataset/features.txt",col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

# 1. Merging the training and test sets to create one data set
X <- rbind(x_train, x_test)
Y<- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_data <- cbind(Subject, X, Y)

# 2. Extracting the measurement on the mean and standard deviations for each measurement
Required_data <- Merged_data %>% select(subject, code, contains("mean"), contains("std"))

# 3. Using descriptive activity names to name the activities in the data set
Required_data$code <- activities[Required_data$code, 2]

# 4. Appropriately labeling the data set with descriptive variable names
names(Required_data)[2] = "activity"
names(Required_data)<-gsub("Acc", "Accelerometer", names(Required_data))
names(Required_data)<-gsub("Gyro", "Gyroscope", names(Required_data))
names(Required_data)<-gsub("BodyBody", "Body", names(Required_data))
names(Required_data)<-gsub("Mag", "Magnitude", names(Required_data))
names(Required_data)<-gsub("^t", "Time", names(Required_data))
names(Required_data)<-gsub("^f", "Frequency", names(Required_data))
names(Required_data)<-gsub("tBody", "TimeBody", names(Required_data))
names(Required_data)<-gsub("-mean()", "Mean", names(Required_data), ignore.case = TRUE)
names(Required_data)<-gsub("-std()", "STD", names(Required_data), ignore.case = TRUE)
names(Required_data)<-gsub("-freq()", "Frequency", names(Required_data), ignore.case = TRUE)
names(Required_data)<-gsub("angle", "Angle", names(Required_data))
names(Required_data)<-gsub("gravity", "Gravity", names(Required_data))

# 5. From the data set created above, creating a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
TidyData <- Required_data %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(TidyData, "TidyData.txt", row.names = F)