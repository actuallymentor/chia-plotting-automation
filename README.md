# Chia remote autoplotting

1. Create 2vCPU/4GB VPS with 500GB volume
1. Clone this repo git `git clone https://github.com/actuallymentor/chia-plotting-automation.git`
1. Run `bash ./install.sh`
1. Create a `.env`, see section below
    - Add credentials
    - Make local private key
1. Run `nohup zsh ./everplot.zsh & disown`

Alternatively you may use `zsh _setup-remote.zsh ip.of.remote.server`.

You can follow the progress with `tail -f nohup.out` and kill the process by running `kill -9 PID` where PIDs can be found using `ps aux | grep everplot`

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
poolfarmerkey=

# For pushover notifications, mandatory for not but you can strip it out
pushover_user=
pushover_token=

# Credentials and config of your farmer, make sure to have the SSH key installed there
remotedownloadfolder=
remoteplotfolder=
sshkey= # This is a path, not a string
remoteserver=
remoteuser=

```