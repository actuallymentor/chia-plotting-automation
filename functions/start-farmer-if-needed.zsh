#!/bin/zsh

source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"

# Activate chia cli
cd ~/chia-blockchain/
git pull
source ./activate

# Check if farm active
if chia farm summary | grep -q 'Connection error'; then

	# Start chia if needed
	echo "[ $( date ) ] - ⚠️ Chia offline - restarting"
	echo "[ $( date ) ] - ⚠️ Chia offline - restarting" >> $daemonLog
	pusherror "Chia not running - restarting"
	
	chia start farmer

else

	# Do nothing and proceed to logging
	echo "Chia is running, no restart needed"
fi

# Check stausses
chiaShow=$( chia show -s )
syncStatus=$( echo $chiaShow | grep -Poi "(?<=Current Blockchain Status: ).*(synced|syncing)" | tr '\n' ' ' )
farmSummary=$( chia farm summary )
farmStatus=$( echo $farmSummary | grep -Poi "(?<=Farming status: ).*" )
farmEta=$( echo $farmSummary | grep -Poi "(?<=Expected time to win: ).*" )
farmPlotcount=$( echo $farmSummary | grep -Poi "(?<=Plot count: ).*" )


# Log to console and file
echo "[ $( date ) ] - Node status: $syncStatus"
echo "[ $( date ) ] - Node status: $syncStatus" >> $daemonLog
echo "[ $( date ) ] - Farm status: $farmStatus - eta $farmEta with $farmPlotcount plots"
echo "[ $( date ) ] - Farm status: $farmStatus - eta $farmEta with $farmPlotcount plots" >> $daemonLog

# Visual log in case of manual calling
echo -e "\n---------------\nBlockchain\n---------------\n"
echo $chiaShow | grep --colour=never -Po "[A-Z]{1}.*$"
echo -e "\n---------------\nFarm\n---------------\n"
echo $farmSummary
echo -e "\n"
