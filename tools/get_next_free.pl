#!/usr/bin/perl -w
use Net::Netmask;
use DBI;
no warnings;

require "/lcs/include/config.pm";

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 1) {

  #example create_net_range.pl 213.184.214.0 25 4 1 DE
  #Will create 213.184.214.0/25 213.184.214.128/25 213.184.215.0/25 213.184.215.128/25

  print "\nUsage: get_free_ips.pl network_id\n";
  print "Example: get_free_ips.pl 200 \n";
  exit;
}

$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

$network_id=$ARGV[0];

$sql = "select id, network, subnet FROM netlist WHERE id = $network_id";
$sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  $net_id = $ref->{'id'};
  $network_id = $ref->{'network'};
  $network_subnet = $ref->{'subnet'};

  $block = new Net::Netmask ($network_id, $network_subnet);

  $sql2 = "SELECT id, ip FROM switches WHERE ip IS NOT NULL AND net_id = $net_id";
  $sth2 = $dbh->prepare($sql2);

  $sth2->execute or die "SQL Error: $DBI::errstr\n";

  $rows = $sth2->rows + 2;

  print $block->nth($rows)."\n";
}
