#!/bin/zsh
# Assumption in script: you want the private key at the remote in ~/chiafarmer

## ###############
## Meta settings
## ###############

# Load environment variables
source "${0:a:h}/.env"
source "${0:a:h}/functions/push.zsh"
remoteip=$1

function handleError() {
	push "Chia setup failed"
	echo "[ $(date) ] - Setup error error $LINENO $1 $remoteip at $plotdir" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# Do not error on no globbing match
setopt +o nomatch


## ###############
## Actual setup
## ###############

echo "Setting up $remoteip with ${0:a:h}/.env"
ssh-keyscan $remoteip || "Error scanning $remoteip"
ssh-keyscan $remoteip >> ~/.ssh/known_hosts
echo "Copying files to remote" 

# Copy files
rsync -zvP $offlinesshkey root@$remoteip:~/chiafarmer 
rsync -zvP "${0:a:h}/.env" root@$remoteip:~/.env 
echo "Sending scripts to remote" 
ssh root@$remoteip "git clone https://github.com/actuallymentor/chia-plotting-automation.git && cp .env ~/chia-plotting-automation" 

# Run install
echo "Starting remote setup" 
ssh -t root@$remoteip "/bin/bash ~/chia-plotting-automation/functions/install.sh" 

# Init plotter
for ((instance=1; instance<=parallel; instance++)); do
	echo "Starting remote plotter $instance" 
	echo "[ $(date) ] - Starting everplot with nohup zsh \$HOME/chia-plotting-automation/functions/everplot.zsh $instance &> \$HOME/nohup.out &" >> $logfile
	ssh -n root@$remoteip "nohup zsh \$HOME/chia-plotting-automation/functions/everplot.zsh $instance &> \$HOME/nohup.out &"
done

echo "Setup for root@$remoteip complete"
