#! /usr/bin/perl
use POSIX;
use NetAddr::IP;
use DBI;

require "/lcs/include/config.pm";
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

$year = 2015;
my %months = (
Jan => "01",
Feb => "02",
Mar => "03",
Apr => "04",
May => "05",
Jun => "06",
Jul => "07",
Aug => "08",
Sep => "09",
Oct => "10",
Nov => "11",
Dec => "12"
);

open(SYSLOG, "tail -n 9999 -F /var/log/syslog |") or die "Unable to tail syslog: $!";
while (<SYSLOG>) {
  /(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d+)\s+(\d+:\d+:\d+).*DHCPACK on (\d+\.\d+\.\d+\.\d+) to (\S+)/ or next;
  my $date = $year . "-" . $months{$1} . "-" . $2 . " " . $3;
  my $machine = $5;
  print "$date $4\n";

  $sql = "select id, network, subnet FROM netlist WHERE dhcp = 1";
  $sth = $dbh->prepare($sql);

  $sth->execute or die "SQL Error: $DBI::errstr\n";
  while (my $ref = $sth->fetchrow_hashref()) {
    $network_id = $ref->{'network'};
    $network_subnet = $ref->{'subnet'};
    my $network  = NetAddr::IP->new($network_id,$network_subnet);
    my $ip = NetAddr::IP->new($4);
    if ($ip->within($network)) {
      $dbh->do("UPDATE `netlist` SET  `last_dhcp_request` =  '$date' WHERE  `network` ='$network_id'");
        last;
}
  }
}
close SYSLOG;
