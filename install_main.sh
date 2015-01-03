#!/bin/bash
echo "Making stuff nice"

sudo mkdir -p "/lcs/"
apt-get -y install unzip libstring-random-perl libnet-netmask-perl isc-dhcp-server bind9 lamp-server^ libnet-telnet-cisco-perl libnet-telnet-perl tftpd-hpa
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
sudo chown root:bind /etc/dhcp/ddns-keys/rndc.key

#Create some folders TEMP, THIS SHOULD BE DONE IN MAKE_DNS.PM NOT HERE
mkdir /etc/bind/dynamic
mkdir /etc/bind/reverse
chmod 777 /etc/bind/dynamic
chmod 777 /etc/bind/reverse

#Do dlinkac magic
sudo chmod -R 777 /lcs/dlinkac/tftp
sudo chown -R nobody /lcs/dlinkac/tftp

cat > /etc/default/tftpd-hpa << EOF
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/lcs/dlinkac/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-s -c -l"
EOF

sudo service tftpd-hpa restart

#remove appamor
service apparmor stop
update-rc.d -f apparmor remove
apt-get -y remove apparmor apparmor-utils
#Det her krever en omstart, men vi gir beskjed om det forst etter database er laget

echo "LCS is finished instaling (/lcs/), Fill in the missing info in config.pm then run setup_database.pl"
