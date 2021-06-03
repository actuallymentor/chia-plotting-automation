# Adding drives

When buying new drives and hooking them up, I like to reformat them like so (where sdX is the drive name):

```shell
# Edit these
MOUNTPATH=/mnt/passport_5TB_two/
DEVID=sdg # see sudo blkid
LABEL="Passport 5TB Two"

# Get the drive location and use it to format the partitions
sudo parted /dev/$DEVID mklabel gpt
sudo parted /dev/$DEVID mkpart primary 0% 100%
sudo mkfs -L $LABEL -t ext4 "/dev/"$DEVID"1"

sudo mkdir -p $MOUNTPATH"chia/download/"
sudo mkdir -p $MOUNTPATH"chia/plots/"
sudo chown -R $( whoami ) $MOUNTPATH
chia plots add -d $MOUNTPATH"chia/plots/"

# Get the UUID to use in the fstab
sudo blkid
sudo nano /etc/fstab
# UUID=UUID $MOUNTPATH ext4 defaults,nofail,x-systemd.mount-timeout=10s 0 2

# Mount and check status
sudo mount -a
df -h

```