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
3. On remote machine run:

```shell
# installation of chia
cd ~/chia-plotting-automation
bash install.sh

# Start everplot
nohup zsh ./everplot.zsh & disown

# Optional log checks:
cat ~/everplot.log
tail -f nohup.out
```

### Droplet creation automation

You can use `plotter-puppetmaster.zsh` to create an arbitrary number of plotting instances. Be sure to create `digital-ocean/.env` with:

```
personal_access_token=

# https://docs.digitalocean.com/products/platform/availability-matrix/
defaultRegion=ams3
fallbackRegion=lon1

# Name of ssh key in DO interface
sshKeyNameInDO=mentorkey
```

Puppetmaster usage: `zsh plotter-puppetmaster.zsh numberofplots hoursofdelaybetweenstartingplots`

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
sshport=22

# Plotting configuration
logfile="$HOME/everplot.log"
plotlog="$HOME/plot.log"
plotdir=$( df -h | grep -Po "/mnt/volume.*" )/plot
tempdir=$( df -h | grep -Po "/mnt/volume.*" )/temp
amountofplots=1
parallel=1
overheadInMB=512

```

## Dev notes

Reset server storage: `rm -rf chia*; rm -f .env; rm -rf .chia; rm *.log; rm -rf vps; rm nohup.out; pgrep -f everplot | xargs kill -9 $1; pgrep -f chia | xargs kill -9 $1; l; ps aux | grep chia`