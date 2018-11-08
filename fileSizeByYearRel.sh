#!/bin/bash
# ls -la: $5 is the file size $6 is the month, $7 is the day, 
# $8 is the year or the time if it's the current year
# $1 is the parameter passed in from the command line outside of AWK

#This output is done here so that we have easy access to the folder that is being searched
directoryToBeSearched=$1
echo "---------------------------------------------------------"
echo "Total Disk Quota Used Per Year for "$directoryToBeSearched
ls -la $(find $1 -type f) |
	awk 'BEGIN {    
			#Initialise variables and print out headings
			print "---------------------------------------------------------"
			#Get the current year
			currentYear = strftime("%Y")
			
			#Set the first row of the array as the current year
			filesTotalSizeByYear[0][1] = currentYear
			filesTotalSizeByYear[0][2] = 0


			tempArrIndexCounter = 0		
			constArrayRowTracker = 1
			
		   } 
		   
		   {
			#Check to see if the file is from this year
			if (match($8,":") || ($8==currentYear))
			{
				#Add this file size to the current year
				filesTotalSizeByYear[0][2]+=$5
			}
			else
			{
				#Need to check if there is already an entry for the year in the array
				#If not, then add that year as a new entry to the array
				#if there is already an entry then just add that file size to that total

				tempArrIndexCounter = 0     #Tracks where we are up to in the array
				foundYearFlag = 0       #If this is not switched to true, then we need to add a new item for our array

				# Go through each row of the array
				for (x in filesTotalSizeByYear)
				{
					if ((filesTotalSizeByYear[tempArrIndexCounter][1]==$8) && (foundYearFlag == 0))
						{
							#Found the year and that we have not triggered finding the year in the array
							filesTotalSizeByYear[tempArrIndexCounter][2]+=$5
							foundYearFlag = 1 #Setting the foundYearFlag to true so that we do not accidentally go in here again for this parse
							
						}
						
					#Increase the counter for the array Position
					tempArrIndexCounter++
					
				}
				if (foundYearFlag == 0)
					{
						#Need to add a new entry for the year because it is not in the array
						filesTotalSizeByYear[constArrayRowTracker][1] = $8
						filesTotalSizeByYear[constArrayRowTracker][2] = $5
						constArrayRowTracker++  #Move the position of the Array Tracker
					}
			}
			   
		   }
		   
		   END {
		 	for (tempCounterForArray=0; tempCounterForArray < constArrayRowTracker; tempCounterForArray++) 
				{
				#Print out the results
				print "In "filesTotalSizeByYear[tempCounterForArray][1] " this amount of disk quota was used: " filesTotalSizeByYear[tempCounterForArray][2]/1000 " KB\n"
				
			}
				}'

