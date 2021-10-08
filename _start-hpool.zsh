#!/bin/zsh

# Very specific to my serup
cd ~/hpool/linux-arm

# Variables
drives=$( ls -1d /mnt/* )
devices=$( ls -1d /dev/sd* )
hpoolpath='/home/mentor/hpool'
mounts="--mount type=bind,source=$hpoolpath,target=$hpoolpath"
paths=""

# Add drives to docker mount command
echo $drives | while read -r drive; do
        echo "Adding mount for $drive"
        mounts="$mounts --mount type=bind,source=$drive,target=$drive"
        paths="$paths- $drive/chia/plots\n"
done

# # Set all drives to no timeout
# echo $devices | while read -r device; do
#         sudo hdparm -S 0 $device && echo "✅ No sleep for $device" || echo "⚠️ Cannot force nosleep on $device"
# done

# Terminal feedback
echo "Run docker and inside there run $hpoolpath/linux-arm/hpool-chia-miner-linux-arm"
echo -e "Run with: \n"
echo "sudo docker run --name hpool --restart unless-stopped -d $mounts arm64v8/ubuntu /bin/bash -c \"cd $hpoolpath/linux-arm/ && ./hpool-chia-miner-linux-arm\" "

echo -e "Or interactively with: \n"
echo "sudo docker run --name hpool --restart no -it $mounts arm64v8/ubuntu /bin/bash -c \"cd $hpoolpath/linux-arm/ && ./hpool-chia-miner-linux-arm\" "


echo -e "token: \"\"
path:
$paths
minerName: ubuntu
apiKey: c626f221-3535-4dd7-837f-4432f61f12fa
cachePath: \"\"
deviceId: \"\"
extraParams: {}
log:
  lv: info
  path: ./log
  name: miner.log
url:
  info: \"\"
  submit: \"\"
  line: \"\"
  ws: \"\"
scanPath: true
scanMinute: 15
debug: \"\"
language: en
multithreadingLoad: false" > config.yaml
