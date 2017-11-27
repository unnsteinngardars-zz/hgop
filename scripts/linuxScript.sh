#!/bin/bash
#script that install dependancies

#Time variabe to measure script running time
startTime=$(date +%s)

#User and system inforamation assigned to variables
user=$(whoami)
system=$(lsb_release -d -s)

#Greeting user with OS information
echo Welcome $user ! This script file installs programs and dependancies. Your OS system is $system. 
#Asking user for permission
echo Are you sure you want to continue ? Answer Y/N 
read answer

if [[ $answer == "Y" || $answer == "y" ]]
then
	#Displaying time before installation begins
	startDate=$(date +"%D %T")
	echo Start date and time: $startDate
	
	echo Now installing Git and VS Code
	sleep 2
	
	#Installation commands
	sudo apt-get update -y  && sudo apt-get install git -y && sudo apt-get install curl -y && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' && sudo apt-get update -y && sudo apt-get install code -y 
	
	#If errorCode not equal to zero, abort and write to error log file
	errorCode=$?
	if [ $errorCode -ne 0 ]
	then
		#Time variables for measuring execution time
		endTime=$(date +%s)
		totalTime=$(($endTime - $startTime))
		#Log information
		echo Script ended unsuccessfully >> script-error.log
		echo Script started: $startTime >> script-error.log
		echo Script ended: $endTime >> script-error.log
		echo Execution time: $totalTime seconds >> script-error.log
		echo Exited with error code $errorCode >> script-error.log
		echo --- Script ended unsuccessfully! ---
		echo Information logged to file script-error.log
		exit $errorCode
	fi
	
        endTime=$(date +%s)
        totalTime=$(($endTime - $startTime))

	echo >> scriptlog.log
	echo Script finished successfully >> scriptlog.log
	echo Script started: $startTime >> scriptlog.log
	echo Script ended: $endTime  >> scriptlog.log
	echo Execution time: $totalTime seconds >> scriptlog.log
	echo Exited with error code $errorCode >> scriptlog.log
	echo --- Script finished successfully ---
	echo Information logged to file scriptlog.log
	exit 0
else
	echo Script aborted!
	exit 0
	
fi
