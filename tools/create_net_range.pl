#!/usr/bin/perl -w
use Net::Netmask;
use DBI;

require "include/config.pm";

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 5) {

  #example create_net_range.pl 213.184.214.0 25 4 1 DE
  #Will create 213.184.214.0/25 213.184.214.128/25 213.184.215.0/25 213.184.215.128/25

  print "\nUsage: create_net_range.pl first_ip_base net_size numer_of_networks dhcp name \n";
  print "Example: create_net_range.pl 213.184.214.0 25 4 1 DE \n";
  exit;
}

$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

$first_ip=$ARGV[0];
$netmask=$ARGV[1];
$number_of_networks=$ARGV[2];
$dhcp=$ARGV[3];
$name=$ARGV[4];

$network_created = 0;

$cidr = $first_ip."/".$netmask;
$block = new Net::Netmask ($cidr);

while($network_created < $number_of_networks) {
  print $block->base()."\n";
  print $block->mask()."\n";
  $dbh->do("INSERT INTO netlist (`name`,`network`,`subnet`, `dhcp`, `desc`) VALUES ('".$name."-".$network_created."', '".$block->base()."','".$block->mask()."','".$dhcp."','create_net_range.pl')");

  $block = $block->nextblock(1);
  $network_created++;
}
