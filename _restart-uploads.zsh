#!/bin/zsh

# Arguments
listonly=$1

# Get all ips
cd digital-ocean
ips=$( npm run getdroplets | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" )
cd ..

echo "Running with ips: $ips"

# List the plots on remote machines
if [[ -n "$listonly" ]];then

	echo -e "\nList remote plots..."

	echo $ips | while read -r ip; do 
		echo -e "\nPlots on $ip"
		ssh -n root@$ip 'l /mnt/everplot*/**/*.plot'
	done

	# exit
	exit 0

fi

# Trigger upload if needed on them
echo -e "\nRestarting uploads on all plotters..."

echo $ips | while read -r ip; do 
	echo "Restart upload on $ip"
	ssh -n root@$ip 'nohup zsh ~/chia-plotting-automation/functions/upload.zsh "/$(ls /mnt/everplot*/plot | grep -P -m 1 serial)/" &> ~/nohup.out &'
done