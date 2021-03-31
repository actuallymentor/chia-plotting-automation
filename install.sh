source ./.env && \
apt update && \

git clone https://github.com/actuallymentor/vps-setup-ssh-zsh-pretty.git vps && \
bash ./vps/03-zsh.sh && \
bash ./vps/04-swap.sh && \

# Install Chia
git clone https://github.com/Chia-Network/chia-blockchain.git && \
cd chia-blockchain && \

sh install.sh && \

. ./activate && \

chia init && \

curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Install donw&message=Continuing&url=&priority=1" https://api.pushover.net/1/messages.json || \

curl -f -X POST -d "token=$pushover_token&user=$pushover_user&title=Install FAILED&message=Go fix it&url=&priority=1" https://api.pushover.net/1/messages.json
