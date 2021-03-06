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
		plots=$( ssh -n root@$ip 'setopt +o nomatch && l /mnt/everplot*/**/*.plot 2> /dev/null' )
		if [[ -n "$plots" ]]; then
			echo -e "Plots on $ip"
			echo $plots
			echo -e "\n"
		else
			echo -e "Plots on $ip: none"
		fi
		
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