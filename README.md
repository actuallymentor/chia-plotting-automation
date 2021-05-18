# 🚜 Chia remote autoplotting

This repository aims to make it easy to plot [Chia]( https://www.chia.net/ ) plots in the [Digital Ocean]( https://www.digitalocean.com/ ) cloud. There are 2 elements to this repository:

1. A Digital Ocean API wrapper to create and destroy plotting machines
2. A script suite that does remote plotting, and uploads the plots to your farming machine

Assumptions:

- [ ] you are using `zsh` as your shell on your local machine
- [ ] you are running your remote as root on Ubuntu 20.04 (probably works on all debian-based distros)
- [ ] the ssh key that can access the farmer machine has no password
- [ ] you have a [pushover]( https://pushover.net/ ) account for push notifications

Notes:

- Datacenter plotting _is more expensive_ than local plotting, but it is convenient
- Your ISP might throttle you if you use your connection at 100% capacity all the time
- Downloading terrabytes per day might trigger your ISPs fair-use policy, plan accordingly

This repository is _NOT_ for you if:

- Any of the following things mean nothing to you: VPS, `ssh`, `zsh`, API
- You are not on a `UN*X` maching (sorry windows)
- You do now know how to make your farmer machine accessible through `ssh` (port forwarding etc)
- Your internet connection is slow (sub 100 Mbit/s is probably not worth it)

If you have questions or suggestions, please open a new issue in this repo.

---

## 🏎 Quickstart

1. Install dependencies with `cd digital-ocean && npm i` (requires `node.js`)
2. Input your settings into `.env` and `digital-ocean/.env`
3. Run `zsh plotter-puppetmaster.zsh plotter_amount download_time`

**Calculating optimal plot amount and delay**

The bottleneck in your plotting process is the speed of the downlink from the plotting datacenter to your farming machine (since the plotting can scale infinitely).  In order to maximize your plotting speed, calculate your plotter amount using:

`plotter_amount = plot_time / download_time`

where those variables are defined as:

1. `download_time (hours, decimal)`either based on your [Speedtest]( https://www.speedtest.net/ ) data or real life data. A 400/s Mbit downlink would equal `download_time = 103GB / ( 400 Mbit / 8 ) / ( 3600 seconds in a hour ) = ` **~0.6 hours**
2. `plot_time (hours, decimal)` is how long a plot takes to create. On the default setting of a `2vCPU 4 GB RAM` machine this is about **11-12 hours** (_last updated 16 Apr 2021, chia v1.0.4_)
3. `plotter_amount (droplets, integer)` is the amount of plotters to run at the same time, so that your downlink is always being fully utulised

Based on the above example of a 400 Mbit/s downlink, we can set up: `plotter_amount = plot_time / download_time = 13 / 0.6 =` **~21 plotters**.

I recommend _rounding down_ your calculations since any internet connection will never be at 100% speed the whole time. At 19:00 on a friday your ISP will probably throttle you so your neighbors can watch Netflix.

### ⚙️ The `.env` files (settings)

#### ./.env

```shell
# Get local ip for logging
myip=$( curl icanhazip.com )

# Plot creation keys, ALL MANDATORY. See chia keys show
publicfarmerkey= # see chia keys show
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
enableBitfield=true # remove variable entirely if not

# Plotting configuration
logfile="$HOME/everplot.log"
plotlog="$HOME/plot.log"
plotdir=$( df -h | grep -Po "/mnt/everplot.*" )/plot
tempdir=$( df -h | grep -Po "/mnt/everplot.*" )/temp
amountofplots=1
parallel=1
overheadInMB=512

# enableBitfield=true # remove variable entirely if not

# Local logging (for farming machine)
daemonLog=~/chia.daemon.log

```

#### digital-ocean/.env

```shell
# https://cloud.digitalocean.com/account/api/tokens
personal_access_token=

# https://docs.digitalocean.com/products/platform/availability-matrix/
defaultRegion=ams3
fallbackRegion=lon1
sshKeyNameInDO=

# chia temp/plotting dir size in GB, 350GB default
volumeSizeOverride=350
```

---

## 🗺 Plotter script documentation

### plotter-puppetmaster.zsh: Full-auto mode

You can use `plotter-puppetmaster.zsh` to create an arbitrary number of plotting instances. The machine that runs this needs to be on for `numberofplots * hoursofdelaybetweenstartingplots` since the script runs synchronously.

Puppetmaster usage: `zsh plotter-puppetmaster.zsh numberofplots hoursofdelaybetweenstartingplots`.

### Automated setup of single remote server

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

### Monitoring

#### Plotter status

You can follow the progress with `tail -f ~/chia-plotting-automation/nohup.out`, `tail -f ~/everplot.log` and kill the process by running `kill -9 PID` where PIDs can be found using `ps aux | grep everplot`.

#### functions/start-farmer-if-needed.zsh

This script starts the chia farmer if it is not running. It also logs status details to the file specified at `daemonLog` in `./.env`. You may want to run this script on your farmer cron.

Call this script with: `zsh ~/chia-plotting-automation/functions/start-farmer-if-needed.zsh` (assuming your cloned this repo in `~`).


### Manual usage

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

---

## 🦈 Digital Ocean scripts documentation

Available commands inside the `digital-ocean` folder:

- `npm run makeplotter` makes one plotter and returns it's IP
- `npm run deleteallplotters` deletes all plotters (filter: any droplet with `everplot` in the name, which is what `makeplotter` uses)
	- The verbose version is `npm start` which prints progress data but is not useful for scripting since it outputs so much data.
- To query the API for data and print to terminal, these do no write actions:
	- `npm run getregions` shows all available datacenter regions
	- `npm run getdroplets` shows all your droplets
	- `npm run getmeta` gets available images, sized and regions


---

## 🛠 Maintenance and debugging

Restart a failed upload asynchronously

```shell
ssh -n root@$ip 'nohup zsh ~/chia-plotting-automation/functions/upload.zsh "/$(ls /mnt/everplot*/plot | grep -P -m 1 serial)/" 'override' <remote user override> <remote ip override> <remote ssh port override> <remote plot folder override> <remote download folder override> &> ~/nohup.out &'
```

Restart a failed upload synchronously

```shell
ssh root@$ip 'zsh ~/chia-plotting-automation/functions/upload.zsh "/$(ls /mnt/everplot*/plot | grep -P -m 1 serial)/" 'override' <remote user override> <remote ip override> <remote ssh port override> <remote plot folder override> <remote download folder override>'
```

Restart failed uploads in bulk asynchronously:

```shell
failedips=( 1.1.1.1 )
for ip in $failedips; do
    ssh -n root@$ip 'nohup zsh ~/chia-plotting-automation/functions/upload.zsh "/$(ls /mnt/everplot*/plot | grep -P -m 1 serial)/" &> ~/nohup.out &'
done
```

Check for plots remotely in bulk:

```shell
ips=( 1.1.1.1 2.2.2.2 )
for ip in $ips; do
    echo -e "\n\nPlots on $ip:"
    ssh root@$ip 'ls -lah /mnt/everplot*/**/*.plot'
done
```

Updating remote servers:

```shell
ips=( 1.1.1.1 2.2.2.2 )
for ip in $ips; do

	echo "Updating repo on $ip"
	ssh root@$ip 'cd ~/chia-plotting-automation/ && git pull'
	echo "Updating chia"
	ssh root@$ip 'zsh ~/chia-plotting-automation/functions/update.zsh'

	# To make env changes
	# ssh root@$ip 'sed -i "s/search/replace/" ~/chia-plotting-automation/.env'
	# ssh root@$ip 'echo "enableBitfield=true # remote addition" >> ~/chia-plotting-automation/.env'
done
```

Reset remote server manually:

```shell
rm -rf chia*
rm -f .env
rm -rf .chia
rm *.log
rm -rf vps
rm nohup.out
pgrep -f everplot | xargs kill -9 $1
pgrep -f chia | xargs kill -9 $1
l
ps aux | grep chia # should be empty
```
