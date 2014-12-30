#!/bin/bash
echo "Making stuff nice"

sudo mkdir -p "/lcs/"
apt-get -y unzip
cd "/lcs"
echo "Downloading code....."
wget https://github.com/msbone/lcs/archive/master.zip
unzip -u master.zip;
mv lcs-master/* ./
rm master.zip
rm -R lcs-master
cp config.pm.example config.pm

echo "lcs is finished instaling (/lcs/), Fill in the missing info in config.pm then run setup_database.sh"
