# GetData_PeerAssign2
Coursera Data Science Speclzn - Getting and Cleaning Data - Peer Assignment 2 

## SYNOPSIS
The goal of this project is to collect, work with, and clean a data set to prepare a filtered, tidy data that can be used for later analysis. The dataset is about wearable computing. Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data that we have represent data collected from the accelerometers from the Samsung Galaxy S smartphone. We read, process and transform the data into a tidy dataset and store it another file for further analysis.


## APPROACH
We see the following structure inside out dataset zip file 'getdata-projectfiles-UCI HAR Dataset.zip'. 

```r
    $ tree "UCI HAR Dataset"
    UCI HAR Dataset
    ├── test/
    │   ├── Inertial Signals/
    │   ├── X_test.txt
    │   ├── subject_test.txt
    │   └── y_test.txt
    ├── train/
    │   ├── Inertial Signals/
    │   ├── X_train.txt
    │   ├── subject_train.txt
    │   └── y_train.txt
    ├── README.txt
    ├── activity_labels.txt
    ├── features.txt
    └── features_info.txt
```
We can see that the subdirectories 'train' and 'test' have similar structure and data files. We focus on the 3 data files 'X', 'subject', and 'y': the 'feature vector values', 'the test subject from whom the device is collecting the activity data', and 'the activity' itself respectively. A quick cursory look at these files show us that these files are space-separated, do not have header lines or quoted values or comment lines, making read.table suitable for reading. Also the 'X' data is 561 variable (columns) data, the entirety of which will not be useful for us, but only the few variables that have to do 'mean' and 'standard deviation' (that is, those that have 'mean' or 'std' in their name, case in-sensitive). 
We also notice that, at the root directory, we have meta-data files such as 'activity_labels.txt' and 'features.txt' giving meaning to the dataset files inside the 'train' and 'test' subdirectories. 'activity_labels.txt' lists the human understandable labels of the SIX activities: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING and the features.txt gives the labels for the 561 variables.


## Source Credtis
  *For more and thorough information about the origin/ideas of this dataset, please see* [this link][1]
  [1]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
  


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

## Transformation steps
  First we devlop few handy functions:

```r
#Handy function to construct and return the filepath
filePath <- function(datasetType="train", fileNamePrefix="y") {
    directory <- "UCI HAR Dataset"
    path <- paste(directory, "/", datasetType, "/",
                fileNamePrefix, "_", datasetType, ".txt", sep="")
    path
}
```


```r
# Handy function to keep read.table params, setting varNames
# and subsetting variables(columns) in one place.
readTable <- function(datasetType="train", fileNamePrefix="y",
                      varIndices=NA, varNames=NA) {
    df = read.table(filePath(datasetType, fileNamePrefix), header=FALSE,
               sep="", quote="", comment.char="",
               nrow=7400, colClasses=c("numeric"))
    if (!is.na(varIndices)) df <- df[, varIndices]
    if (!is.na(varNames)) names(df) <- varNames
    df
}
```
If variable indices are passed, this function would subset the data frame 
to have only those variables(columns).  If variable names are passed,
it assigns them to the variables(columns).



```r
# Similar to readTable, but reads the meta-data files such as
# features.txt and activity_labels.txt rather than a data file.
readMetaTable <- function(fileName) {
    directory <- "UCI HAR Dataset"
    filePath <- paste(directory, "/", fileName, sep="")
    read.table(filePath, header=FALSE, sep="", quote="",
               comment.char="")
}
```


## The complete code (with annotations to the RUBRICs) is listed below:

```r
#
# Getting and Cleaning Data - Peer Assignment 2
#
# 1) Merge the training and test sets to create one data set
# 2) Extract only the measurements on the mean and standard-deviation 
#   for each measurement
# 3) Use descriptive activity names to name the activities in the data set
# 4) Appropriately lable the data set with descriptive variable names
# 5) From the data set in step 4, create a second, independent tidy data set 
#   with average of each variable for each activity for each subject
#

library(dplyr)
library(data.table)


#Handy function to construct and return the filepath
filePath <- function(datasetType="train", fileNamePrefix="y") {
    directory <- "UCI HAR Dataset"
    path <- paste(directory, "/", datasetType, "/",
                fileNamePrefix, "_", datasetType, ".txt", sep="")
    path
}


# Handy function to keep read.table params, setting varNames
# and subsetting variables(columns) in one place.
readTable <- function(datasetType="train", fileNamePrefix="y",
                      varIndices=NA, varNames=NA) {
    df = read.table(filePath(datasetType, fileNamePrefix), header=FALSE,
               sep="", quote="", comment.char="",
               nrow=7400, colClasses=c("numeric"))
    if (!is.na(varIndices)) df <- df[, varIndices]
    if (!is.na(varNames)) names(df) <- varNames
    df
}


# Similar to readTable, but reads the meta-data files such as
# features.txt and activity_labels.txt rather than a data file.
readMetaTable <- function(fileName) {
    directory <- "UCI HAR Dataset"
    filePath <- paste(directory, "/", fileName, sep="")
    read.table(filePath, header=FALSE, sep="", quote="",
               comment.char="")
}


readData <- function() {

    # --First, lets read meta-data about features and activity-labels--
    # Read the meaningful names of feature variables. There are some
    # duplicate names. Fortunately none of them have 'mean' or 'std' in
    # their name that we are interested in. So, we can safely ignore them
    # *according to a community TA*.
    feature_names <- readMetaTable("features.txt")

    # *** RUBRIC #2: EXTRACT ONLY MEAN & STDDEV FOR EACH MEASUREMENT ***
    wanted_features_idx <- grep("mean|std", feature_names$V2, ignore.case = TRUE)
    wanted_features <- feature_names$V2[wanted_features_idx]

    # *** RUBRIC #4: APPROPRIATELY NAME THE DATASET WITH DESCRIPTIVE VAR NAMES ***
    # Non-word characters such as '-', '(', ')' can create problems in R
    # as variable-names. So, lets replace those chars with '__'
    wanted_features <- gsub("\\W+", "_", wanted_features)

    # *** RUBRIC #3: USE DESCRIPTIVE ACTIVITY NAMES ***
    # Read the discrete labels of outcome (aka "y" or "activity")
    activity_names <- readMetaTable("activity_labels.txt")
    activity_labels <- activity_names$V1
    activity_levels <- activity_names$V2

    # --Read the 'training' dataset--
    df <- readTable("train", "subject", varNames="subject")
    df <- cbind(df, readTable("train", "X", varIndices=wanted_features_idx,
                      varNames=wanted_features))
    df <- cbind(df, readTable("train", "y", varNames="activity"))
    df$activity <- as.factor(df$activity); levels(df$activity) <- activity_levels;
    df$dataset_type <- "train"

    # --Now read the 'test' dataset--
    df2 <- readTable("test", "subject", varNames="subject")
    df2 <- cbind(df2, readTable("test", "X", varIndices=wanted_features_idx,
                              varNames=wanted_features))
    df2 <- cbind(df2, readTable("test", "y", varNames="activity"))
    df2$activity <- as.factor(df2$activity); levels(df2$activity) <- activity_levels;
    df2$dataset_type <- "test"

    # *** RUBRIC #1: MERGE TRAINING AND TEST SETS INTO ONE ***
    df <- rbind(df, df2)
    df$dataset_type <- as.factor(df$dataset_type)

    df
}


df <- readData()
```

```
## Warning in if (!is.na(varIndices)) df <- df[, varIndices]: the condition
## has length > 1 and only the first element will be used
```

```
## Warning in if (!is.na(varNames)) names(df) <- varNames: the condition has
## length > 1 and only the first element will be used
```

```
## Warning in if (!is.na(varIndices)) df <- df[, varIndices]: the condition
## has length > 1 and only the first element will be used
```

```
## Warning in if (!is.na(varNames)) names(df) <- varNames: the condition has
## length > 1 and only the first element will be used
```

```r
n <- NCOL(df)
str(df)
```

```
## 'data.frame':	10299 obs. of  89 variables:
##  $ subject                             : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ tBodyAcc_mean_X                     : num  0.289 0.278 0.28 0.279 0.277 ...
##  $ tBodyAcc_mean_Y                     : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
##  $ tBodyAcc_mean_Z                     : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
##  $ tBodyAcc_std_X                      : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
##  $ tBodyAcc_std_Y                      : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
##  $ tBodyAcc_std_Z                      : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
##  $ tGravityAcc_mean_X                  : num  0.963 0.967 0.967 0.968 0.968 ...
##  $ tGravityAcc_mean_Y                  : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
##  $ tGravityAcc_mean_Z                  : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
##  $ tGravityAcc_std_X                   : num  -0.985 -0.997 -1 -0.997 -0.998 ...
##  $ tGravityAcc_std_Y                   : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
##  $ tGravityAcc_std_Z                   : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
##  $ tBodyAccJerk_mean_X                 : num  0.078 0.074 0.0736 0.0773 0.0734 ...
##  $ tBodyAccJerk_mean_Y                 : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
##  $ tBodyAccJerk_mean_Z                 : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
##  $ tBodyAccJerk_std_X                  : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
##  $ tBodyAccJerk_std_Y                  : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
##  $ tBodyAccJerk_std_Z                  : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
##  $ tBodyGyro_mean_X                    : num  -0.0061 -0.0161 -0.0317 -0.0434 -0.034 ...
##  $ tBodyGyro_mean_Y                    : num  -0.0314 -0.0839 -0.1023 -0.0914 -0.0747 ...
##  $ tBodyGyro_mean_Z                    : num  0.1077 0.1006 0.0961 0.0855 0.0774 ...
##  $ tBodyGyro_std_X                     : num  -0.985 -0.983 -0.976 -0.991 -0.985 ...
##  $ tBodyGyro_std_Y                     : num  -0.977 -0.989 -0.994 -0.992 -0.992 ...
##  $ tBodyGyro_std_Z                     : num  -0.992 -0.989 -0.986 -0.988 -0.987 ...
##  $ tBodyGyroJerk_mean_X                : num  -0.0992 -0.1105 -0.1085 -0.0912 -0.0908 ...
##  $ tBodyGyroJerk_mean_Y                : num  -0.0555 -0.0448 -0.0424 -0.0363 -0.0376 ...
##  $ tBodyGyroJerk_mean_Z                : num  -0.062 -0.0592 -0.0558 -0.0605 -0.0583 ...
##  $ tBodyGyroJerk_std_X                 : num  -0.992 -0.99 -0.988 -0.991 -0.991 ...
##  $ tBodyGyroJerk_std_Y                 : num  -0.993 -0.997 -0.996 -0.997 -0.996 ...
##  $ tBodyGyroJerk_std_Z                 : num  -0.992 -0.994 -0.992 -0.993 -0.995 ...
##  $ tBodyAccMag_mean_                   : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ tBodyAccMag_std_                    : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ tGravityAccMag_mean_                : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ tGravityAccMag_std_                 : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ tBodyAccJerkMag_mean_               : num  -0.993 -0.991 -0.989 -0.993 -0.993 ...
##  $ tBodyAccJerkMag_std_                : num  -0.994 -0.992 -0.99 -0.993 -0.996 ...
##  $ tBodyGyroMag_mean_                  : num  -0.969 -0.981 -0.976 -0.982 -0.985 ...
##  $ tBodyGyroMag_std_                   : num  -0.964 -0.984 -0.986 -0.987 -0.989 ...
##  $ tBodyGyroJerkMag_mean_              : num  -0.994 -0.995 -0.993 -0.996 -0.996 ...
##  $ tBodyGyroJerkMag_std_               : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ fBodyAcc_mean_X                     : num  -0.995 -0.997 -0.994 -0.995 -0.997 ...
##  $ fBodyAcc_mean_Y                     : num  -0.983 -0.977 -0.973 -0.984 -0.982 ...
##  $ fBodyAcc_mean_Z                     : num  -0.939 -0.974 -0.983 -0.991 -0.988 ...
##  $ fBodyAcc_std_X                      : num  -0.995 -0.999 -0.996 -0.996 -0.999 ...
##  $ fBodyAcc_std_Y                      : num  -0.983 -0.975 -0.966 -0.983 -0.98 ...
##  $ fBodyAcc_std_Z                      : num  -0.906 -0.955 -0.977 -0.99 -0.992 ...
##  $ fBodyAcc_meanFreq_X                 : num  0.252 0.271 0.125 0.029 0.181 ...
##  $ fBodyAcc_meanFreq_Y                 : num  0.1318 0.0429 -0.0646 0.0803 0.058 ...
##  $ fBodyAcc_meanFreq_Z                 : num  -0.0521 -0.0143 0.0827 0.1857 0.5598 ...
##  $ fBodyAccJerk_mean_X                 : num  -0.992 -0.995 -0.991 -0.994 -0.996 ...
##  $ fBodyAccJerk_mean_Y                 : num  -0.987 -0.981 -0.982 -0.989 -0.989 ...
##  $ fBodyAccJerk_mean_Z                 : num  -0.99 -0.99 -0.988 -0.991 -0.991 ...
##  $ fBodyAccJerk_std_X                  : num  -0.996 -0.997 -0.991 -0.991 -0.997 ...
##  $ fBodyAccJerk_std_Y                  : num  -0.991 -0.982 -0.981 -0.987 -0.989 ...
##  $ fBodyAccJerk_std_Z                  : num  -0.997 -0.993 -0.99 -0.994 -0.993 ...
##  $ fBodyAccJerk_meanFreq_X             : num  0.8704 0.6085 0.1154 0.0358 0.2734 ...
##  $ fBodyAccJerk_meanFreq_Y             : num  0.2107 -0.0537 -0.1934 -0.093 0.0791 ...
##  $ fBodyAccJerk_meanFreq_Z             : num  0.2637 0.0631 0.0383 0.1681 0.2924 ...
##  $ fBodyGyro_mean_X                    : num  -0.987 -0.977 -0.975 -0.987 -0.982 ...
##  $ fBodyGyro_mean_Y                    : num  -0.982 -0.993 -0.994 -0.994 -0.993 ...
##  $ fBodyGyro_mean_Z                    : num  -0.99 -0.99 -0.987 -0.987 -0.989 ...
##  $ fBodyGyro_std_X                     : num  -0.985 -0.985 -0.977 -0.993 -0.986 ...
##  $ fBodyGyro_std_Y                     : num  -0.974 -0.987 -0.993 -0.992 -0.992 ...
##  $ fBodyGyro_std_Z                     : num  -0.994 -0.99 -0.987 -0.989 -0.988 ...
##  $ fBodyGyro_meanFreq_X                : num  -0.2575 -0.0482 -0.2167 0.2169 -0.1533 ...
##  $ fBodyGyro_meanFreq_Y                : num  0.0979 -0.4016 -0.0173 -0.1352 -0.0884 ...
##  $ fBodyGyro_meanFreq_Z                : num  0.5472 -0.0682 -0.1107 -0.0497 -0.1622 ...
##  $ fBodyAccMag_mean_                   : num  -0.952 -0.981 -0.988 -0.988 -0.994 ...
##  $ fBodyAccMag_std_                    : num  -0.956 -0.976 -0.989 -0.987 -0.99 ...
##  $ fBodyAccMag_meanFreq_               : num  -0.0884 -0.0441 0.2579 0.0736 0.3943 ...
##  $ fBodyBodyAccJerkMag_mean_           : num  -0.994 -0.99 -0.989 -0.993 -0.996 ...
##  $ fBodyBodyAccJerkMag_std_            : num  -0.994 -0.992 -0.991 -0.992 -0.994 ...
##  $ fBodyBodyAccJerkMag_meanFreq_       : num  0.347 0.532 0.661 0.679 0.559 ...
##  $ fBodyBodyGyroMag_mean_              : num  -0.98 -0.988 -0.989 -0.989 -0.991 ...
##  $ fBodyBodyGyroMag_std_               : num  -0.961 -0.983 -0.986 -0.988 -0.989 ...
##  $ fBodyBodyGyroMag_meanFreq_          : num  -0.129 -0.272 -0.2127 -0.0357 -0.2736 ...
##  $ fBodyBodyGyroJerkMag_mean_          : num  -0.992 -0.996 -0.995 -0.995 -0.995 ...
##  $ fBodyBodyGyroJerkMag_std_           : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ fBodyBodyGyroJerkMag_meanFreq_      : num  -0.0743 0.1581 0.4145 0.4046 0.0878 ...
##  $ angle_tBodyAccMean_gravity_         : num  -0.1128 0.0535 -0.1186 -0.0368 0.1233 ...
##  $ angle_tBodyAccJerkMean_gravityMean_ : num  0.0304 -0.00743 0.1779 -0.01289 0.12254 ...
##  $ angle_tBodyGyroMean_gravityMean_    : num  -0.465 -0.733 0.101 0.64 0.694 ...
##  $ angle_tBodyGyroJerkMean_gravityMean_: num  -0.0184 0.7035 0.8085 -0.4854 -0.616 ...
##  $ angle_X_gravityMean_                : num  -0.841 -0.845 -0.849 -0.849 -0.848 ...
##  $ angle_Y_gravityMean_                : num  0.18 0.18 0.181 0.182 0.185 ...
##  $ angle_Z_gravityMean_                : num  -0.0586 -0.0543 -0.0491 -0.0477 -0.0439 ...
##  $ activity                            : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 5 5 5 5 5 5 5 5 5 5 ...
##  $ dataset_type                        : Factor w/ 2 levels "test","train": 2 2 2 2 2 2 2 2 2 2 ...
```

```r
# The 3 variables (subject, activity, dataset_type) that were santized much
summary(df[,c(1, n-1, n)])
```

```
##     subject                    activity    dataset_type
##  Min.   : 1.00   WALKING           :1722   test :2947  
##  1st Qu.: 9.00   WALKING_UPSTAIRS  :1544   train:7352  
##  Median :17.00   WALKING_DOWNSTAIRS:1406               
##  Mean   :16.15   SITTING           :1777               
##  3rd Qu.:24.00   STANDING          :1906               
##  Max.   :30.00   LAYING            :1944
```

```r
# *** RUBRIC #5: FROM THE DATASET IN STEP4, CREATE A SECOND, INDEPENDENT
#     TIDY DATASET WITH AVG OF EACH VAR FOR EACH ACTIVITY, FOR EACH SUBJECT ***
library(dplyr)
tidy_df <- df %>% group_by(subject, activity) %>% 
             select(2:n-2) %>% summarise_each(funs(mean))
n <- NCOL(tidy_df)
summary(tidy_df[,-c(5:80)])  # Just a few first columns to visually check
```

```
##     subject                   activity  tBodyAcc_mean_X 
##  Min.   : 1.0   WALKING           :30   Min.   :0.2216  
##  1st Qu.: 8.0   WALKING_UPSTAIRS  :30   1st Qu.:0.2712  
##  Median :15.5   WALKING_DOWNSTAIRS:30   Median :0.2770  
##  Mean   :15.5   SITTING           :30   Mean   :0.2743  
##  3rd Qu.:23.0   STANDING          :30   3rd Qu.:0.2800  
##  Max.   :30.0   LAYING            :30   Max.   :0.3015  
##  tBodyAcc_mean_Y     fBodyBodyGyroJerkMag_meanFreq_
##  Min.   :-0.040514   Min.   :-0.18292              
##  1st Qu.:-0.020022   1st Qu.: 0.05423              
##  Median :-0.017262   Median : 0.11156              
##  Mean   :-0.017876   Mean   : 0.12592              
##  3rd Qu.:-0.014936   3rd Qu.: 0.20805              
##  Max.   :-0.001308   Max.   : 0.42630              
##  angle_tBodyAccMean_gravity_ angle_tBodyAccJerkMean_gravityMean_
##  Min.   :-0.163043           Min.   :-0.1205540                 
##  1st Qu.:-0.011012           1st Qu.:-0.0211694                 
##  Median : 0.007878           Median : 0.0031358                 
##  Mean   : 0.006556           Mean   : 0.0006439                 
##  3rd Qu.: 0.024393           3rd Qu.: 0.0220881                 
##  Max.   : 0.129154           Max.   : 0.2032600                 
##  angle_tBodyGyroMean_gravityMean_ angle_tBodyGyroJerkMean_gravityMean_
##  Min.   :-0.38931                 Min.   :-0.22367                    
##  1st Qu.:-0.01977                 1st Qu.:-0.05613                    
##  Median : 0.02087                 Median :-0.01602                    
##  Mean   : 0.02193                 Mean   :-0.01137                    
##  3rd Qu.: 0.06460                 3rd Qu.: 0.03200                    
##  Max.   : 0.44410                 Max.   : 0.18238                    
##  angle_X_gravityMean_ angle_Y_gravityMean_ angle_Z_gravityMean_
##  Min.   :-0.9471      Min.   :-0.87457     Min.   :-0.873649   
##  1st Qu.:-0.7907      1st Qu.: 0.02191     1st Qu.:-0.083912   
##  Median :-0.7377      Median : 0.17136     Median : 0.005079   
##  Mean   :-0.5243      Mean   : 0.07865     Mean   :-0.040436   
##  3rd Qu.:-0.5823      3rd Qu.: 0.24343     3rd Qu.: 0.106190   
##  Max.   : 0.7378      Max.   : 0.42476     Max.   : 0.390444
```

```r
write.table(tidy_df, file = "getdata_peerassign2_tidy_data.txt", row.names = FALSE)
```

For details about the data transformations done please look at the CodeBook.md file.
