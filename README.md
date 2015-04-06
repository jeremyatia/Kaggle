# Kaggle: Driver Telematics Analysis

You can find the challenge on the following link : https://www.kaggle.com/c/axa-driver-telematics-analysis

Here is the methodology we use in order to solve the following problem: 

Determine who is driving the car in a set of trips.

## Data preprocessing 

When you download the data you get a tons of csv files (~2700 drivers x 200 trips = 540 000)

Each file represents a trip for a driver where we have his position (x,y) **every second**.

So in each file we have 2 variables: 
the x & y position, 

and between 100 and 2000 rows approximately (corresponding to the **trip length**) 

### Methodology: 

The first goal is to **aggregate** the data and create a **global dataset** in order to run the statistical models:

1. Aggregate a trip (between in 100 and 2000 rows) in 1 row adding different variables as : 
  1. The speed (distance - thanks to the position / time – number of rows) with the quantiles, mean and standard deviation.
  2. The acceleration
  3. The distance to the origin (the quantiles, mean and standard deviation)
  4. The trip duration
  5. The trip length = trip duration * average speed
  6. The number of important acceleration/deceleration
  7. A crow ratio  = crow flight / trip length
  8. (We wanted to go further using **pattern recognition** to identify the similarities between the trips) 

All these variables are computed in order to feel – as far as we can - the comportment of each driver.

If we assume we have 1000 rows by csv file, it means we have summarized 540 000 000 rows in 540 000 rows.

## Data modelization:  

### Objective 

Random Forest model which determines for each individual trip if he is driving the car (1) or not (0). 

Here is a **pseudo – code** of the implemented algorithm : 

1. For each individual 
  1. Take the 200 trips and define them as **1**.
  2. Add 600 trips (taken randomly from the other individuals) and define them as **0**.
  3. Run random forest model on 800 trips (train set)
  4. Apply random forest on the 200 initial trips (test set)
  5. Save the rows numbers where the trips are identified as 0 (with their frequencies, because we run it a few times)
  6. Take again 600 external trips (taken randomly)
  7. And come back to 1.iii and do it 50 times.

2. At the end of the 50 times we get the frequencies where the 200 trips are identified as 0.
3. If this number is greater than (50/2)+1 (the majority) then this trip is external (= 0).
4. So we obtain a vector of length 200 where there is x number of 0 and y number of 1. *Remember, at the beginning all the 200 trips were identified as 1*.
5. We come back to 1.i and we iterate this 5 times in order to initialize the 200 trips as precise as we can.

## Result:

**292**nd out of **1528** => **top 20%**

