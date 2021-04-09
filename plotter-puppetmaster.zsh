#!/bin/zsh

# Arguments
amountOfPlotters=$1
intervalInHours=$2

# input validation
if [ -z "$amountOfPlotters" ]; then
	echo "No amount of plotters specifiec"
	exit 1
fi

if [ -z "$intervalInHours" ]; then
	echo "No setup interval specified"
	exit 1
fi

# Settings
minuteInSeconds=60
hourInSeconds=$(( $minuteInSeconds * 60 ))
spawningIntervalInSeconds=$(( $intervalInHours * 10 * $hourInSeconds / 10 )) # Integers only, so 15 / 10 is 1.5


for ((instance=1; instance<=amountOfPlotters; instance++)); do
	
	echo "Setting up instance number $instance"
	cd ./digital-ocean
	pwd
	ip=$( npm run makeplotter | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" )
	echo "Created droplet at $ip"
	cd ..
	pwd

	if [ -z "$ip" ]; then
		echo "No ip found $ip"
	else
		echo "Triggering setup with zsh ./_setup-remote.zsh $ip"
	    zsh ./_setup-remote.zsh $ip
	fi

	# Wait until next
	if [ "$instance" = "$amountOfPlotters" ]; then
    	echo "Setup loop completed $instance setups"
    else
    	echo "Waiting for $spawningIntervalInSeconds seconds until next deploy"
    	sleep $spawningIntervalInSeconds
    fi

done

