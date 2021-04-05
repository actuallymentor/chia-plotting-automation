#!/bin/zsh

# Load environment variables
source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"
subpath=$1

function handleError() {
	push "Chia plot failed"
	echo "[ $(date) ] [ plot.zsh ] - Plot error $LINENO $( caller ) at $subpath" >> $logfile
	exit 1
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# DO not error on no globbing match
setopt +o nomatch

# Activate chia
. $HOME/chia-blockchain/activate 

# Performance settings
restMBAfter512MBRemoved=$( echo $(( $(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) - $overheadInMB )) )
restMiBAfter512MBRemoved=$(( $restMBAfter512MBRemoved * 1000 / 1049 ))
threads=$( getconf _NPROCESSORS_ONLN )
memorybuffer=$( echo $restMiBAfter512MBRemoved ) # in MiBs, 4608 is default which is 4832 MB which is 4.84 GB
ksize=32

echo "[ $(date) ] [ plot.zsh ] Starting Chia plotting with $(( $threads / $parallel )) threads / $(( $memorybuffer / $parallel )) MiB RAM" >> $logfile

# Create relevant directory
echo "[ $(date) ] [ plot.zsh ] creating tempdir $tempdir$subpath" >> $logfile
mkdir -p $tempdir$subpath
echo "[ $(date) ] [ plot.zsh ] creating tempdir $plotdir$subpath" >> $logfile
mkdir -p $plotdir$subpath

if [ -v dryrun ]; then

	# Create dummy chia files
	echo "[ $( date ) ] [ plot.zsh ] dry run, making dummy files" >> $logfile
	echo "A temp file" >> "$tempdir/$subpath$( date ).plot.temp"
	echo "A plot file" >> "$plotdir/$subpath$( date ).plot"

else

	# Create chia plot
	echo "[ $(date) ] [ plot.zsh ] running with: chia plots create -e \
		-b $(( $memorybuffer / $parallel )) \
		-r $(( $threads / $parallel )) \
		-k $ksize -n $amountofplots \
		-d $plotdir$subpath -t $tempdir$subpath \
		-f $publicfarmerkey -p $publicchiakey -p $poolfarmerkey >> $plotlog" >> $logfile

	chia plots create -e \
		-b $(( $memorybuffer / $parallel )) \
		-r $(( $threads / $parallel )) \
		-k $ksize -n $amountofplots \
		-d $plotdir$subpath -t $tempdir$subpath \
		-f $publicfarmerkey -p $publicchiakey -p $poolfarmerkey >> $plotlog

fi

echo "[ $(date) ] [ plot.zsh ] Removing tempfiles at $tempdir$subpath" >> $logfile

rm -rf "$tempdir$subpath" || echo "[ $(date) ] [ plot.zsh ] - No temporary files" >> $logfile 

echo "[ $(date) ] [ plot.zsh ] Done creating Chia plot at $plotdir$subpath" >> $logfile
