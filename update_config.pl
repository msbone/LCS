#!/usr/bin/perl -w
use make_dhcp;
use make_dns;

make_dhcp-> make_dhcp_config();
make_dns-> make_dns_config();
