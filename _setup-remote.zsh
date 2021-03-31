echo "Setting up $1" && \
source "${0:a:h}/.env" && \
ssh-keyscan $1 >> ~/.ssh/known_hosts && \
rsync -zvP $offlinesshkey root@$1:$offlinesshkey && \
rsync -zvP "${0:a:h}/.env" root@$1:~/.env && \
ssh -t root@$1 "git clone git clone https://github.com/actuallymentor/chia-plotting-automation.git && cd chia-plotting-automation && echo 'Ready to bash install.sh && nohup zsh ./everplot.zsh & disown'"
echo "Something went wrong"