setwd("L:/Dateien/Data_Science/03_Getting_And_Cleaning_Data/Ass")
require(data.table)
library(reshape2)
# Create directory data in the working directory
if (!file.exists("data")) {
        message("Creating data directory")
        dir.create("data")
}

# Check if data is already downloaded
if (!file.exists("data/UCI HAR Dataset")) {
        # If not, download & unzip the data into the data folder
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        zipfile="data/UCI_HAR_data.zip"
        message("Downloading the data")
        download.file(fileURL, destfile=zipfile)
        unzip(zipfile, exdir="data")
        message("Downloading data completed!")
}

# Loading the data
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./data/UCI HAR Dataset/features.txt")[,2]
extract_features <- grepl("mean|std", features)
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
names(X_test) = features
X_test = X_test[,extract_features]
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"
# Bind
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load X_train & y_train data
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
names(X_train) = features
X_train = X_train[,extract_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"
# Bind
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge the training and the test sets
data = rbind(test_data, train_data)
id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)
View(tidy_data)

#Create file with the tidy data
write.table(tidy_data, file = "./tidy_data.txt")
