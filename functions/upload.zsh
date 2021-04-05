#!/bin/zsh
# Load environment variables
source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"
subpath=$1

function handleError() {
	push "Chia plot failed"
	echo "[ $(date) ] [ upload.zsh ] plot error $( caller ) at $plotdir$subpath" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# DO not error on no globbing match
setopt +o nomatch

# Get the plotfile
plotfile=$( ls $plotdir$subpath | grep -P -m 1 ".plot$" )
echo "[ $( date ) ] [ upload.zsh ] there are $( ls $plotdir$subpath | grep -P ".plot$" | wc -l ) plots, choosing $plotfile" >> $logfile

# Trust the remote server and import ssh key
chmod 600 $sshkey
eval `ssh-agent -s` && ssh-keyscan $remoteserver >> ~/.ssh/known_hosts
ssh-add $sshkey

echo "[ $( date ) ] [ upload.zsh ] starting upload of $plotfile" >> $logfile
# Copy without -z compression, -v verbosity, -P progress
rsync -e "ssh -p $sshport" -vP $plotdir$subpath/$plotfile "$remoteuser@$remoteserver:$remotedownloadfolder"
echo "[ $( date ) ] [ upload.zsh ] completed upload of $plotfile" >> $logfile

# Move the remote file from download folder to farming folder
ssh $remoteuser@$remoteserver "mv $remotedownloadfolder/* $remoteplotfolder"
echo "[ $( date ) ] [ upload.zsh ] completed moving of $plotfile" >> $logfile

# Delete local plotfile
echo "[ $( date ) ] [ upload.zsh ] deleting $plotdir$subpath" >> $logfile
rm -rf $plotdir$subpath

# Notify via push noti
push "Chia upload success"

echo "[ $( date ) ] [ upload.zsh ] ended upload process of $plotfile" >> $logfile
