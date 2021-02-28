#!/bin/bash

rm -rf ~/tinyha-svn/php/ ~/tinyha-svn/opt/
cp -a /var/www/html/. ~/tinyha-svn/php/
cp -a /opt/tinyha/ ~/tinyha-svn/opt/
mkdir ~/tinyha-svn/opt/systemd
cp -a /etc/systemd/system/tinyha*.service ~/tinyha-svn/opt/systemd/
cp /var/spool/cron/crontabs/root ~/tinyha-svn/opt/crontab.txt
rm ~/tinyha-svn/opt/gpio/??
rm ~/tinyha-svn/php/graphs/*.png

cd ~/tinyha-svn
svn status | grep ^! | awk '{print " --force "$2}' | xargs svn remove
svn add --force * --auto-props --parents --depth infinity

echo
echo

svn status

read -rsp $'Press enter to commit SVN...\n'

svn commit -m "TinyHA auto commit"
