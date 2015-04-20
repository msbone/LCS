Lan Config System
===
The system is only tested on Ubuntu 14.04.2 clean install


####How to setup the master server (main NMS, DHCP and master DNS) <br />
Install mysql-server ```apt-get install mysql-server``` <br />
 Set a good password for mysql root user

Get the setup script from https://raw.githubusercontent.com/msbone/LCS/master/install_main.sh  or just run the following command<br />
```wget https://raw.githubusercontent.com/msbone/LCS/master/install_main.sh; chmod +x install_main.sh; ./install_main.sh; rm install_main.sh;```

After the script have downloaded the files, fill in the settings at config.pm. The one that is important is DB root password.
Then run setup_database.pl. It is now safe to remove the DB root password from config.pm

The core system is now running, but without data. Start by adding some networks. The easiest way to do that is just use the tools/create_net.pl or tools/create_net_range.pl

Usage: create_net.pl ip_base net_size dhcp name
  Example tools/create_net.pl 213.184.213.0 25 0 Server <br />
  Will create 213.184.213.0/25 with dhcp disabled and the name Server

Usage: create_net_range.pl first_ip_base net_size numer_of_networks dhcp name
  Example: tools/create_net_range.pl 213.184.214.0 25 4 1 DE<br />
  Will create 213.184.214.0/25 213.184.214.128/25 213.184.215.0/25 213.184.215.128/25 with dhcp enabled and the names DE-0 DE-1 DE-2 DE-3

The dhcp/dns config is not created automatic, you will have to run update_config.pl this would also restart/reload the services

The dlink system is included in this package under dlinkac. Read the readme.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">LCS</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Ole Mathias</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
