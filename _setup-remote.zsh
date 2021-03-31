#!/bin/zsh

# Assumption in script: you want the private key at the remote in ~/chiafarmer

echo "Setting up $1 with ${0:a:h}/.env " && \
source "${0:a:h}/.env" && \
ssh-keyscan $1 >> ~/.ssh/known_hosts && \
rsync -zvP $offlinesshkey root@$1:~/chiafarmer && \
rsync -zvP "${0:a:h}/.env" root@$1:~/.env && \
ssh -t root@$1 "git clone https://github.com/actuallymentor/chia-plotting-automation.git && mv .env ~/chia-plotting-automation && cd chia-plotting-automation && echo 'Ready to bash install.sh && nohup zsh ./everplot.zsh & disown' && /bin/bash -i"
echo "Something went wrong"