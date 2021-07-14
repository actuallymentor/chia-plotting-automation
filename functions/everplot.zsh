#!/bin/zsh

# variables
goon=true
count=1
instance=$1 # passed by setup script ar argv[0]
source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"

echo "[ $( date ) ] [ everplot.zsh ] starting everplot" >> $logfile
source "${0:a:h}/validate.zsh"

## ###############
## Plotting loop
## ###############
while [ "$goon" = true ]; do

	# Start time
	start=$( date +%s )

	# Based on paralellel trigger and serial count
	subpath="/$( date +%Y-%m-%d-%H-%M )-parallel-$instance-serial-$count/"

	# Create a plot synchronously
	echo "[ $( date ) ] [ everplot.zsh ] starting plot $count creation" >> $logfile
	echo "[ $( date ) ] [ everplot.zsh ] volume usage at start: $( df -h $plotdir | grep /dev )" >> $logfile
	zsh "${0:a:h}/plot.zsh" $subpath
	echo "[ $( date ) ] [ everplot.zsh ] volume usage at completion: $( df -h $plotdir | grep /dev )" >> $logfile

	# End time timestamp
	end=$( date +%s )
	plotDurationInSeconds=$(( end - start ))
	plotDurationInHM=$( date -d@$plotDurationInSeconds -u +%H:%M )
	echo "[ $( date ) ] [ everplot.zsh ] plotting took $plotDurationInHM" >> $logfile

	echo "[ $( date ) ] [ everplot.zsh ] uploading plot $count to remote asynchronously" >> $logfile

	if [ -v dryrun ]; then
		echo "[ $( date ) ] [ everplot.zsh ] dry run, skipping upload and waiting 10 seconds" >> $logfile
		sleep 10
	else
		nohup zsh "${0:a:h}/upload.zsh" $subpath $plotDurationInHM & disown
	fi
	

	# Increment plot counter and sleep for a minute
	((count=count+1))
	echo "[ $( date ) ] [ everplot.zsh ] sleeping a minute before creating plot $count" >> $logfile
	sleep "${plotTimeoutInSeconds:-60}"

done

echo "[ $( date ) ] [ everplot.zsh ] exit everplot" >> $logfile
push "Everplot stopped"