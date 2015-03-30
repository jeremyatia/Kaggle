#########################################################################
# Authors : Stephane FENIAR & Jeremy ATIA - Team "Fast & Curious"	#
# Date 	  : March 2015							#
# Title   : Kaggle Axa Drivers Challenge				#
# Info    : Data modelisation						#
#########################################################################

# require the following packages 
if(!require("dplyr")){
	install.packages("dplyr")
	require("dplyr")
}
if(!require("randomForest")){
	install.packages("randomForest")
	require("randomForest")
}

# global parameters
NbDrivers = 2736
NbTrips = 200

# global options 
options(scipen=999)
setwd('C:/Users/Documents/Kaggle/Axa Driver/Input/') # your data folder

GlobalTripsSummary = read.table('GlobalTripsSummary.csv', sep=',' , header = TRUE, stringsAsFactors=FALSE)
GlobalTripsSummary  = GlobalTripsSummary [order(GlobalTripsSummary$driver, GlobalTripsSummary$trip),]


#get the trips of a driver and add "NbExternalTrips" external trips to build the train set
CreateTrain = function(driver, NbExternalTrips){
	InternalTrips = GlobalTripsSummary[which(GlobalTripsSummary[,'driver']==driver), ]
	ExternalTrips = GlobalTripsSummary[sample(which(GlobalTripsSummary[,'driver']!=driver), size = NbExternalTrips), ]
	ExternalTrips[,'is_internal'] = 0
	Train = rbind(InternalTrips, ExternalTrips)
	return(Train)
}


# Recursive modelisation
ComputeProbability = function(Train){

	rf = randomForest(as.factor(is_internal) ~ avg_speed + sd_speed + max_speed + q1_speed + q2_speed + q3_speed 
                      + avg_dist_to_orig  + sd_dist_to_orig + max_dist_to_orig + q1_dist_to_orig + q2_dist_to_orig + q3_dist_to_orig
                      + acc_time + dec_time + avg_acc + sd_acc + min_acc + max_acc + q1_acc + q2_acc + q3_acc + trip_duration 
                      + crow_flight + trip_length + crow_ratio , ntree = 50, nodesize=5, importance = TRUE,  data=Train)
	predictions = predict(rf, Train[1:200, ], type = "prob")[,2]
	return(predictions)
}

driver_trip = paste(GlobalTripsSummary$driver, '_', GlobalTripsSummary$trip, sep = '')

CreateSubmission = function(NbExternalTrips, NbRecursion, NbTrain){
	prob_int = numeric(200)
	prob_final = numeric(200 * NbDrivers)
	## creation of a matrix where each vector is the probability of the train set 
	prob_Trains=matrix(data=NA, nrow=NbTrips, ncol=NbTrain)
  
	i=1 # driver's count, which alternative
  
	for (driver in Drivers){
		print(i)
		for (j in 1:NbRecursion){
			for (train in 1:NbTrain){
				Train = CreateTrain(driver, NbExternalTrips)
				prob_Trains[,train]=ComputeProbability(Train)
			}
			prob_int=apply(X=prob_Trains, MARGIN=1, median)
			new_is_internal=ifelse(prob_int>=0.5,1,0)
			GlobalTripsSummary[seq((i-1)*200+1, i*200 ),"is_internal"]=new_is_internal
		}
		prob_final[seq((i-1)*200+1, i*200 )]=prob_int
		i=i+1  
	} 
	submission = cbind(driver_trip, prob_final)
	write.csv(submission, 'submission.csv', row.names=F, quote=F)
}

CreateSubmission(NbExternalTrips = 600, NbRecursion = 5, NbTrain= 50)


submission = read.table('submission.csv', sep=',' , header = TRUE, stringsAsFactors=FALSE)
submission = cbind(driver_trip, submission$prob_final)

write.csv(submission, 'submission.csv', row.names=F, quote=F)
