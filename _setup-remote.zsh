#!/bin/zsh
# Assumption in script: you want the private key at the remote in ~/chiafarmer

# Load environment variables
source "${0:a:h}/.env"

function handleError() {
	curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Chia setup failed&message=Setup error $( caller ) at $myip&url=&priority=1" https://api.pushover.net/1/messages.json
	echo "[ $(date) ] - Plot error $1 at $plotdir" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# DO not error on no globbing match
setopt +o nomatch

echo "Setting up $1 with ${0:a:h}/.env " 
ssh-keyscan $1 >> ~/.ssh/known_hosts 
echo "Copying files to remote" 

# Copy files
rsync -zvP $offlinesshkey root@$1:~/chiafarmer 
rsync -zvP "${0:a:h}/.env" root@$1:~/.env 
echo "Sending scripts to remote" 
ssh root@$1 "git clone https://github.com/actuallymentor/chia-plotting-automation.git && cp .env ~/chia-plotting-automation" 

# Run install
echo "Starting remote setup" 
ssh -t root@$1 "/bin/bash ~/chia-plotting-automation/install.sh" 

# Init plotter
for ((instance=1; instance<=parallel; instance++)); do
	echo "Starting remote plotter $instance" 
	ssh -n root@$1 'nohup zsh $HOME/chia-plotting-automation/everplot.zsh $instance &> $HOME/nohup.out &'
done

echo "Setup for root@$1 complete"
