#!/usr/bin/perl -w
use dlink;
use ciscoconf;
use stuff;
use Net::Netmask;
use DBI;

require "/lcs/config.pm";

#THE SCRIPT OF ALL SCRIPTS
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select * from switches WHERE model = 'dgs24' AND configured = 1";

$sth = $dbh->prepare($sql);
$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  print "We will start to ping $ref->{'name'} \n";
  $respond = stuff->ping(ip => $ref->{'ip'},tryes => "3");

  if ($respond == 0)
  {
    print "No able to ping $ref->{'name'} ($ref->{'ip'}), skipping \n";
  }else {
    $dlink = dlink->connect(ip => $ref->{'ip'},username => "admin",password => $lcs::config::dlink_pass, name => $ref->{'name'});
    $dlink -> save();
    $dlink->close;
    undef $dlink;
  }
}
