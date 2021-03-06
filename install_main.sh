#!/bin/bash
echo "Making stuff nice"

sudo mkdir -p "/lcs/"
apt-get -y install libnet-snmp-perl unzip libstring-random-perl libnetaddr-ip-perl libnet-netmask-perl isc-dhcp-server bind9 lamp-server^ libnet-telnet-cisco-perl libnet-telnet-perl tftpd-hpa libnet-oping-perl libio-socket-ssl-perl snmp-mibs-downloader snmp
cd "/lcs"
echo "Downloading code....."
wget https://github.com/msbone/lcs/archive/master.zip
unzip -u master.zip;
mv LCS-master/* ./
rm master.zip
rm -R LCS-master


#make the config.pm
cp include/config.pm.example include/config.pm
touch include/db_password.txt

#SETUP THE WEBSERVER
echo "CREATING CONFIG FOR THE WEB SERVER"
cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /lcs/web/
        <Directory "/lcs/web/">
            AllowOverride All
            Require all granted
        </Directory>


        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

service apache2 restart

#SETUP THE SNMP STUFF
echo "CREATING SNMP CRONJOB"
download-mibs
mkdir /lcs/web/rrd

cat > /etc/cron.d/lcs << EOF
0,15,30,45 * * * * root perl /lcs/tools/snmp_discovery.pl
* * * * * root perl /lcs/tools/snmp_fetch.pl
* * * * * root perl /lcs/tools/dhcp_magic.pl
* * * * * root perl /lcs/tools/mac-fetch.pl
EOF


#Make the hardlink for dns and dhcp key
ln /etc/bind/rndc.key /etc/dhcp/ddns-keys/rndc.key
sudo chown root:bind /etc/dhcp/ddns-keys/rndc.key

#Create some folders TEMP, THIS SHOULD BE DONE IN MAKE_DNS.PM NOT HERE
mkdir /etc/bind/dynamic
mkdir /etc/bind/reverse
chmod -R 777 /etc/bind/dynamic
chmod -R 777 /etc/bind/reverse

#Do dlinkac magic
sudo chmod -R 777 /lcs/AC/tftp
sudo chown -R nobody /lcs/AC/tftp

cat > /etc/default/tftpd-hpa << EOF
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/lcs/AC/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-s -c -l"
EOF

sudo service tftpd-hpa restart

mkdir /LCS/AC/mikrotik-config
mkdir /LCS/AC/mikrotik-firmware
cd /LCS/AC/mikrotik-firmware

#remove appamor
service apparmor stop
update-rc.d -f apparmor remove
apt-get -y remove apparmor apparmor-utils
apt-get -y purge apparmor
#Det her krever en omstart, men vi gir beskjed om det forst etter database er laget

echo "LCS is finished instaling (/lcs/), Fill in the root password for mysql in /lcs/include/config.pm then run perl /lcs/setup_database.pl"
