The data frames created by run_analysis.R file have the following variables:

The source of data and the details of the experiment including sampling are described in the folowing link:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Variables:

activity:
The values of activity variables are the six activities (walking, walking upstairs, walking downstairs, sitting, standing, laying)
performed by the volunteers of the experiment wearing a smartphone (Samsung Galaxy S II) on their waist with an embedded accelerometer and gyroscope 
measuring 3-axial linear acceleration and 3-axial angular velocity.
 
examinedperson:
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
The values of this variable refer to the identifying numbers of the volunteers. 

dataset:
The obtained dataset has been randomly partitioned into two sets, 
where 70% of the volunteers was selected for generating the training data and 30% the test data.
The values of this variable (test / train) indicate which dataset an observation belongs to. 

domain:
The variable shows if an observation belongs to a time domain signal (indicated with "t"), 
or a frequency domain signal where Fast Fourier Transform (FFT) was applied (indicated with "f"). 

signal:
The variables selected for this database come from the accelerometer and gyroscope 3-axial raw signals (Acc, Gyro).
The acceleration signal was then separated into three-dimensional body and gravity acceleration signals (BodyAcc,GravityAcc).
The value of signal variable show which signal (BodyGyro / BodyAcc / GravityAcc) an observation belongs to. 

jerk:
The body linear acceleration and angular velocity were derived in time to obtain Jerk signals.
The jerk variable shows if the observation belongs to a jerk signal (indicated with "Jerk") or not (indicated with the lack of value).

magnitude:
The magnitude of the different three-dimensional signals were calculated using the Euclidean norm.
The magnitude variable shows if the observation belongs to a magnitude value (indicated with "Mag") or not (indicated with the lack of value).

axis:
"X","Y","Z"" are used to denote 3-axial signals in the X, Y and Z directions.
The axis variable shows if the observation belongs to a signal in one of the directions or none of them (indicated with the lack of value).

mean:
Mean value
Note: in final data frame the values are the average mean of the grouped categories.

std:
Standard deviation
Note: in final data frame the values are the average standard deviation of the grouped categories.
