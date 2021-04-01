#!/bin/zsh

# Assumption in script: you want the private key at the remote in ~/chiafarmer

echo "Setting up $1 with ${0:a:h}/.env " && \
source "${0:a:h}/.env" && \
ssh-keyscan $1 >> ~/.ssh/known_hosts && \
echo "Copying files to remote" && \
rsync -zvP $offlinesshkey root@$1:~/chiafarmer && \
rsync -zvP "${0:a:h}/.env" root@$1:~/.env && \
echo "Sending scripts to remote" && \
ssh root@$1 "git clone https://github.com/actuallymentor/chia-plotting-automation.git && mv .env ~/chia-plotting-automation && cd chia-plotting-automation" && \
echo "Starting remote setup" && \
ssh -t root@$1 "/bin/bash ~/chia-plotting-automation/install.sh" && \
echo "Starting remote plotter" && \
ssh -n root@$1 "nohup zsh ~/chia-plotting-automation/everplot.zsh &> /dev/null &" && \
echo "Setup for root@$1 complete"
