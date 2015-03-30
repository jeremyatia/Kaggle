# Kaggle: Driver Telematics Analysis

You can find the challenge on the following link : https://www.kaggle.com/c/axa-driver-telematics-analysis
Here is the methodology we use in order to solve the following problem: 
Determine who is driving the car in a set of trips.
Data preprocessing 
When you download the data you get a tons of csv files (~2700 drivers x 200 trips = 540 000)
Each file represents a trip for a driver where we have his position (x,y) every second.
So in each file we have 2 variables: 
the x & y position, 
and between 100 and 2000 rows approximately (corresponding to the trip length) 
Methodology: 
The first goal is to aggregate the data and create a global dataset in order to run the statistical models:
1.	Aggregate a trip (between in 100 and 2000 rows) in 1 row adding different variables as : 
a.	The speed (distance - thanks to the position / time – number of rows) with the quantiles, mean and standard deviation.
b.	The acceleration
c.	The distance to the origin (the quantiles, mean and standard deviation)
d.	The trip duration
e.	The trip length = trip duration * average speed
f.	The number of important acceleration/deceleration
g.	A crow ratio  = crow flight / trip length
h.	(We wanted to go further using pattern recognition to identify the similarities between the trips) 
All these variables are computed in order to feel – as far as we can - the comportment of each driver.
If we assume we have 1000 rows by csv file, it means we have summarized 540 000 000 rows in 540 000 rows.




Data modelization:  

Objective 
Random Forest model which determines for each individual trip if he is driving the car (1) or not (0). 
Here is a pseudo – code of the implemented algorithm  
1.	For each individual 
a.	Take the 200 trips and define them as 1.
b.	Add 600 trips (taken randomly from the other individuals) and define them as 0.
c.	Run random forest model on 800 trips (train set)
d.	Apply random forest on the 200 initial trips (test set)
e.	Save the rows numbers where the trips are identified as 0 (with their frequencies, because we run it a few times)
f.	Take again 600 external trips (taken randomly)
g.	And come back to c. and do it 50 times.
2.	At the end of the 50 times we get the frequencies where the 200 trips are identified as 0.
3. If this number is greater than (50/2)+1 (the majority) then this trip is external (= 0).
4. So we obtain a vector of length 200 where there is x number of 0 and y number of 1. (remember, at the beginning all the 200 trips were identified as 1).
5. We come back to 1.a and we iterate this 5 times in order to initialize the 200 trips as precise as we can.

Result:

292nd/1528

