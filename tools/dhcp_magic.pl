#!/usr/bin/perl
use File::Copy;
use Time::Local;
use NetAddr::IP;
use DBI;

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use AnyEvent::InfluxDB;

require "/lcs/include/config.pm";
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

# Connect to InfluxDB
my $ix = AnyEvent::InfluxDB->new(
            server => 'http://localhost:8086',
            username => 'admin',
            password => 'password',
        );

$dbh->do("TRUNCATE dhcp_leases"); #Tømmer dhcp_leases sa vi kan legge inn alt pånytt

my $leasefile = '/var/lib/dhcp/dhcpd.leases';
my $tempfile  = '/tmp/dhcpd.leases';
copy($leasefile,$tempfile) or die "Copy failed: $!";

open LEASES, "< $tempfile" or die $!;
my @lines = <LEASES>;
close LEASES;

my $ip;
my $mac='                 ';
my $end_date_time;
my $start_date_time;
my $name;
my @used_ip;

foreach $line (@lines){
        if ($line=~/lease\s(\d+\.\d+\.\d+\.\d+)/){
                $ip=$1;
                $readit = 1;
                $name="";
                $mac='                 ';
        }
        if ($readit && $line=~/starts\s\d\s(\d+\/\d+\/\d+\s\d+:\d+:\d+)\;/){
                my ($year,$mon,$mday,$hour,$min,$sec) = split(/[\s.:|\/]+/, $1);
                $start_date_time = timelocal($sec,$min,$hour,$mday,$mon-1,$year);
  }
        if ($readit && $line=~/ends\s\d\s(\d+\/\d+\/\d+\s\d+:\d+:\d+)\;/){
my ($year,$mon,$mday,$hour,$min,$sec) = split(/[\s.:|\/]+/, $1);
$end_date_time = timelocal($sec,$min,$hour,$mday,$mon-1,$year);
        }
        if ($readit && $line =~/hardware\sethernet\s(.*?)\;/){
                $mac=$1;
        }
        if ($readit && $line =~/client-hostname\s"(.*?)"\;/){
                $name=$1;
        }
        if ($readit && $line=~/^}/){
                $end_date_time = $end_date_time + 7200;
                $start_date_time = $start_date_time + 7200;
                $epoc = time();
                if($epoc < $end_date_time) {
                  $sql = "select id, network, subnet FROM netlist WHERE dhcp = 1";
                  $sth = $dbh->prepare($sql);

                  $sth->execute or die "SQL Error: $DBI::errstr\n";
                  while (my $ref = $sth->fetchrow_hashref()) {
                    $net_id = $ref->{'id'};
                    $network_id = $ref->{'network'};
                    $network_subnet = $ref->{'subnet'};
                    my $network  = NetAddr::IP->new($network_id,$network_subnet);
                    my $ip2 = NetAddr::IP->new($ip);
                    if ($ip2->within($network)) {
                      foreach (@{$used_ip[$network_id]}) { if($_ eq $ip) {
                        $funnet = "true";
                      } }
                      if($funnet eq "false") {
                        push (@{$used_ip[$network_id]},($ip));
                        $dbh->do("INSERT INTO `dhcp_leases` (time,network,ip,mac,name) VALUES ('$start_date_time', '$net_id', '$ip', '$mac', '$name')");
                        $lease++;
                      }
                      $funnet = "false";
                      last;
                }
                  }
                }
                $readit = 0;
        }
}

$epoc = time();


$sql = "select id, network, name FROM netlist WHERE dhcp = 1";
$sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";
while (my $ref = $sth->fetchrow_hashref()) {
  $leases = 0;
  $net_id = $ref->{'id'};
  $network_id = $ref->{'network'};
  $network_name = $ref->{'name'};
  $epoc = time();
   $sql2 = "select id from dhcp_leases WHERE network = '$net_id'";
   $sth2 = $dbh->prepare($sql2);
   $sth2->execute or die "SQL Error: $DBI::errstr\n";
   $leases = $sth2->rows;

   $cv = AE::cv;
      $ix->write(
          database => 'lcs',
          data => [
              {
                  measurement => 'dhcp_leases',
                  tags => {
                      lcs_id => $net_id,
                      name => $network_name,
                  },
                  fields => {
                      leases => $leases,
                  },
              }
          ],

          on_success => $cv,
          on_error => sub {
              $cv->croak("Failed to write data: @_");
          }
      );
      $cv->recv;

   print "$network_id  - $leases \n";
}

print "Total leases: $lease\n";
