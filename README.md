# Chia remote autoplotting

1. Create a `.env`, see sectoion below
1. Create 2vCPU/4GB VPS with 500GB volume
2. Clone this repo
3. Run `bash ./install.sh`
4. Run `nohup zsh ./everplot.zsh & disown`

The script will:

1. Make a plot
2. Upload the plot to your farmer
3. Delete the local plot
4. Make another
5. Continue until you force it to stop

## The `.env`

```shell
myip=$( curl icanhazip.com )

# see chia keys show
publicfarmerkey= 
publicchiakey=

# For pushover notifications, mandatory for not but you can strip it out
pushover_user=
pushover_token=

# Credentials and config of your farmer, make sure to have the SSH key installed there
remotefolder=
sshkey= # This is a path, not a string
remoteserver=
remoteuser=

```