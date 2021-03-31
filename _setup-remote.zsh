source "${0:a:h}/.env" && \
rsync -zvP ~/chiafarmer root@$1:$offlinesshkey && \
rsync -zvP "${0:a:h}/.env" root@$1:~/.env && \
ssh -t root@$1 "git clone git clone https://github.com/actuallymentor/chia-plotting-automation.git && cd chia-plotting-automation && echo 'Ready to bash install.sh && nohup zsh ./everplot.zsh & disown'"
echo "Something went wrong"