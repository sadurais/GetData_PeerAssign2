# Data Set Code Book: Human Activity Sensor Data

Prepared By: Sathish Duraisamy
Date: January 18th, 2015


# Source Credtis
*For more and thorough information about the origin/ideas of this dataset, please see* [this link][1]
[1]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


The input dataset contained in getdata-projectfiles-UCI HAR Dataset.zip has the following structure:
  UCI HAR Dataset
  ├── test/                  # The test dataset
  │   ├── Inertial Signals/    # We ignored this in creating the tidy dataset
  │   ├── X_test.txt           # The accelerameter and gyrosscope and other sensor data values
  │   ├── subject_test.txt     # An integer code representing the test-subject (human individual)
  │   └── y_test.txt           # The outcome of the experiment (the names of SIX different activities coded as an integer)
  ├── train/                 # The training dataset
  │   ├── Inertial Signals/    # We ignored this in creating the tidy dataset
  │   ├── X_train.txt          # The accelerameter and gyrosscope and other sensor data values
  │   ├── subject_train.txt    # An integer code representing the test-subject (human individual)
  │   └── y_train.txt          # The outcome of the experiment (the names of SIX different activities coded as an integer)
  ├── README.txt
  ├── activity_labels.txt    # Has the meaningful names of the SIX discrete activities 
  ├── features.txt           # Has the names of the 561 feature vector (sensor data)
  └── features_info.txt     



## Transformations done to the data:
  - *Subsetting the features*: Even though there are 561 variables measured 
       from the sensors, we need only those that measure the 'mean' 
       and 'standard deviation'. So we grep for those patterns 'mean|std' in
       the names of the features that we obtain from the features.txt file.
  - *Attach feature-names to the feature data*: The feature names and feature 
       data are conveyed in two different files: features.txt and 
       {train|test}/X_{train|test}.txt files. We attach the names to the data
       in our data frame using names(df) <- features_names_vect
  - *Sanitizing the feature labels/names*: The feature names from features.txt
       file have non-word characters such as '-', '(', ')' that could cause
       problems with certain R functions. We find&replace such chars with 
       a '_' using regex:  s/\W+/_/g  (global replace a sequence of 1 or more
       non-word characters into a single underscore).So, "tBodyAcc-arCoeff()-X,1"
       becomes "tBodyAcc_arCoeff_X_1"
  - *Ensuring categorical variables are discrete*: Variables with few discrete 
       values needs to be treated as factors for our further analysis to work
       nicely. We use 'as.factor' to convert these variables (activity & dataset_type)
  - *Combine training and test datasets into one*: The subdirectories 'train' 
       and 'test' have similar structure. We use modularized code to read them
       alike and combine them into one data frame using:
       df <- training-set's data
       df <- cbind(df, testing-set's data)
  - *Grouping & Summarizing our data*: We first group by test-subject, then the
       activity and finally take the mean of all the other variables (with index
       2:ncol-2). With these variables we create our final tidy dataset. This
       second dataset is stored in a file: getdata_peerassign2_tidy_data.txt
       as space separated values, for quicker reading by read.table

  
## Final variables:  Mean values grouped by (subject, activity)
  - subject           - The test subject
  - activity          - One of six activities coded as an integer (factor var). 
  - tBodyAcc_mean_X   - TimeSeries data of various dimensions of Accelerometer
  - tBodyAcc_mean_Y   -     and Gyrosscope follow
  - tBodyAcc_mean_Z
  - tBodyAcc_std_X
  - tBodyAcc_std_Y
  - tBodyAcc_std_Z
  - tGravityAcc_mean_X
  - tGravityAcc_mean_Y
  - tGravityAcc_mean_Z
  - tGravityAcc_std_X
  - tGravityAcc_std_Y
  - tGravityAcc_std_Z
  - tBodyAccJerk_mean_X
  - tBodyAccJerk_mean_Y
  - tBodyAccJerk_mean_Z
  - tBodyAccJerk_std_X
  - tBodyAccJerk_std_Y
  - tBodyAccJerk_std_Z
  - tBodyGyro_mean_X
  - tBodyGyro_mean_Y
  - tBodyGyro_mean_Z
  - tBodyGyro_std_X
  - tBodyGyro_std_Y
  - tBodyGyro_std_Z
  - tBodyGyroJerk_mean_X
  - tBodyGyroJerk_mean_Y
  - tBodyGyroJerk_mean_Z
  - tBodyGyroJerk_std_X
  - tBodyGyroJerk_std_Y
  - tBodyGyroJerk_std_Z
  - tBodyAccMag_mean_
  - tBodyAccMag_std_
  - tGravityAccMag_mean_
  - tGravityAccMag_std_
  - tBodyAccJerkMag_mean_
  - tBodyAccJerkMag_std_
  - tBodyGyroMag_mean_
  - tBodyGyroMag_std_
  - tBodyGyroJerkMag_mean_
  - tBodyGyroJerkMag_std_
  - fBodyAcc_mean_X
  - fBodyAcc_mean_Y
  - fBodyAcc_mean_Z
  - fBodyAcc_std_X
  - fBodyAcc_std_Y
  - fBodyAcc_std_Z
  - fBodyAcc_meanFreq_X
  - fBodyAcc_meanFreq_Y
  - fBodyAcc_meanFreq_Z
  - fBodyAccJerk_mean_X
  - fBodyAccJerk_mean_Y
  - fBodyAccJerk_mean_Z
  - fBodyAccJerk_std_X
  - fBodyAccJerk_std_Y
  - fBodyAccJerk_std_Z
  - fBodyAccJerk_meanFreq_X
  - fBodyAccJerk_meanFreq_Y
  - fBodyAccJerk_meanFreq_Z
  - fBodyGyro_mean_X                   
  - fBodyGyro_mean_Y
  - fBodyGyro_mean_Z
  - fBodyGyro_std_X
  - fBodyGyro_std_Y
  - fBodyGyro_std_Z
  - fBodyGyro_meanFreq_X
  - fBodyGyro_meanFreq_Y
  - fBodyGyro_meanFreq_Z
  - fBodyAccMag_mean_
  - fBodyAccMag_std_
  - fBodyAccMag_meanFreq_
  - fBodyBodyAccJerkMag_mean_
  - fBodyBodyAccJerkMag_std_
  - fBodyBodyAccJerkMag_meanFreq_
  - fBodyBodyGyroMag_mean_             
  - fBodyBodyGyroMag_std_
  - fBodyBodyGyroMag_meanFreq_
  - fBodyBodyGyroJerkMag_mean_
  - fBodyBodyGyroJerkMag_std_
  - fBodyBodyGyroJerkMag_meanFreq_
  - angle_tBodyAccMean_gravity_
  - angle_tBodyAccJerkMean_gravityMean_
  - angle_tBodyGyroMean_gravityMean_
  - angle_tBodyGyroJerkMean_gravityMean_
  - angle_X_gravityMean_
  - angle_Y_gravityMean_
  - angle_Z_gravityMean

--end--
