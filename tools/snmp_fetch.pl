#!/usr/bin/perl
use DBI;
use Time::HiRes qw(time);
use lib '/lcs/include';
require "/lcs/include/config.pm";
   use Net::SNMP qw(:snmp);
   use Data::Dumper qw(Dumper);
   use syslog;

syslog->log(message => "Started",type => "1",priority => "9",from => "snmpfetch");

   # Connect to the database.
   $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

   # Connect to InfluxDB
   my $ix = AnyEvent::InfluxDB->new(
               server => 'http://localhost:8086',
               username => 'admin',
               password => 'password',
           );

   my $OID_ifName = '1.3.6.1.2.1.31.1.1.1.1';
   my $OID_in     = '1.3.6.1.2.1.31.1.1.1.6';
   my $OID_out    = '1.3.6.1.2.1.31.1.1.1.10';
   my $OID_speed  = '1.3.6.1.2.1.31.1.1.1.15';
   my $OID_desc  =  '1.3.6.1.2.1.31.1.1.1.18';
   my $OID_status = '1.3.6.1.2.1.2.2.1.8';
   my $OID_ifPhysAddress = '1.3.6.1.2.1.2.2.1.6';

   my $OID_sysDescr = '1.3.6.1.2.1.1.1';
   my $OID_sysUpTime = '1.3.6.1.2.1.1.3';

   @OID_port_request = ($OID_ifName,$OID_in,$OID_out,$OID_speed,$OID_desc,$OID_status,$OID_ifPhysAddress);

   my @port_data = ();

 our $qswitch = $dbh->prepare(<<"EOF")
Select * from switches WHERE ip IS NOT NULL AND configured = '1' AND latency_ms IS NOT NULL AND snmp_version IS NOT NULL
EOF
   or die "Couldn't prepare qswitch";

   my @port_data = ();

   my @switches = ();
populate_switches();

for my $refswitch (@switches) {
  my %switch = %{$refswitch};
  $switch{'start'} = time;
print "START: Polling $switch{'sysname'} ($switch{'mgtip'}) \n";
syslog->log(message => "POOLING START",type => "11",priority => "9",from => "sw".$switch{'id'});
       my ($session, $error) = Net::SNMP->session(
          -hostname    => shift ||  $switch{'mgtip'},
          -community   => shift ||  $switch{'community'},
          -translate   => [-octetstring => 0],
          -version     =>  $switch{'version'},
       );
       if (!defined $session) {
          printf "ERROR: %s.\n", $error;
          exit 1;
       }

our $qport = $dbh->prepare(<<"EOF")
SELECT ifIndex FROM ports WHERE switch_id = $switch{'id'}
EOF
         or die "Couldn't prepare qport";

       $qport->execute()
         or die "Couldn't get ports";

       while (my $ref = $qport->fetchrow_hashref()) {
my @OID_port_request_local = ();

foreach my $n (@OID_port_request) {
  push @OID_port_request_local, $n.".".$ref->{'ifIndex'};
}
my $result = $session->get_request( -varbindlist => [ @OID_port_request_local ] );
if (!defined $result) {
   printf "ERROR: %s\n", $session->error();
   $session->close();
   exit 1;
}

my $switch = $switch{'id'};
my $port = $ref->{'ifIndex'};
foreach my $n (@OID_port_request_local) {
  if(oid_base_match($OID_ifName,$n)) {
    $port_data{$switch}{$port}{"name"} = $result->{$n};
  }elsif(oid_base_match($OID_in,$n)) {
      $port_data{$switch}{$port}{"in"} = $result->{$n};
    }elsif(oid_base_match($OID_out,$n)) {
        $port_data{$switch}{$port}{"out"} = $result->{$n};
      }elsif(oid_base_match($OID_speed,$n)) {
          $port_data{$switch}{$port}{"speed"} = $result->{$n};
        }elsif(oid_base_match($OID_desc,$n)) {
            $port_data{$switch}{$port}{"desc"} = $result->{$n};
          }elsif(oid_base_match($OID_status,$n)) {
              $port_data{$switch}{$port}{"status"} = $result->{$n};
            }elsif(oid_base_match($OID_ifPhysAddress,$n)) {
                $port_data{$switch}{$port}{"ifPhysAddress"} = unpack( 'H*', $result->{$n});
              }
}
}
$session->close();
  print "STOP: Polling $switch{'sysname'} ($switch{'mgtip'}) ".(time - $switch{'start'}) ."\n";
  syslog->log(message => "POOLING STOP ".(time - $switch{'start'}) . "s",type => "11",priority => "9",from => "sw".$switch{'id'});
}

foreach my $switch (sort keys %port_data) {
  #print "Switch: $switch \n";
    foreach my $port (keys %{ $port_data{$switch} }) {
      #print "Port: $port \n";
      my $if_name = $port_data{$switch}{$port}{'name'};
      my $if_speed = $port_data{$switch}{$port}{'speed'};
      my $if_desc = $port_data{$switch}{$port}{'desc'};
      my $if_in = $port_data{$switch}{$port}{'in'};
      my $if_out = $port_data{$switch}{$port}{'out'};
      my $if_status = $port_data{$switch}{$port}{'status'};
      my $if_PhysAddress = $port_data{$switch}{$port}{'ifPhysAddress'};

      $sql2 = "SELECT ports.id,ports.ifHighSpeed,switches.name, switches.id AS swid, ports.status FROM ports JOIN switches WHERE ports.switch_id = '$switch' AND ports.ifName = '$if_name' AND switches.id = ports.switch_id";
      #print $sql2 ."\n";
      $sth2 = $dbh->prepare($sql2);

      $sth2->execute or die "SQL Error: $DBI::errstr\n";

      while (my $ref = $sth2->fetchrow_hashref()) {
        my $id = $ref->{'id'};
        my $sw_id = $ref->{'swid'};
        my $switch_name = $ref->{'name'};
        my $port_speed = $ref->{'ifHighSpeed'};
        my $port_status = $ref->{'status'};

        $epoc = time();

        #UPDATE THE DATABASE WITH THE LASTEST DATA
        $sql3 = "SELECT ports_poll.bytes_in, ports_poll.bytes_out, ports_poll.time FROM `lcs`.`ports_poll` WHERE ports_poll.port = $id ORDER BY time DESC LIMIT 1";
        $sth3 = $dbh->prepare($sql3);
        $sth3->execute or die "SQL Error: $DBI::errstr\n";

        while (my $ref = $sth3->fetchrow_hashref()) {

  $time_gone =  $epoc - int($ref->{'time'});

if($time_gone > 0) {
  $current_bytes_in =  ($if_in - int(($ref->{'bytes_in'}))) / $time_gone;
  $current_bytes_out = ($if_out - int(($ref->{'bytes_out'}))) / $time_gone;
} else {
$current_bytes_in =  0;
$current_bytes_out = 0;
}

if($port_status != $if_status) {
  if($if_speed == 1000 && $if_status == 1) {
  syslog->log(message => "Port: $if_name is up (1000mb/s) $port_status - $if_status",type => "13",priority => "5",from => "sw".$switch);
  }
  elsif($if_speed == 100  && $if_status == 1) {
  syslog->log(message => "Port: $if_name is up (100mb/s) $if_status",type => "13",priority => "5",from => "sw".$switch);
  }
  elsif($if_speed == 10   && $if_status == 1) {
  syslog->log(message => "Port: $if_name is down $if_status",type => "13",priority => "4",from => "sw".$switch);
  }
  elsif($if_status == 2) {
  syslog->log(message => "Port: $if_name is down $if_status",type => "13",priority => "4",from => "sw".$switch);
  }
  else {
    syslog->log(message => "Port: $if_name is unknown ($if_speed) - Status: $if_status",type => "13",priority => "5",from => "sw".$switch);
  }
}


  $dbh->do("UPDATE `ports` SET `current_in` =  '$current_bytes_in',`current_out` =  '$current_bytes_out',`ifHighSpeed` = '$if_speed',`updated` =  '$epoc',`status` =  '$if_status',`ifPhysAddress` =  '$if_PhysAddress' WHERE  `id` ='$id'");
        }

        $dbh->do("INSERT INTO `lcs`.`ports_poll` (`time`, `switch`, `port`, `bytes_in`, `bytes_out`) VALUES ($epoc, '$sw_id', '$id', '$if_in', '$if_out')");

        $cv = AE::cv;
           $ix->write(
               database => 'lcs',
               data => [
                   {
                       measurement => 'net',
                       tags => {
                           host =>  $switch_name,
                           lcs_id => $sw_id,
                           interface => $if_name,
                           lcs_interface_id => $id
                       },
                       fields => {
                           bytes_recv => $if_in,
                           bytes_sent => $if_out,
                       },
                       time => time()
                   }
               ],

               on_success => $cv,
               on_error => sub {
                   $cv->croak("Failed to write data: @_");
               }
           );
           $cv->recv;

      }

    }
  }

   exit 0;

   sub populate_switches
   {
     @switches = ();
     $qswitch->execute()
       or die "Couldn't get switch";

     while (my $ref = $qswitch->fetchrow_hashref()) {
       push @switches, {
         'sysname' => $ref->{'name'},
         'id' => $ref->{'id'},
         'mgtip' => $ref->{'ip'},
         'community' => $lcs::config::snmp_community,
         'version' => $ref->{'snmp_version'},
         'model' => $ref->{'model'}
       };
     }
   }
