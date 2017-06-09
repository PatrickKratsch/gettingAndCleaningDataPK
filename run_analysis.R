### Getting and Cleaning Data - Course Project ###
## Author: Patrick K. ##


#####################################################################

## 0. Download data ##

library(dplyr)
library(data.table)

# Create data directory if it doesn't exist, and download dataset into it
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "./data/trackingData.zip")

# Navigate to ./data/ using Termainal (Mac) and unzip trackingData.zip with the unzip command


#####################################################################


## 1. Merge the training and test data sets to create one dataset ##

# First, read the test data set, the corresponding test activity labels, and the subject definitions into variables
test_dataset <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test_subjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
# Now, bind (from left to right) the subject definitions, the activity labels, and the test dataset together
test_data_full <- cbind(test_subjects, test_labels, test_dataset)

# Repeat the same process with the training dataset
train_dataset <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train_subjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
train_data_full <- cbind(train_subjects, train_labels, train_dataset)

# Convert both data.frames into data.tables
setDT(test_data_full)
setDT(train_data_full)

# Assign names to the columns
# Read in features.txt and add column names for first two columns
col_names <- read.table("./data/UCI HAR Dataset/features.txt")
col_names <- data.frame(col_names[, 2], stringsAsFactors = FALSE)
col_names <- as.character(col_names[, 1])
col_names_complete <- c("Subject", "Activity", col_names)

# Rename labelled datasets using setnames() from the data.table package
test_data_labelled <- setnames(test_data_full, col_names_complete)
train_data_labelled <- setnames(train_data_full, col_names_complete)

# Now, merge the two datasets using rbind()
merged_data_set <- rbind(train_data_labelled, test_data_labelled)


#####################################################################


## 2. Extract only the mean and standard deviation for each measurement ##

# Use grepl() to retrieve indices of column names containing (a) the substring 'mean',
# or (b) the substring 'std'
mean_index <- grepl("[a-zA-Z0-9]*mean[a-zA-Z0-9]*", colnames(merged_data_set))
std_index <- grepl("[a-zA-Z0-9]*std[a-zA-Z0-9]*", colnames(merged_data_set))

# Extract only TRUE columns from above, i.e. columns containing the word
# 'mean' or 'std' in their name
mean_index <- which(mean_index == TRUE)
merged_data_set_means <- merged_data_set[, mean_index, with=FALSE]

std_index <- which(std_index == TRUE)
merged_data_set_std <- merged_data_set[, std_index, with=FALSE]

# Add these two data sets using cbin()
merged_data_set_mean_std <- cbind(merged_data_set[, 1:2, with = FALSE], merged_data_set_means, merged_data_set_std)


#####################################################################


## 3. Use descriptive activity names to name the activities in the data set ##

# First change second column of dataset to characters, to enable replacement below
merged_data_set_mean_std[[2]] <- as.character(merged_data_set_mean_std[[2]])

# Use gsub() to replace replacement of numbers to corresponding activity labels
merged_data_set_mean_std[[2]] <- gsub("1", "WALKING", merged_data_set_mean_std[[2]])
merged_data_set_mean_std[[2]] <- gsub("2", "WALKING_UPSTAIRS", merged_data_set_mean_std[[2]])
merged_data_set_mean_std[[2]] <- gsub("3", "WALKING_DOWNSTAIRS", merged_data_set_mean_std[[2]])
merged_data_set_mean_std[[2]] <- gsub("4", "SITTING", merged_data_set_mean_std[[2]])
merged_data_set_mean_std[[2]] <- gsub("5", "STANDING", merged_data_set_mean_std[[2]])
merged_data_set_mean_std[[2]] <- gsub("6", "LAYING", merged_data_set_mean_std[[2]])


#####################################################################


## 4. Appropriately label the data set with descriptive variable names ##

# All columns have already been descriptively named in step (1), but the 
# commands are reiterated here (commented out)

## Assign names to the columns
## Read in features.txt and add column names for first two columns
# col_names <- read.table("./data/UCI HAR Dataset/features.txt")
# col_names <- data.frame(col_names[, 2], stringsAsFactors = FALSE)
# col_names <- as.character(col_names[, 1])
# col_names_complete <- c("Subject", "Activity", col_names)

## Rename labelled datasets using setnames() from the data.table package
# test_data_labelled <- setnames(test_data_full, col_names_complete)
# train_data_labelled <- setnames(train_data_full, col_names_complete)


#####################################################################

## 5. From the data set in step 4, create a second, independent tidy data set ##
## with the average of each variable for each activity and each subject ##

# H. Whickham - Tidy Data # 
# 1. Each variable forms a column.
# 2. Each observation forms a row.
# 3. Each type of observational unit forms a table.

# 1. Melt the dataset, so that all columns are variables, not observations
# Assign columns 1 and 2 to id.vars, as Subject and Activity are already
# in the correct format
merged_data_set_mean_std_molten <- melt(merged_data_set_mean_std, id.vars = c(1, 2))

# 2. Rename columns with descriptive names
merged_data_set_mean_std_molten <- setnames(merged_data_set_mean_std_molten, c("subject", "activity", 
                                                                               "measurement_type", 
                                                                               "measurement_result"))
# 3. Split tidy data set by subject
merged_data_set_mean_std_molten_subjects <- split(merged_data_set_mean_std_molten, 
                                                  merged_data_set_mean_std_molten$subject)

# Create 4 separate vectors that will later be joined to a data.frame
subject <- character()
activity <- character()
measurement <- character()
mean_result <- numeric()

# 4. Loop through each subject
for(i in 1:(length(merged_data_set_mean_std_molten_subjects))){
  
  temp_data_set <- merged_data_set_mean_std_molten_subjects[i]
  temp_data_set <- as.data.frame(temp_data_set)
  # Split data by activity
  temp_data_set_split <- split(temp_data_set, temp_data_set[[2]])
  
  # Loop through activities
  for(j in 1:length(temp_data_set_split)){
    
    current_act <- names(temp_data_set_split)[[j]]
    
    temp_data_set2 <- temp_data_set_split[j]
    temp_data_set2 <- as.data.frame(temp_data_set2)
    # Calculate the mean of the measurement_result, broken down by measurement_type
    temp_data_set2_means <- as.data.frame(tapply(temp_data_set2[[4]], temp_data_set2[[3]], mean))
    
    # Append all four columns to output
    col_len <- dim(temp_data_set2_means)[1]
    subject <- c(subject, rep(i, col_len))
    activity <- c(activity, rep(current_act, col_len))
    measurement <- c(measurement, rownames(temp_data_set2_means))
    mean_result <- c(mean_result, as.numeric(temp_data_set2_means[[1]]))
  }
  
}

# Bind all 4 vectors to a data.frame
# This dataset is tidy according to the tidy data principles
output <- data.frame(Subject = subject, Activity = activity, Measurement = measurement, Mean_result = mean_result)

#####################################################################
############################## END ##################################
#####################################################################
