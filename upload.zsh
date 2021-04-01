source "${0:a:h}/.env" && \
plotfile=$( ls /mnt/volume* | grep plot ) && \

# Trust the remote server and import ssh key
chmod 600 $sshkey && \
eval `ssh-agent -s` && ssh-keyscan $remoteserver >> ~/.ssh/known_hosts && \
ssh-add $sshkey && \

echo "[ $( date ) ] starting upload of $plotfile" >> $logfile && \
# Copy without -z compression, -v verbosity, -P progress
rsync -vP $plotdir/$plotfile "$remoteuser@$remoteserver:$remotedownloadfolder" && \
echo "[ $( date ) ] completed upload of $plotfile" >> $logfile && \

# Move the remote file from download folder to farming folder
ssh $remoteuser@$remoteserver "mv $remotedownloadfolder/* $remoteplotfolder" && \
echo "[ $( date ) ] completed moving of $plotfile" >> $logfile && \

# Delete local plotfile
rm $plotdir/$plotfile && \

# Notify via push noti
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia upload success&message=Plot added at $myip&url=&priority=1" https://api.pushover.net/1/messages.json || \
curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia upload failed&message=Plot download error at $myip&url=&priority=1" https://api.pushover.net/1/messages.json

echo "[ $( date ) ] ended upload process of $plotfile" >> $logfile
