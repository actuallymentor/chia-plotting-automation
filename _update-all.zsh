#!/bin/zsh

# Arguments
oldUploadPath=$1
newUploadPath=$2

# Get all ips
cd digital-ocean
ips=$( npm run getdroplets | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" )
cd ..

echo "Running with ips: $ips"

# Update to new upload-folders
if [[ -n "$oldUploadPath" && -n "$newUploadPath" ]]; then
	
	echo -e "\nUpdating $oldUploadPath to $newUploadPath on all plotters..."
	echo $ips | while read -r ip; do
		echo "Updating $ip"
		ssh -n root@$ip 'sed -i "s/'$oldUploadPath'/'$newUploadPath'/" ~/chia-plotting-automation/.env'
	done

fi

# Trigger updates remotely
if [[ -n "$updateChia" ]];then
	echo -e "\nUpdating all plotters..."
	echo $ips | while read -r ip; do 
		echo "Updating $ip"
		ssh -n root@$ip 'nohup zsh ~/chia-plotting-automation/functions/update.zsh &> ~/nohup.out &'
	done
fi