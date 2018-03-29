The task was to create one R script called run_analysis.R that does the following.:

Merges the training and the test sets to create one data set.
Extracts only the measurements on the mean and standard deviation for each measurement.
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names.
From the data set, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



#step 0
creating a directory, download the zip file and unzip it 

if(!file.exists("./mobile")){dir.create("./mobile")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./mobile/study.zip")
unzip("./mobile/study.zip")


#step 1
reading the different files into variables except for features.txt which will be handled later
header = FALSE otherwise the header would contain data from the first line

X_train <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = FALSE)

y_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)

X_test <- read.csv("./UCI HAR Dataset/test/X_test.txt" , header = FALSE)
	
y_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = FALSE)

subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)

activity_labels <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = FALSE)


#step 2
checking the hypothesis, that the files in Inertial Signals directories are inputs of X_test or X_train
based on the README.txt, the X_test and X-train files contain the values calculated from the windows (rows) of signal files.
"From each window, a vector of features was obtained by calculating variables from the time and frequency domain."  
consequently, the data in Inertial Signals directories should not be processed now.


#step 3
merging the data frames of test data

#step 3/a
first activity_labels shall be tidy with an appropriate id 
to separate the nr from the name of activities, I will use separate function from tidyr package

library(tidyr)
activity_labels <- separate(activity_labels, V1, c("activity_nr", "activity"), sep = " ")
activity_labels$activity <- tolower(activity_labels$activity) 

#step 3/b
rename the column of subjects as "examinedperson"

library(dplyr)
subject_test <- rename (subject_test, "examinedperson" = "V1")

#step 3/c
giving an id to y_test, X_test, subject_test

y_test$activity_id <- rownames(y_test)
X_test$test_id <- rownames(X_test)
subject_test$subject_id <- rownames(subject_test)

#step 3/d
numbers should be replaced by activity names in y_test 

temp <- merge(activity_labels, y_test, by.x ="activity_nr", by.y ="V1")
y_test <- temp[,2:3]

#step 3/e
merging y_test, subject_test, than X_test

temp <- merge(y_test, subject_test, by.x ="activity_id", by.y ="subject_id")
X_test <- merge(X_test, temp, by.x ="test_id", by.y ="activity_id")


#step 4
merging the data frames of train data the same way as test data

subject_train <- rename (subject_train, "examinedperson" = "V1")

y_train$activity_id <- rownames(y_train)
X_train$train_id <- rownames(X_train)
subject_train$subject_id <- rownames(subject_train)

temp <- merge(activity_labels, y_train, by.x ="activity_nr", by.y ="V1")
y_train <- temp[,2:3]

temp <- merge(y_train, subject_train, by.x ="activity_id", by.y ="subject_id")
X_train <- merge(X_train, temp, by.x ="train_id", by.y ="activity_id")


#step 5
binding train and test data
first we get rid of the test_id and train_id variables

X_test <- within(X_test, rm(test_id))
X_train <- within(X_train, rm(train_id))

then a "dataset" variable is created in both X_train and X_test dataframe
X_test <- mutate(X_test, dataset = "test")
X_train <- mutate(X_train, dataset = "train")

then the two datasets are bound
X<- bind_rows(X_train,X_test)

an id is given for the bound set in order to help the later spread process
X$id <- rownames(X)

in order to save some memory X_test and X_train are removed
rm(X_train)
rm(X_test)
 
 
#step 6

#step 6/a
tidy the features file, all values should be in one row
since there were white spaces at the end of the lines, text was divided into rows
sep = "\n" new line solves the issue
read.table would also be a solution
header should also be FALSE, since by mistake the first value is the column name

features <- read.csv("./UCI HAR Dataset/features.txt", header = FALSE, sep = "\n")

#step 6/b
the values should be slightly modified
we need characters instead of factors for using the features as variable names later

features <- mutate(features, colnames = as.character(features$V1))

we need to get rid of the unnecessary numbers at the beginning of the values 

features$colnames <- gsub("^[0-9]+ ", "", features$colnames)

since there are duplicated values with the same feature name, I assume that they belong to different axis(X,Y,Z)
the assumption is based on the fact that all affected signals have X,Y,Z directions (fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ)
therefore I added X,Y,Z to the end of the features in question(i.e. all features containing "bandsEnergy()")
14 unique features is followed by 2*14 duplicated features

a <- grep("bandsEnergy()", features$colnames)
b<- c(rep("-X",14), rep("-Y",14), rep("-Z", 14))
c <- rep(b,3)
for (i in seq_along(c)) { features$colnames[a[i]] <- paste0(features$colnames[a[i]], c[i])}

in some features the word "Body" was repeated, therefore it was replaced

features <- mutate(features, colnames = gsub("BodyBody", "Body", colnames))

the angle variables have a common element, one of the vectors was gravityMean and the other was either the mean of a signal or an axis
in one case there is just gravity, but based on the features_info.txt there is no gravity vector, just gravityMean
therefore the word "gravity"  is modified to "gravityMean"
signals without Mean are placed in front of the word angle, axis are placed at the end
in the code book, it could be indicated that angle variable measure two vectors: gravityMean and an axis or the mean of a signal 

features <- mutate (features, colnames = gsub("(angle.*gravity).*", "\\1Mean\\)", colnames))
features <- mutate(features, colnames = gsub("(angle).*(t.+)Mean.*,gravityMean.*", "\\2-\\1", colnames))
features <- mutate(features, colnames = gsub("(angle).*([X-Z]).*,gravityMean.*", "\\1-\\2", colnames)) 

#step 6/c
marking the values for the later separation 

features will be the variables in X data frame
though it would not be a tidy data set, since the variables contain more than one categories
I identified 9 different categories in them: 
1:domain(time/frequency), 
signal, which has two parts
	2:Body/Gravity, 
	3:Acc/Gyro,
4:jerk signal, 
5:magnitude, 
6:indicator, 
7:the frequency intervals of bandsEnergy indicator, 
8:the axes, 
9:the coefficients of correlation indicators

with the help of regular expressions, I placed ":" marks between them
features <- mutate(features, colnames = gsub("^(t|f)?(Body|Gravity)?(Acc|Gyro)?(Jerk)?(Mag)?(?:-)?([a-zA-Z]+)(?:\\(\\))?(?:-)?([0-9]+,[0-9]+)?(?:-)?([X-Z])?(?:-)?([0-9X-Z](?:,)?(?:[0-9X-Z])?)?", 
"\\1:\\2\\3:\\4:\\5:\\6:\\7:\\8:\\9", colnames))

#step 7
separate the fix width text column of X into 561 different variables with the name of the features
to get rid of the white spaces at the beginning of X V1 column, I use str_trim()
library(stringr)
X$V1 <- str_trim(X$V1)

separation should be made on the basis of one or more white spaces
X <- separate(X, V1, features$colnames, sep = " +")

#step 8
since the task is to extract only the mean and std variables, I select these from the features variables
X <- select(X, id, activity, examinedperson, dataset, contains("mean"), contains ("std"), -contains("meanFreq"))

#step 9
in order to have a tidy data set, without more than one categories in a variable name, 
the mean and std variables are gathered, separated and spread in a way to have the numbers under variables "mean" and "std"  
X <- gather(X, variables, count, -dataset, -examinedperson, -activity, -id)
X <- separate(X, variables, c("domain", "signal", "jerk", "magnitude", "indicator", "frequencyintervals","axis","coefficients"), sep = ":")
X <- spread(X, indicator,count)

id, frequencyintervals and coefficients variables are irrelevant in the following steps, they are removed
X <- select(X, -id, -frequencyintervals, -coefficients)

#step 10
calculating the average value for all variables
we need numeric values instead of factors, therefore I used lapply and as.character(), than as.numeric() function to alter them
X <- data.frame(lapply(X, as.character), stringsAsFactors=FALSE)
temp <- data.frame(lapply(X[,9:10], as.numeric))
X[,9:10] <- temp

X is the first output of the task, which is a tidy data set merging the train and test data sets, with descriptive activity and variable names, 
extracting only the measurements on mean and std

print("the first dataset is:")
str(X)

since the feature variables were separated to a bunch of identifying variables, to have reasonable average values 
(not handling together for instance magnitude or non magnitude values) the grouping will cover not only the activity and examinedperson
variables but also all variables connected to mean and std previously 
X_grouped <- group_by(X, examinedperson, activity, domain, signal, jerk, magnitude, axis)


dataset variable is excluded, since it is not necessary for grouping, and the mean is not reasonable
X_grouped <- select(X_grouped, - dataset)

finally, with summarize_all, the averages of all groups are calculated in case of all variables
final <- summarize_all(X_grouped, mean)

final is the second output of the task, having a second tidy data set with the average of each variable for each activity and each subject

print("the second dataset will be presented with View:")
View(final)

#step 11
write the result to a txt file
write.table(final, file = "./final.txt", row.name=FALSE)
 





