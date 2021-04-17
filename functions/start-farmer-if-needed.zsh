#!/bin/zsh

source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"

# Activate chia cli
source ~/chia-blockchain/activate

# Check if farm active
if chia farm summary | grep -q 'Connection error'; then

	# Start chia if needed
	echo "Chia is not running, starting"
	pusherror "Chia not running - restarting"
	chia start farmer

	# Hol'up a minnit
	wait 60
else

	# Do nothing and proceed to logging
	echo "Chia is running, taking no action"
fi

# Check stausses
syncStatus=$( chia show -s | grep -Poi "(?<=Current Blockchain Status: ).*(synced|syncing)" | tr '\n' ' ' )
farmSummary=$( chia farm summary )
farmStatus=$( echo $farmSummary | grep -Poi "(?<=Farming status: ).*" )
farmEta=$( echo $farmSummary | grep -Poi "(?<=Expected time to win: ).*" )
farmPlotcount=$( echo $farmSummary | grep -Poi "(?<=Plot count: ).*" )


# Log to console and file
echo "[ $( date ) ] - Node status: $syncStatus"
echo "[ $( date ) ] - Farm status: $farmStatus - eta $farmEta with $farmPlotcount plots"

echo "[ $( date ) ] - Node status: $syncStatus" >> $daemonLog
echo "[ $( date ) ] - Farm status: $farmStatus - eta $farmEta with $farmPlotcount plots" >> $daemonLog
