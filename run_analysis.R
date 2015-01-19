#
# Getting and Cleaning Data - Peer Assignment 2
#
# Merge the training and test sets to create one data set
# Extract only the measurements on the mean and standard-deviation for each measurement
# Use descriptive activity names to name the activities in the data set
# Appropriately lable the data set with descriptive variable names
# From the data set in step 4, create a second, independent tidy data set with average of each variable for each activity for each subject
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
str(df)

# The 3 variables (subject, activity, dataset_type) that were santized much
summary(df[,c(1, NROW(df)-1, NROW(df))])


# *** RUBRIC #5: FROM THE DATASET IN STEP4, CREATE A SECOND, INDEPENDENT
#     TIDY DATASET WITH AVG OF EACH VAR FOR EACH ACTIVITY, FOR EACH SUBJECT ***
library(dplyr)
n <- NCOL(df)
tidy_df <- df %>% group_by(subject, activity) %>% select(2:n-2) %>% summarise_each(funs(mean))
summary(tidy_df[,-c(5:80)])  # Just a few first columns to visually check

write.table(tidy_df, file = "getdata_peerassign2_tidy_data.txt", row.names = FALSE)



