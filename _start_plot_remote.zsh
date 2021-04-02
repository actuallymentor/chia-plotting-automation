#!/bin/zsh

ssh root@$1 "nohup zsh ~/chia-plotting-automation/everplot.zsh &> /dev/null &"