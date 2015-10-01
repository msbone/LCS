#!/usr/bin/perl
use DBI;
use Net::Oping;

require "/lcs/include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select id,ip from switches WHERE ip IS NOT NULL AND configured = '1'";
$sth = $dbh->prepare($sql);

while(true) {
$sth->execute or die "SQL Error: $DBI::errstr\n";

if($sth->rows > 0) {

$ping = Net::Oping->new;
$ping->timeout(1.0);
$ping->ttl(22);

while (my $ref = $sth->fetchrow_hashref()) {
my $switch = $ref->{'id'};
my $ip = $ref->{'ip'};
$ping->host_add($ip);
$ip_to_switch{$ip} = $switch;
}

my $result = $ping->ping();
  die $ping->get_error if (!defined($result));

  while (my ($ip, $latency) = each %$result) {
    my $switch = $ip_to_switch{$ip};
    next if (!defined($switch));

    $latency //= "NULL";
$epoc = time();
    print "Switch: $switch : $latency at $epoc\n";
    $dbh->do("UPDATE  `switches` SET  `latency_ms` =  $latency,`updated` =  '$epoc' WHERE  `id` =$switch");
    $dbh->do("INSERT INTO  `lcs`.`switches_ping` (`switch` , `updated` , `latency_ms`) VALUES ( '$switch',  '$epoc',  $latency )");
  }
    sleep (2);
  } else {
    print "No switch found, ZzZzZz \n";
    sleep (10);
  }
}
