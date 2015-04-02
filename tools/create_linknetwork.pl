#!/usr/bin/perl -w
use Net::Netmask;
use DBI;

require "/lcs/include/config.pm";

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 2) {

  print "\nUsage: create_linknetwork.pl first_ip_base number_of_networks\n";
  print "Example: create_linknetwork.pl 213.184.213.0 5\n";
  exit;
}

$first_ip=$ARGV[0];
$netmask=30;
$number_of_networks=$ARGV[1];

$network_created = 0;

$cidr = $first_ip."/".$netmask;
$block = new Net::Netmask ($cidr);

while($network_created < $number_of_networks) {
  print $block->base()."/".$netmask."\n";

  $block = $block->nextblock(1);
  $network_created++;
}
