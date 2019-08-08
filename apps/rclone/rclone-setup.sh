#! /bin/bash

# Install unzip
apt-get -qq update > /dev/null
apt-get install -y unzip wget

# Install rclone
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip

cp rclone-*/rclone /usr/local/bin/rclone
rm -rf rclone-v*
rm -rf rclone-current-linux-amd64.zip

# Configure rclone - config created during terraform setup phase!
mkdir -p /home/ubuntu/.config/rclone
cp "$(dirname -- "$0")"/rclone.conf /home/ubuntu/.config/rclone/rclone.conf

rclone mkdir crypt:composeexample-backup
rclone sync /home/ubuntu crypt:composeexample-backup

#Setup cronjob and daily backup script
cp "$(dirname -- "$0")"/backupApplication.sh /usr/local/bin/
chmod +x /usr/local/bin/backupApplication.sh
cat "$(dirname -- "$0")"/backupApplication >> /etc/crontab
