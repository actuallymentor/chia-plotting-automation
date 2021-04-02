#!/bin/zsh

# variables
goon=true
count=1
source "${0:a:h}/.env"

echo "[ $( date ) ] starting everplot" >> $logfile

while [ "$goon" = true ]; do

	# Create a plot synchronously
	echo "[ $( date ) ] starting plot $count creation" >> $logfile
	zsh "${0:a:h}/plot.zsh"

	echo "[ $( date ) ] uploading plot $count to remote asynchronously" >> $logfile

	if [ -z "$dryrun" ]; then
		echo "[ $( date ) ] dry run, skipping upload and waiting 10 seconds" >> $logfile
		sleep 10
	else
		nohup zsh "${0:a:h}/upload.zsh" & disown
	fi
	

	# Increment plot counter and sleep for a minute
	((count=count+1))
	echo "[ $( date ) ] sleeping a minute before creating plot $count" >> $logfile
	sleep 60

done

echo "[ $( date ) ] exit everplot" >> $logfile
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Everplot STOPPED&message=Everplot at $myip ended&url=&priority=1" https://api.pushover.net/1/messages.json
