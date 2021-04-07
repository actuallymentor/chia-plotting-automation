#!/bin/zsh

# Arguments
amountOfPlotters=$1

# Settings
minuteInSeconds=60
hourInSeconds=$(( $minuteInSeconds * 60 ))
spwaningIntervalInSeconds=$(( 15 * $hourInSeconds / 10 )) # Integers only, so 15 / 10 is 1.5

for ((instance=1; instance<=amountOfPlotters; instance++)); do
	
	echo "Setting up instance number $instance"
	ip=$( cd ./digital-ocean && npm run makeplotter | sed "s/Plotter ip address: //" )
	echo "Created droplet at $ip"
    zsh ./_setup-remote.zsh $ip
    sleep 10

done

