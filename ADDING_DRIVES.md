# Adding drives

When buying new drives and hooking them up, I like to reformat them like so (where sdX is the drive name):

```shell
# Edit these
MOUNTPATH=/mnt/passport_5TB_eleven/
DEVID=sdo # see sudo blkid | grep "My Passport" lmno
LABEL="Passport 5TB 11"
UPLOADUSER=mentor

# Get the drive location and use it to format the partitions
sudo parted /dev/$DEVID mklabel gpt
sudo parted /dev/$DEVID mkpart primary 0% 100%
sudo mkfs -L $LABEL -t ext4 "/dev/"$DEVID"1"

# Add the drive to Fstab
PARTITIONUUID=$( sudo blkid | grep $LABEL | grep -Po "(?<=\ UUID=\")([a-z0-9\-]*)" )
echo "Writing $PARTITIONUUID to fstab. Press any key to continue."
read
echo "UUID=$PARTITIONUUID $MOUNTPATH ext4 defaults,nofail,x-systemd.mount-timeout=10s 0 2" | sudo tee -a /etc/fstab

# Mount and check status
sudo mkdir $MOUNTPATH
sudo mount -a
df -h

# Make paths and add them
sudo mkdir -p $MOUNTPATH"chia/download/"
sudo mkdir -p $MOUNTPATH"chia/plots/"
sudo chown -R $UPLOADUSER $MOUNTPATH
l $MOUNTPATH"/chia/"


# Use if local farming, not with hpool
# chia plots add -d $MOUNTPATH"chia/plots/"

```