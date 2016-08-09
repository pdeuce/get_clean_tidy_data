##set working dir and load needed packages
setwd("C://Users/Downloads/get_and_clean_R/")
library(plyr)
file <- "data.zip"
url <-
  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data_dir <- "UCI HAR Dataset"
result_dir <- "results"


##reads in zip file
getTable <- function (filename, cols = NULL) {
  print(paste("Getting table:", filename))
    f <- unz(file, paste(data_dir, filename, sep = "/"))
    data <- data.frame()
    if (is.null(cols)) {
    data <- read.table(f, sep = "", stringsAsFactors = F)
  } else {
    data <- read.table(
      f,
      sep = "",
      stringsAsFactors = F,
      col.names = cols
    )
  }
    data
  }

##Reads and creates a complete data set
getData <- function(type, features) {
  print(paste("Getting data", type))
    subject_data <-
    getTable(paste(type, "/", "subject_", type, ".txt", sep = ""), "id")
  y_data <-
    getTable(paste(type, "/", "y_", type, ".txt", sep = ""), "activity")
  x_data <-
    getTable(paste(type, "/", "X_", type, ".txt", sep = ""), features$V2)
  
  return (cbind(subject_data, y_data, x_data))
}

##saves the data into the result folder
saveResult <- function (data, name) {
  print(paste("Saving data", name))
  
  file <- paste(result.dir, "/", name, ".csv" , sep = "")
  write.csv(data, file)
}

##get common data tables

features <- getTable("features.txt")

## Load the data sets
train <- getData("train", features)
test <- getData("test", features)

## Merges the training and the test sets 
data <- rbind(train, test)

# rearrange the data using id
data <- arrange(data, id)
activity_labels <- getTable("activity_labels.txt")
data$activity <-
  factor(data$activity, levels = activity_labels$V1, labels = activity_labels$V2)

## Extracts mean and standard deviation 
dataset1 <-
  data[, c(1, 2, grep("std", colnames(data)), grep("mean", colnames(data)))]

# save dataset1 into results 
saveResult(dataset1, "dataset1")

## Creates a second, independent tidy dataset
dataset2 <-
  ddply(
    dataset1,
    .(id, activity),
    .fun = function(x) {
      colMeans(x[, -c(1:2)])
    }
  )

# Add mean columns
colnames(dataset2)[-c(1:2)] <-
  paste(colnames(dataset2)[-c(1:2)], "_mean", sep = "")

# Save tidy dataset2 into results
saveResult(dataset2, "dataset2")
