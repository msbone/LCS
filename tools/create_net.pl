#!/usr/bin/perl -w
use Net::Netmask;
use DBI;

require "/lcs/include/config.pm";

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 4) {

  #example create_net.pl 213.184.214.0 25 4 1 DE
  #Will create 213.184.214.0/25

  print "\nUsage: create_net_range.pl ip_base net_size dhcp name \n";
  print "Example: create_net_range.pl 213.184.213.128 25 1 Crew \n";
  exit;
}

$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

$first_ip=$ARGV[0];
$netmask=$ARGV[1];
$dhcp=$ARGV[2];
$name=$ARGV[3];


$cidr = $first_ip."/".$netmask;
$block = new Net::Netmask ($cidr);

  print $block->base()."\n";
  print $block->mask()."\n";
  $dbh->do("INSERT INTO netlist (`name`,`network`,`subnet`, `dhcp`, `desc`) VALUES ('".$name."', '".$block->base()."','".$block->mask()."','".$dhcp."','create_net.pl')");
