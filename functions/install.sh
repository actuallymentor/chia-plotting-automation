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

# DO not error on no globbing match
setopt +o nomatch

# Get anv vars and validate
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ./.env
bash "$DIR/validate.zsh"

apt update

git clone https://github.com/actuallymentor/vps-setup-ssh-zsh-pretty.git vps
bash ./vps/03-zsh.sh

if [ -v madmax ]; then
	echo "[ $( date ) ] Using madmax, skip swap" >> $logfile
else
	bash ./vps/04-swap.sh
fi

echo "[ $( date ) ] shell setup complete" >> $logfile

# Install chia or madmax
if [ -v madmax ]; then

	# Madmax setup
	apt install -y libsodium-dev cmake g++ git build-essential
	# Checkout the source and install
	git clone https://github.com/madMAx43v3r/chia-plotter.git 
	cd chia-plotter
	git submodule update --init
	./make_devel.sh
	./build/chia_plot --help

	# Make ramdisk
	ramdiskpath="${ramdiskpath:-/mnt/ramdisk/}"
	mkdir $ramdiskpath
	mount -t tmpfs -o size=110G tmpfs $ramdiskpath
	df -h
	echo "[ $( date ) ] Madmax installation complete" >> $logfile

else

	# Install Chia
	cd
	git clone https://github.com/Chia-Network/chia-blockchain.git
	cd chia-blockchain

	sh install.sh

	. ./activate

	chia init 
	echo "[ $( date ) ] chia installation complete" >> $logfile


fi

cd ~/chia-plotting-automation
