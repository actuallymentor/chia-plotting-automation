#!/bin/zsh
# Load environment variables
source "${0:a:h}/push.zsh"

function handleError() {
	pusherror "Chia update failed"
	echo "[ $(date) ] [ update.zsh ] update error $LINENO" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap handleError ERR

# DO not error on no globbing match
setopt +o nomatch

# Get the plotfile
echo "[ $( date ) ] [ update.zsh ] Updating chia version" >> $logfile

cd ~/chia-blockchain/
git fetch
git checkout latest
git pull
sh install.sh
source activate
chia init

echo "[ $( date ) ] [ update.zsh ] Chia update complete" >> $logfile
