goon=true
source ./.env
while [ "$goon" = true ]; do
	zsh ./plot.zsh
	zsh ./upload.zsh

	# If prevcious plot was not deleted
	plotsondisk=$( ls /mnt/volume* | grep plot | wc -l )
	if (( plotsondisk > 0 )); then
		goon=false
	fi

done

curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Everplot STOPPED&message=Everplot at $myip ended&url=&priority=1" https://api.pushover.net/1/messages.json
