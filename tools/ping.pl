#!/usr/bin/perl
use DBI;
use Net::Oping;

require "/lcs/include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select id,ip from switches WHERE ip IS NOT NULL AND configured = '1'";
$sth = $dbh->prepare($sql);

while(true) {
  $ping = Net::Oping->new;
  $ping->timeout(0.2);
  $ping->ttl(8);

$sth->execute or die "SQL Error: $DBI::errstr\n";

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

    print "Switch: $switch : $latency \n";
    $epoc = time();
    $dbh->do("UPDATE  `switches` SET  `latency_ms` =  $latency,`updated` =  '$epoc' WHERE  `id` =$switch");
    $dbh->do("INSERT INTO  `lcs`.`switches_ping` (`switch` , `updated` , `latency_ms`) VALUES ( '$switch',  '$epoc',  $latency )");
  }
  sleep (1);
}
