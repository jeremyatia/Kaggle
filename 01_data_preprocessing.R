#####################################################################
# Authors : Stephane FENIAR & Jeremy ATIA - Team "Fast & Curious"   #						
# Date 	  : March 2015					 	    #		
# Title   : Kaggle Axa Drivers Challenge		            #		
# Info 	  : Data preprocessing 					    #		
#####################################################################

# Global options 
options(scipen=999)
setwd('C:/Users/Documents/Kaggle/Axa Driver/Input/') # change this path with your data folder

Drivers <- as.numeric(list.files(path = "drivers/")) 
NB_DRIVERS <- length(Drivers)
NB_TRIPS <- 200

# For a specific driver, recover the data of his 200 trips and summarize each of them by 29 features. 
# Output: matrix(nrow=200, ncol=29) 
#--------------------------------------------------------------------------------------------------------------#
Summary_Driver_Trips <- function(driver) {

	driver_files <- list.files(path = paste("./drivers/",driver,sep="")) # recover the names of the csv files
  	summary <- matrix(nrow=200, ncol=29) # initialize the matrix which will store the summary of the 200 trips
  	t=1 # trip counter (from 1 to 200)
  
	for (file in driver_files){ # for each csv file in each driver folder
    		#Recover trip data
		coord <- as.matrix(read.csv(paste("./drivers/",driver,"/", file, sep=""))) # x & y coordinates
		trip  <- as.numeric(strsplit(file,"[.]")[[1]][1])
    
    		#Create some variables for each record of the trip
		time = 1:nrow(coord)
		dist_to_origin = sqrt(coord[,1]^2 + coord[,2]^2)
		speed = 0 ; speed[2:nrow(coord)] = sqrt(diff(coord[,1],1)^2 + diff(coord[,2],1)^2)
		acc = 0 ; acc[2:nrow(coord)] = diff(speed,1)
		acc_flag = ifelse(acc>1.5, 1, 0) # flag for important accelerations
		dec_flag = ifelse(acc< -2, 1, 0) # flag for important decelerations
    
		#Aggregation at the trip level
    
		#Speed      
		avg_speed=mean(speed); sd_speed=sd(speed); min_speed=min(speed); max_speed=max(speed)
		q1_speed=quantile(speed, probs = 0.25)
		q2_speed=quantile(speed, probs = 0.50)
		q3_speed=quantile(speed, probs = 0.75)
		#Acceleration
		avg_acc=mean(acc); sd_acc=sd(acc); min_acc=min(acc); max_acc=max(acc)
		q1_acc=quantile(acc, probs = 0.25)
		q2_acc=quantile(acc, probs = 0.50)
		q3_acc=quantile(acc, probs = 0.75)
		#Distance to origin
		avg_dist_to_orig=mean(dist_to_origin); sd_dist_to_orig=sd(dist_to_origin); max_dist_to_orig=max(dist_to_origin)
		q1_dist_to_orig=quantile(dist_to_origin, probs = 0.25)
		q2_dist_to_orig=quantile(dist_to_origin, probs = 0.50)
		q3_dist_to_orig=quantile(dist_to_origin, probs = 0.75)
		#Others
		trip_duration=max(time)
		crow_flight=sqrt(coord[nrow(coord), 1]^2 + coord[nrow(coord), 2]^2)
		acc_time=sum(acc_flag)
		dec_time=sum(dec_flag)
		trip_length = trip_duration * avg_speed
		crow_ratio = crow_flight / trip_length
		is_internal = 1 # for now we assume all the trips have been done by this driver
    
		summary[t,]= cbind(driver, trip, 
                    		avg_speed, sd_speed, min_speed, max_speed, q1_speed, q2_speed, q3_speed, #speed features
		                avg_acc, sd_acc, min_acc, max_acc, q1_acc, q2_acc, q3_acc, #acc features
		                avg_dist_to_orig, sd_dist_to_orig, max_dist_to_orig, q1_dist_to_orig, q2_dist_to_orig, q3_dist_to_orig, #distance to origin features
		                acc_time, dec_time, trip_duration, crow_flight, trip_length, crow_ratio, is_internal) #others features
    				t=t+1 # increment the trip counter
	}
	return(summary) 
}


# Apply the "Summary_Driver_Trips" function too all the drivers and store the result in "DriversTripsSummary" 
#---------------------------------------------------------------------------------------------------------------#
DriversTripsSummary = matrix(nrow=NB_DRIVERS * NB_TRIPS, ncol=29)
colnames(GlobalTripsSummary) =  c('driver', 'trip', 'avg_speed', 'sd_speed', 'min_speed', 'max_speed', 'q1_speed', 'q2_speed', 'q3_speed',
                       		'avg_acc', 'sd_acc', 'min_acc', 'max_acc', 'q1_acc', 'q2_acc', 'q3_acc',
                       		'avg_dist_to_orig', 'sd_dist_to_orig', 'max_dist_to_orig', 'q1_dist_to_orig', 'q2_dist_to_orig', 'q3_dist_to_orig',
                       		'acc_time', 'dec_time', 'trip_duration', 'crow_flight', 'trip_length', 'crow_ratio', 'is_internal')

d=1 # driver counter

for(driver in Drivers){ 
	driverTripsSummary= summary_driver_trips(driver)
	GlobalTripsSummary[seq((d-1)*NB_TRIPS+1, d*NB_TRIPS),] = driverTripsSummary
	d=d+1 
}

# Save the result in a csv file 
#----------------------------------------------------------------------------------------------------------------#
write.csv(GlobalTripsSummary, 'GlobalTripsSummary.csv', row.names=FALSE)
