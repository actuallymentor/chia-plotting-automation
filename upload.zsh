source "${0:a:h}/.env" && \
plotfile=$( ls /mnt/volume* | grep plot ) && \

# Trust the remote server and import ssh key
chmod 600 $sshkey && \
eval `ssh-agent -s` && ssh-keyscan $remoteserver >> ~/.ssh/known_hosts && \
ssh-add $sshkey && \

echo "[ $( date ) ] Starting upload" >> ~/chia.download.log && \
# Copy with -z compression, -v verbosity, -P progress
rsync -zvP $plotdir/$plotfile "$remoteuser@$remoteserver:$remotedownloadfolder" && \
ssh $remoteuser@$remoteserver "mv $remotedownloadfolder/* $remoteplotfolder" && \
rm $plotdir/$plotfile && \
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia upload success&message=Plot added from $myip&url=&priority=1" https://api.pushover.net/1/messages.json || \
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia upload failed&message=Plot download error from $myip&url=&priority=1" https://api.pushover.net/1/messages.json

echo "[ $( date ) ] Upload process complete" >> ~/chia.download.log
