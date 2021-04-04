#!/bin/zsh

# variables
goon=true
count=1
instance=$1 # passed by setup script ar argv[0]
source "${0:a:h}/.env"

echo "[ $( date ) ] [ everplot.zsh ] starting everplot" >> $logfile

while [ "$goon" = true ]; do

	# Based on paralellel trigger and serial count
	subpath="/$( date +%Y-%m-%d-%H-%M )-parallel-$1-serial-$count/"

	# Create a plot synchronously
	echo "[ $( date ) ] [ everplot.zsh ] starting plot $count creation" >> $logfile
	zsh "${0:a:h}/plot.zsh" $subpath

	echo "[ $( date ) ] [ everplot.zsh ] uploading plot $count to remote asynchronously" >> $logfile

	if [ -v dryrun ]; then
		echo "[ $( date ) ] [ everplot.zsh ] dry run, skipping upload and waiting 10 seconds" >> $logfile
		sleep 10
	else
		nohup zsh "${0:a:h}/upload.zsh" $subpath & disown
	fi
	

	# Increment plot counter and sleep for a minute
	((count=count+1))
	echo "[ $( date ) ] [ everplot.zsh ] sleeping a minute before creating plot $count" >> $logfile
	sleep 60

done

echo "[ $( date ) ] [ everplot.zsh ] exit everplot" >> $logfile
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Everplot STOPPED&message=Everplot at $myip ended&url=&priority=1" https://api.pushover.net/1/messages.json
