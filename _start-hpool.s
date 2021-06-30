# Very specific to my serup
cd ~/hpool/linux-arm

drives=$( ls -1d /mnt/* )

hpoolpath='/home/mentor/hpool'
mounts="--mount type=bind,source=$hpoolpath,target=$hpoolpath"
paths=""

echo $drives | while read -r drive; do
        mounts="$mounts --mount type=bind,source=$drive,target=$drive"
        paths="$paths- $drive/chia/plots\n"
done


echo "Run docker and inside there run ./$hpoolpath/hpool-chia-miner-linux-arm"
echo "Run with: "
echo "sudo docker run -it $mounts arm32v7/ubuntu"


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