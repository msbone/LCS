#!/usr/bin/perl
use DBI;
use Net::Oping;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AnyEvent::InfluxDB;

require "/lcs/include/config.pm";


# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select id,ip,name from switches WHERE ip IS NOT NULL AND configured = '1'";
$sth = $dbh->prepare($sql);

# Connect to InfluxDB
my $ix = AnyEvent::InfluxDB->new(
            server => 'http://localhost:8086',
            username => 'admin',
            password => 'password',
        );

while(true) {
$sth->execute or die "SQL Error: $DBI::errstr\n";

if($sth->rows > 0) {

$ping = Net::Oping->new;
$ping->timeout(1.0);
$ping->ttl(22);

while (my $ref = $sth->fetchrow_hashref()) {
my $switch = $ref->{'id'};
my $ip = $ref->{'ip'};
my $name = $ref->{'name'};
$ping->host_add($ip);
$ip_to_switch{$ip} = $switch;
$ip_to_name{$ip} = $name;
}

my $result = $ping->ping();
  die $ping->get_error if (!defined($result));

  while (my ($ip, $latency) = each %$result) {
    my $switch = $ip_to_switch{$ip};
    my $name = $ip_to_name{$ip};
    next if (!defined($switch));

    $latency //= "NULL";
    $epoc = time();
    print "Switch: $name : $latency at $epoc\n";
    $dbh->do("UPDATE  `switches` SET  `latency_ms` =  $latency,`updated` =  '$epoc' WHERE  `id` =$switch");
    $dbh->do("INSERT INTO  `lcs`.`switches_ping` (`switch` , `updated` , `latency_ms`) VALUES ( '$switch',  '$epoc',  $latency )");

if($latency == "NULL"){
$latency = 0;
}

    $cv = AE::cv;
       $ix->write(
           database => 'lcs',
           data => [
               {
                   measurement => 'ping',
                   tags => {
                       host =>  $name,
                       lcs_id => $switch,
                   },
                   fields => {
                       value => $latency,
                   },
               }
           ],

           on_success => $cv,
           on_error => sub {
               $cv->croak("Failed to write data: @_");
           }
       );
       $cv->recv;

  }
    sleep (2);
  } else {
    print "No switch found, ZzZzZz \n";
    sleep (10);
  }
}
