#!/bin/zsh
# Load environment variables
source "${0:a:h}/../.env"
source "${0:a:h}/push.zsh"

# Arguments to this script
subpath=$1
remoteuserOverride=$2
ipOverride=$3
sshPortOverride=$4
plotFolderOverride=$5
downloadFolderOverride=$6


# Change things based on arguments
if [ -n "$downloadFolderOverride" ]; then
	echo "Override download folder $remotedownloadfolder to $downloadFolderOverride"
	remotedownloadfolder=$downloadFolderOverride
fi
if [ -n "$plotFolderOverride" ]; then
	echo "Override plot folder $remotedownloadfolder to $plotFolderOverride"
	remoteplotfolder=$plotFolderOverride
fi
if [ -n "$ipOverride" ]; then
	echo "Override ip $remoteserver to $ipOverride"
	remoteserver=$ipOverride
fi
if [ -n "$remoteuserOverride" ]; then
	echo "Override user $remoteuser to $remoteuserOverride"
	remoteuser=$remoteuserOverride
fi
if [ -n "$sshPortOverride" ]; then
	echo "Override ssh port $sshport to $sshPortOverride"
	sshport=$sshPortOverride
fi

function handleError() {
	pusherror "Chia plot failed"
	echo "[ $(date) ] [ upload.zsh ] upload error $LINENO at $plotdir$subpath" >> $logfile
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
echo "[ $( date ) ] [ upload.zsh ] scanning for keys on $remoteuser@$remoteserver:$sshport" >> $logfile
chmod 600 $sshkey
eval `ssh-agent -s` && ssh-keyscan -p $sshport $remoteserver >> ~/.ssh/known_hosts
ssh-add $sshkey

echo "[ $( date ) ] [ upload.zsh ] starting upload of $plotfile to $remotedownloadfolder" >> $logfile
# Copy without -z compression, -v verbosity, -P progress
rsync -e "ssh -p $sshport" -vP $plotdir$subpath/$plotfile "$remoteuser@$remoteserver:$remotedownloadfolder"
echo "[ $( date ) ] [ upload.zsh ] completed upload of $plotfile" >> $logfile

# Move the remote file from download folder to farming folder
echo "[ $( date ) ] [ upload.zsh ] completed mv $remotedownloadfolder/$plotfile $remoteplotfolder/$plotfile" >> $logfile
ssh $remoteuser@$remoteserver -p $sshport "mv $remotedownloadfolder/$plotfile $remoteplotfolder/$plotfile"
echo "[ $( date ) ] [ upload.zsh ] completed moving of $plotfile to $remotedownloadfolder" >> $logfile

# Delete local plotfile
echo "[ $( date ) ] [ upload.zsh ] deleting $plotdir$subpath" >> $logfile
rm -rf $plotdir$subpath

# Notify via push noti
push "Chia upload success"

echo "[ $( date ) ] [ upload.zsh ] ended upload process of $plotfile" >> $logfile
