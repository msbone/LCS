#!/usr/bin/perl
use DBI;
use Net::Ping;

require "include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select * from switches WHERE ip IS NOT NULL";
$sth = $dbh->prepare($sql);

while(true) {

$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  my $p=Net::Ping->new('icmp');
  if ($p->ping($ref->{'ip'}, "1")){
    print "Pong $ref->{'ip'} alive \n";
    $dbh->do("UPDATE `switches` SET  `ping` = 1 WHERE id = '".$ref->{'id'}."'");
  } else {
    print "Pong $ref->{'ip'} dead \n";
    $dbh->do("UPDATE `switches` SET  `ping` = 0 WHERE id = '".$ref->{'id'}."'");
  }
}
}
