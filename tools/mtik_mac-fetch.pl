#!/usr/bin/perl -w
use strict;
use warnings;
use lib '/lcs/include';
use Data::Dumper;
use vars qw($error_msg $debug);
use Mtik;
use MtikAC;

my $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = 'mtik'";
my $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  $Mtik::debug = 2;
  my($mtik_host) = $ref->{'ip'};
  my($mtik_username) = 'admin';
  my($mtik_password) = 'Dataparty15';
  print "Logging in to Mtik: $mtik_host ".$ref->{"name"}."\n";
Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");
#Get the fdb table
my %attrs;
my %queries;
my($retval,@results) = Mtik::mtik_query("/interface/ethernet/switch/unicast-fdb/print", \%attrs, \%queries);
#print Dumper @results;

foreach my $test (@results) {
my $time = time();
my $mac = $test->{'mac-address'};
my $port = $test->{'port'};
my $switch = $ref->{"id"};
if($port eq "ether1" or $port eq "switch1-cpu") {
  next;
}

#Get the correct id for this port
my $sql1 = "SELECT ports.id FROM ports WHERE ports.switch_id = $switch AND ports.ifName = '$port'";
my $sth1 = $dbh->prepare($sql1);
  $sth1->execute or die "SQL Error: $DBI::errstr\n";
my $port_found = "false";
while (my $ref1 = $sth1->fetchrow_hashref()) {
  $port = $ref1->{"id"};
  $port_found = "true";
}
if($port_found eq "false") {
  next;
}

my $found = "false";

my $sql1 = "SELECT switch,port FROM mac_table WHERE mac = '$mac'";
my $sth1 = $dbh->prepare($sql1);
  $sth1->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref1 = $sth1->fetchrow_hashref()) {
  $found = "true";
  if($port ne $ref1->{"port"} or $switch ne $ref1->{"switch"}) {
    #Mac moved, update.
$dbh->do("UPDATE  `lcs`.`mac_table` SET  `switch` =  '".$switch."',`port` =  '".$port."',`updated` =  '".$time."' WHERE  `mac_table`.`mac` =  '$mac'");
  }else {
    #Update the time
$dbh->do("UPDATE  `lcs`.`mac_table` SET  `updated` =  '".$time."' WHERE  `mac_table`.`mac` =  '$mac'");
  }
}
if($found eq "false") {
  #Create the mac
  $dbh->do("INSERT INTO `mac_table` (mac,port,switch,updated) VALUES ('$mac', '$port', '$switch', '$time')");
}
}
Mtik::logout;
}

#Get the arp from core
my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = 'ccr'";
my $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  $Mtik::debug = 2;
  my($mtik_host) = $ref->{'ip'};
  my($mtik_username) = 'admin';
  my($mtik_password) = 'Data15Party';
  print "Logging in to Mtik: $mtik_host ".$ref->{"name"}."\n";
  Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");

  my %attrs;
  my %queries;
  my($retval,@results) = Mtik::mtik_query("/ip/arp/print", \%attrs, \%queries);
  #print Dumper @results;
foreach my $test (@results) {
my $mac = $test->{'mac-address'};
my $ip = $test->{'address'};
my $sql1 = "SELECT mac FROM mac_table WHERE mac = '$mac'";
my $sth1 = $dbh->prepare($sql1);
  $sth1->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref1 = $sth1->fetchrow_hashref()) {
if($mac eq $ref1->{"mac"}) {
  $dbh->do("UPDATE  `lcs`.`mac_table` SET  `ip` =  '$ip' WHERE  `mac_table`.`mac` =  '$mac'");
}
}


}
}
