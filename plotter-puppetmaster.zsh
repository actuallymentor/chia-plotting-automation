#!/bin/zsh

# Arguments
amountOfPlotters=$1

# Settings
minuteInSeconds=60
hourInSeconds=$(( $minuteInSeconds * 60 ))
spwaningIntervalInSeconds=$(( 15 * $hourInSeconds / 10 )) # Integers only, so 15 / 10 is 1.5

for ((instance=1; instance<=amountOfPlotters; instance++)); do
	
	echo "Setting up instance number $instance"
	cd ./digital-ocean
	ip=$( npm run makeplotter | grep "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" )
	echo "Created droplet at $ip"
	cd ..

	if [ -z "$ip" ]; then
		echo "No ip found $ip"
	else
	    zsh ./_setup-remote.zsh $ip
	fi

	# Throttle in case there is a problem that causes insta-continue
    sleep 10

done

