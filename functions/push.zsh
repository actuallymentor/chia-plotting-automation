# Load environment variables
source "${0:a:h}/../.env"

function push() {
	echo "[ $( date ) ] [ push.zsh ] $1 $2" >> $logfile
	curl -f -X POST \
	-d "token=$pushover_token&user=$pushover_user&title=$1&message=$2 at $( hostname )/$myip&url=&priority=1" \
	https://api.pushover.net/1/messages.json
}