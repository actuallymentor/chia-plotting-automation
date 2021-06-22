# Adding drives

When buying new drives and hooking them up, I like to reformat them like so (where sdX is the drive name):

```shell
# Edit these
MOUNTPATH=/mnt/passport_5TB_five/
DEVID=sdi # see sudo blkid
LABEL="Passport 5TB 5"
UPLOADUSER=mentor

# Get the drive location and use it to format the partitions
sudo parted /dev/$DEVID mklabel gpt
sudo parted /dev/$DEVID mkpart primary 0% 100%
sudo mkfs -L $LABEL -t ext4 "/dev/"$DEVID"1"

# Add the drive to Fstab
sudo blkid | grep $LABEL
PARTITIONUUID=xxx-xxx-xxx-xxx
echo "UUID=$PARTITIONUUID $MOUNTPATH ext4 defaults,nofail,x-systemd.mount-timeout=10s 0 2" | sudo tee -a /etc/fstab

# Make paths and add them
sudo mkdir -p $MOUNTPATH"chia/download/"
sudo mkdir -p $MOUNTPATH"chia/plots/"
l $MOUNTPATH"/chia/"
sudo chown -R $UPLOADUSER $MOUNTPATH

# Mount and check status
sudo mount -a
df -h

# Use if local farming, not with hpool
# chia plots add -d $MOUNTPATH"chia/plots/"

```