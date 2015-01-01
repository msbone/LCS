#!/bin/bash
echo "Making stuff nice"

sudo mkdir -p "/lcs/"
apt-get -y install unzip libstring-random-perl libnet-netmask-perl isc-dhcp-server bind9 lamp-server^
cd "/lcs"
echo "Downloading code....."
wget https://github.com/msbone/lcs/archive/master.zip
unzip -u master.zip;
mv LCS-master/* ./
rm master.zip
rm -R LCS-master
cp config.pm.example config.pm

#Make the hardlink for dns and dhcp key
ln /etc/bind/rndc.key /etc/dhcp/ddns-keys/rndc.key

#Create some folders TEMP, THIS SHOULD BE DONE IN MAKE_DNS.PM NOT HERE
mkdir /etc/bind/dynamic
mkdir /etc/bind/reverse
chmod 777 /etc/bind/dynamic
chmod 777 /etc/bind/reverse

echo "LCS is finished instaling (/lcs/), Fill in the missing info in config.pm then run setup_database.pl"
