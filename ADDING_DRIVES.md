# Adding drives

When buying new drives and hooking them up, I like to reformat them like so (where sdX is the drive name):

```shell
MOUNTPATH=/mnt/PATH/
DEVID=sdaX

sudo blkid
sudo parted /dev/$DEVID mklabel gpt
sudo parted /dev/$DEVID mkpart primary 0% 100%
sudo mkfs -L "Label" -t ext4 "/dev/"$DEVID"1"
sudo blkid
sudo mkdir $MOUNTPATH
sudo chown -R USER $MOUNTPATH
sudo nano /etc/fstab
# UUID=UUID $MOUNTPATH ext4 defaults,nofail,x-systemd.mount-timeout=10s 0 2
sudo mount -a
df -h

```