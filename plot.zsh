#!/bin/zsh

# Load environment variables
source "${0:a:h}/.env"

function handleError() {
	curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia plot failed&message=Plotting $1 at $myip&url=&priority=1" https://api.pushover.net/1/messages.json
	echo "[ $(date) ] [ plot.zsh ] - Plot error $1 at $plotdir" >> $logfile
	exit 1
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError EXIT TERM INT

# DO not error on no globbing match
setopt +o nomatch

# Activate chia
. $HOME/chia-blockchain/activate 

# Performance settings
restMBAfter512MBRemoved=$( echo $(( $(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) - 512 )) )
restMiBAfter512MBRemoved=$(( $restMBAfter512MBRemoved * 1000 / 1049 ))
threads=$( getconf _NPROCESSORS_ONLN )
memorybuffer=$( echo $restMiBAfter512MBRemoved ) # in MiBs, 4608 is default which is 4832 MB which is 4.84 GB
ksize=32

echo "[ $(date) ] [ plot.zsh ] Starting Chia plotting with $threads threads / $memorybuffer MiB RAM" >> $logfile

if [ -v dryrun ]; then

	# Create dummy chia files
	echo "[ $( date ) ] [ plot.zsh ] dry run, making dummy files" >> $logfile
	echo "A temp file" >> "$tempdir/$( date ).plot.temp"
	echo "A plot file" >> "$plotdir/$( date ).plot"

else

	# Create chia plot
	chia plots create -e -b $memorybuffer -r $threads -k $ksize \
		-n $amountofplots -d $plotdir -t $tempdir \
		-f $publicfarmerkey -p $publicchiakey -p $poolfarmerkey >> $plotlog

fi

echo "[ $(date) ] [ plot.zsh ] Removing $( l $tempdir/*.tmp | wc -l ) tempfiles" >> $logfile

rm -f "$tempdir/*.tmp" || echo "[ $(date) ] [ plot.zsh ] - No temporary files" >> $logfile 

echo "[ $(date) ] [ plot.zsh ] Done creating Chia plot at $plotdir" >> $logfile
