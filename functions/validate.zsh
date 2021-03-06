## ###############
## Validation of env
## ###############

# Chia key validation
if [ -z "$publicfarmerkey" ] || [ -z "$poolfarmerkey" ]; then
	echo "Missing chia keys"
	exit 1
fi

# Pushover validation
if [ -z "$pushover_user" ] || [ -z "$pushover_token" ]; then
	echo "Missing pushover tokens"
fi

# Folder validations
if [ -z "$remotedownloadfolder" ] || [ -z "$remoteplotfolder" ]; then
	echo "Missing folders"
	exit 1
fi

# Auth validations
if [ -z "$remoteserver" ] || [ -z "$remoteuser" ] || [ -z "$sshkey" ] || [ -z "$offlinesshkey" ] || [ -z "$sshport" ]; then
	echo "Missing auth settings"
	exit 1
fi

# Plot config
if [ -z "$overheadInMB" ] || [ -z "$logfile" ] || [ -z "$plotlog" ] || [ -z "$plotdir" ] || [ -z "$tempdir" ] || [ -z "$amountofplots" ] || [ -z "$parallel" ]; then
	echo "Missing plot config settings"
	exit 1
fi