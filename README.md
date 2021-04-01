# Chia remote autoplotting

Assumptions:

- you are running your remote as root
- your remote is ubuntu (probably works on all debian-based distros)
- your ssh key for farmer use has no password

## Manual usage

1. Create 2vCPU/4GB VPS with 500GB volume
    - recommended: choose close data center
    - recommended: enable additional monitoring
1. `ssh` into it
1. Clone this repo git `git clone https://github.com/actuallymentor/chia-plotting-automation.git`
1. Run `bash ./install.sh`
1. Create a `.env`, see section below
    - Add credentials
    - Make local private key
1. Run `nohup zsh ./everplot.zsh & disown`

The script will:

1. Make a plot
2. Upload the plot to your farmer (async)
3. Delete the local plot (async)
4. Make another
5. Continue until you manually force it to stop

## Automated setup

Assumptions: you have a locally populated `.env` of which all file references exist.

1. Create 2vCPU/4GB VPS with 500GB volume
2. Locally run `zsh _setup-remote.zsh the.ip.of.remote`
3. On remote machine run
    - `cd chia-plotting-automation`
    - `bash install.sh`
    - `nohup zsh ./everplot.zsh & disown`

## Monitoring

You can follow the progress with `tail -f ~/chia-plotting-automation/nohup.out`, `tail -f ~/everplot.log` and kill the process by running `kill -9 PID` where PIDs can be found using `ps aux | grep everplot`.

## The `.env`

```shell
# Get local ip for logging
myip=$( curl icanhazip.com )

# Plot creation keys, ALL MANDATORY. See chia keys show
publicfarmerkey= # see chia keys show
publicchiakey=
poolfarmerkey=

# Pushnotifications using pushover.net
pushover_user=
pushover_token=

# Remote farmer configuration
remotedownloadfolder='/mnt/yourdrive/chia/download/'
remoteplotfolder='/mnt/yourdrive/chia/plots/'
remoteserver='1.1.1.1'
remoteuser='username'
sshkey="$HOME/chiafarmer" # for use on the plotting machine, this is where to put the private key REMOTELY
offlinesshkey="$HOME/.ssh/chiafarmer" # for use in _setup-remote.zsh, so this is your LOCAL privatekey location

# Plotting configuration
logfile="$HOME/everplot.log"
plotdir=$( df -h | grep -Po "/mnt/volume.*" )
tempdir=$( df -h | grep -Po "/mnt/volume.*" )
amountofplots=1

```