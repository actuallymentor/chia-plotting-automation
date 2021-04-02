#!/bin/zsh

# Load environment variables
source "${0:a:h}/.env"

# Activate chia
. ~/chia-blockchain/activate && \

# Performance settings
restMBAfter512MBRemoved=$( echo $(( $(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) - 512 )) )
restMiBAfter512MBRemoved=$(( $restMBAfter512MBRemoved * 1000 / 1049 ))
threads=$( getconf _NPROCESSORS_ONLN )
memorybuffer=$( echo $restMiBAfter512MBRemoved ) # in MiBs, 4608 is default which is 4832 MB which is 4.84 GB
ksize=32

echo "[ $(date) ] - Starting Chia plotting with $threads threads / $memorybuffer MiB RAM" >> $logfile

chia plots create -e -b $memorybuffer -r $threads -k $ksize -n $amountofplots -d $plotdir -t $tempdir -f $publicfarmerkey -p $publicchiakey -p $poolfarmerkey >> $plotlog && \
rm "$tempdir/*.tmp" || echo "[ $(date) ] - No temporary files" >> $logfile && \

echo "[ $(date) ] - Done creating Chia plot at $plotdir" >> $logfile || \

echo "[ $(date) ] - Plot error $plotdir" >> $logfile && \
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia plot failed&message=Plotting error at $myip&url=&priority=1" https://api.pushover.net/1/messages.json