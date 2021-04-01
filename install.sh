#!/bin/bash

# Check if the digital ocean monitor was installed yet
waitingforinstall=true
waitcount=0
waitdurationinseconds=30
maxwaitcount=10
echo -e "\n[ $( date ) ]  Does this log confuse you? You probably forgot to enable monitoring, see https://www.digitalocean.com/docs/monitoring/how-to/install-agent/#during-creation. Don't worry, this operation will time out after a few minutes, just go make tea.\n"
while [ "$waitingforinstall" = true ]; do

	# Check if DO utility finished installing
	if apt-cache policy do-agent | grep -qPo "Installed: \d+"; then
		waitingforinstall=false
		echo "[ $( date ) ] DO agent installed, continuing"
	else
		
		echo "[ $( date ) ] waiting for DO agent to be installed"
		sleep $waitdurationinseconds

		# Increment wait cound
		((waitcount=waitcount+1))

		# If wait count was exceeded, just continue
		if (( $waitcount > $maxwaitcount )); then
			echo "[ $( date ) ] DO wait timed out, continuing"
			waitingforinstall=false
		fi
	fi


done

source ~/.env && \
apt update && \

git clone https://github.com/actuallymentor/vps-setup-ssh-zsh-pretty.git vps && \
bash ./vps/03-zsh.sh && \
bash ./vps/04-swap.sh && \

# Install Chia
cd && \
git clone https://github.com/Chia-Network/chia-blockchain.git && \
cd chia-blockchain && \

sh install.sh && \

. ./activate && \

chia init && \

cd ~/chia-plotting-automation && \

curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Install done&message=Continuing&url=&priority=1" https://api.pushover.net/1/messages.json && \
zsh || \

curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Install failed&message=Go fix it&url=&priority=1" https://api.pushover.net/1/messages.json
