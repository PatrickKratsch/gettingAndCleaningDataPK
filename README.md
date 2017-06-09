# gettingAndCleaningDataPK
Final project of course 3 of the Data Science Specialisation on Coursera

Description of Script

## 1. Download the data

A folder called 'data' is created in the working directory, and the data is downloaded into it.

## 2. Merging training and test data sets to create one dataset

test_data_full is created by combining X_test.txt, y_test.txt, and subject_test.txt into one data.frame. The same is done, respectively, for train_data_full. Both these datasets are then converted into a data.table. col_names_complete is then created, which is a vector containing the column names from features.txt, and these column names are given to train_data_full and test_data_full. Finally, both datasets are merged into merged_data_set.

## 3. Extract only the mean and standard deviation for each measurement

grepl() is used to extract all features containing the word 'mean' or 'std' somewhere in them. The indices of their occurences are then used to extract them from merged_data_set, and the dataset merged_data_set_mean_std is created.

## 4. 3. Use descriptive activity names to name the activities in the data set

The second column of merged_data_set_mean_std is converted into character format, and then gsub() is used to exchange the numbers 1-6 with the respective activity, as described in activity_labels.txt.

## 5. Appropriately label the data set with descriptive variable names

In section (2), this has already been done by labelling the columns of the data set based on the feature descriptions in features.txt.

## 6. From the data set in step 4, create a second, independent tidy data set

First, merged_data_set_mean_std_molten is created by melting merged_data_set_mean_std. The former is then split by subject. Four vectors are created (subject, activity, measurement, and mean_result), which are to be filled with the required values and then later combined into the output data.frame. Next, a loop goes through each subject, and a second loop through each activity. tapply() is used to then obtain the mean of the measurement_result, broken down by measurement_type. Finally, the results of these calculations are stored in the respective vectors mentioned above. Once all subjects have been worked through this way, a data.frame called output is created, which represents a tidy data set with four columns: Subject, Activity, Measurement, and Mean_result.

# END
