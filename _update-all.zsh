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
		echo "✅ Search/replace on $ip complete"
	done

fi

# Trigger updates remotely
if [[ "$oldUploadPath" = 'update' ]];then
	echo -e "\nUpdating all plotters..."
	echo $ips | while read -r ip; do 
		echo "Updating $ip"
		ssh -n root@$ip 'zsh ~/chia-plotting-automation/functions/update.zsh'
		echo -e "✅ Update of $ip complete\n"
	done
fi