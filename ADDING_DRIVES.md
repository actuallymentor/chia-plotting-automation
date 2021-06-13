# Adding drives

When buying new drives and hooking them up, I like to reformat them like so (where sdX is the drive name):

```shell
# Edit these
MOUNTPATH=/mnt/path_to_mountpath/
DEVID=sdX # see sudo blkid
LABEL="Label of drive"

# Get the drive location and use it to format the partitions
sudo parted /dev/$DEVID mklabel gpt
sudo parted /dev/$DEVID mkpart primary 0% 100%
sudo mkfs -L $LABEL -t ext4 "/dev/"$DEVID"1"

# Add the drive to Fstab
PARTITIONUUID=uuid-of-partition-see-blkid
echo "UUID=$PARTITIONUUID $MOUNTPATH ext4 defaults,nofail,x-systemd.mount-timeout=10s 0 2" | sudo tee -a /etc/fstab

# Mount and check status
sudo mount -a
df -h

# Make paths and add them
sudo mkdir -p $MOUNTPATH"chia/download/"
sudo mkdir -p $MOUNTPATH"chia/plots/"
l $MOUNTPATH"/chia/"
sudo chown -R $( whoami ) $MOUNTPATH
chia plots add -d $MOUNTPATH"chia/plots/"

```