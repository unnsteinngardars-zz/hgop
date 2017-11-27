#!/bin/bash

#initialize variables
user=$(whoami)
os=$(sw_vers -productName)
startdate=$(date '+%A %d %m %X')
starttime=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')

#greets current user and displays current os
echo "Welcome $user, this script installs all programs/dependencies needed"
echo "Running OS:  $os"
echo "Script started at: $startdate"

#prompts user to continue or not
read -p "Are you sure you want to continue? y/n:"  answer
case "$answer" in
	[yY])
	# runs commands to install homebrew, then installs git and VS code
	echo "Installing programs and dependencies, please be patient, it might take some time"

	#check if VS code is already installed, if so we do not want to execute that installation
	if [ -e /Applications/Visual\ Studio\ Code.app ]
	then
		echo "Installing Homebrew and git, VS code already installed"
		echo "Press enter"
		installDependencies=$(/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brew install git)
	else
		echo "Installing Homebrew, git and VScode"
		echo "Press enter"
		installDependencies=$(/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && brew install git && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null ; brew install caskroom/cask/brew-cask 2> /dev/null && brew cask install visual-studio-code)
	fi
	#fetches the exit code of the last executed command
	errorCode=$?

	#determines if the error code is something else but 0, if so we return an error message and the corresponding error code
	if [ $errorCode  -ne 0 ]
	then
		enddate=$(date '+%A %d %m %X')
		endtime=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')
		totaltime=$(($endtime - $starttime))
		echo >> script-error.log
		echo "Script ended unsuccessfully" >> script-error.log
		echo "Script started: $startdate" >> script-error.log
		echo "Script ended: $enddate" >> script-error.log
		echo "Execution time: $totaltime.ms" >> script-error.log
		echo "Exited with error code $errorCode" >> script-error.log
		echo "Information logged to file script-error.log"
		exit $errorCode
	fi
	#if all is good, we finish the execution by logging and exiting

	enddate=$(date '+%A %d %m %X')
	endtime=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')
	totaltime=$(($endtime - $starttime))
	echo >> scriptlog.log
	echo "Script finished successfully" >> scriptlog.log
	echo "Script started: $startdate" >> scriptlog.log
	echo "Script ended: $enddate"  >> scriptlog.log
	echo "Execution time: $totaltime.ms" >> scriptlog.log
	echo "Exited with error code $errorCode" >> scriptlog.log
	echo "information logged to file scriptlog.log"
	exit 0
	;;
	*)
	# is user entered no or something else we abort and display stats

	enddate=$(date '+%A %d %m %X')
	endtime=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')
	totaltime=$(($endtime - $starttime))
	echo "Script aborted"
	echo "Script started: $startdate"
	echo "Script ended: $enddate"
	echo "Execution time: $totaltime.ms"
	exit 0
esac
