if(!file.exists("./mobile")){dir.create("./mobile")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./mobile/study.zip")
unzip("./mobile/study.zip")

X_train <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = FALSE)

y_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = FALSE)

subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)

X_test <- read.csv("./UCI HAR Dataset/test/X_test.txt" , header = FALSE)
	
y_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = FALSE)

subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)

activity_labels <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = FALSE)

library(tidyr)
activity_labels <- separate(activity_labels, V1, c("activity_nr", "activity"), sep = " ")
activity_labels$activity <- tolower(activity_labels$activity) 

library(dplyr)
subject_test <- rename (subject_test, "examinedperson" = "V1")

y_test$activity_id <- rownames(y_test)
X_test$test_id <- rownames(X_test)
subject_test$subject_id <- rownames(subject_test)

temp <- merge(activity_labels, y_test, by.x ="activity_nr", by.y ="V1")
y_test <- temp[,2:3]

temp <- merge(y_test, subject_test, by.x ="activity_id", by.y ="subject_id")
X_test <- merge(X_test, temp, by.x ="test_id", by.y ="activity_id")

subject_train <- rename (subject_train, "examinedperson" = "V1")

y_train$activity_id <- rownames(y_train)
X_train$train_id <- rownames(X_train)
subject_train$subject_id <- rownames(subject_train)

temp <- merge(activity_labels, y_train, by.x ="activity_nr", by.y ="V1")
y_train <- temp[,2:3]

temp <- merge(y_train, subject_train, by.x ="activity_id", by.y ="subject_id")
X_train <- merge(X_train, temp, by.x ="train_id", by.y ="activity_id")

X_test <- within(X_test, rm(test_id))
X_train <- within(X_train, rm(train_id))

X_test <- mutate(X_test, dataset = "test")
X_train <- mutate(X_train, dataset = "train")

X<- bind_rows(X_train,X_test)

X$id <- rownames(X)

rm(X_train)
rm(X_test)
 
features <- read.csv("./UCI HAR Dataset/features.txt", header = FALSE, sep = "\n")

features <- mutate(features, colnames = as.character(features$V1))


features$colnames <- gsub("^[0-9]+ ", "", features$colnames)

a <- grep("bandsEnergy()", features$colnames)
b<- c(rep("-X",14), rep("-Y",14), rep("-Z", 14))
c <- rep(b,3)
for (i in seq_along(c)) { features$colnames[a[i]] <- paste0(features$colnames[a[i]], c[i])}

features <- mutate(features, colnames = gsub("BodyBody", "Body", colnames))

features <- mutate (features, colnames = gsub("(angle.*gravity).*", "\\1Mean\\)", colnames))
features <- mutate(features, colnames = gsub("(angle).*(t.+)Mean.*,gravityMean.*", "\\2-\\1", colnames))
features <- mutate(features, colnames = gsub("(angle).*([X-Z]).*,gravityMean.*", "\\1-\\2", colnames))

features <- mutate(features, colnames = gsub("^(t|f)?(Body|Gravity)?(Acc|Gyro)?(Jerk)?(Mag)?(?:-)?([a-zA-Z]+)(?:\\(\\))?(?:-)?([0-9]+,[0-9]+)?(?:-)?([X-Z])?(?:-)?([0-9X-Z](?:,)?(?:[0-9X-Z])?)?", 
"\\1:\\2\\3:\\4:\\5:\\6:\\7:\\8:\\9", colnames))

library(stringr)
X$V1 <- str_trim(X$V1)

X <- separate(X, V1, features$colnames, sep = " +")

X <- select(X, id, activity, examinedperson, dataset, contains("mean"), contains ("std"), -contains("meanFreq"))

X <- gather(X, variables, count, -dataset, -examinedperson, -activity, -id)
X <- separate(X, variables, c("domain", "signal", "jerk", "magnitude", "indicator", "frequencyintervals","axis","coefficients"), sep = ":")
X <- spread(X, indicator,count)

X <- select(X, -id, -frequencyintervals, -coefficients)

X <- data.frame(lapply(X, as.character), stringsAsFactors=FALSE)
temp <- data.frame(lapply(X[,9:10], as.numeric))
X[,9:10] <- temp

print("the first dataset is:")
str(X)

X_grouped <- group_by(X, examinedperson, activity, domain, signal, jerk, magnitude, axis)

X_grouped <- select(X_grouped, - dataset)

final <- summarize_all(X_grouped, mean)

print("the second dataset will be presented with View:")
View(final)

write.table(final, file = "./final.txt", row.name=FALSE)




