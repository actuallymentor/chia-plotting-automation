#!/bin/zsh
# Load environment variables
source "${0:a:h}/.env"

function handleError() {
	curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia plot failed&message=Plotting $1 at $myip&url=&priority=1" https://api.pushover.net/1/messages.json
	echo "[ $(date) ] [ upload.zsh ] plot error $( caller ) at $plotdir" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# DO not error on no globbing match
setopt +o nomatch

# Get the plotfile
plotfile=$( ls /mnt/volume* | grep -P -m 1 ".plot$" )
echo "[ $( date ) ] [ upload.zsh ] there are $( ls /mnt/volume* | grep -P ".plot$" | wc -l ), choosing $plotfile" >> $logfile

# Trust the remote server and import ssh key
chmod 600 $sshkey
eval `ssh-agent -s` && ssh-keyscan $remoteserver >> ~/.ssh/known_hosts
ssh-add $sshkey

echo "[ $( date ) ] [ upload.zsh ] starting upload of $plotfile" >> $logfile
# Copy without -z compression, -v verbosity, -P progress
rsync -vP $plotdir/$plotfile "$remoteuser@$remoteserver:$remotedownloadfolder"
echo "[ $( date ) ] [ upload.zsh ] completed upload of $plotfile" >> $logfile

# Move the remote file from download folder to farming folder
ssh $remoteuser@$remoteserver "mv $remotedownloadfolder/* $remoteplotfolder"
echo "[ $( date ) ] [ upload.zsh ] completed moving of $plotfile" >> $logfile

# Delete local plotfile
rm $plotdir/$plotfile

# Notify via push noti
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia upload success&message=Plot added at $myip&url=&priority=1" https://api.pushover.net/1/messages.json

echo "[ $( date ) ] [ upload.zsh ] ended upload process of $plotfile" >> $logfile
