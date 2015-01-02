#!/usr/bin/perl -w
use make_dhcp;
use make_dns;


#Make the dhcp and dns config so the server will start
make_dhcp-> make_dhcp_config();
system("service isc-dhcp-server restart");
make_dns-> make_dns_config();
system("service bind9 reload");
