#!/bin/zsh
# Load environment variables
source "${0:a:h}/push.zsh"

function handleError() {
	pusherror "Chia update failed"
	echo "[ $(date) ] [ update.zsh ] update error at $1" >> $logfile
}

# Error handling as per https://stackoverflow.com/questions/35800082/how-to-trap-err-when-using-set-e-in-bash
set -eE
trap 'handleError ${LINENO}' ERR

# DO not error on no globbing match
setopt +o nomatch

# Get the plotfile
echo "[ $( date ) ] [ update.zsh ] Updating chia version" >> $logfile

cd ~/chia-blockchain/
source ./activate
chia stop -d all || echo "Chia not running, no need to exit"
deactivate

git fetch
git checkout latest
git reset --hard FETCH_HEAD

sh install.sh
source activate
chia init

echo "[ $( date ) ] [ update.zsh ] Chia update complete" >> $logfile
