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

   my $OID_ifTable = '1.3.6.1.2.1.31.1.1';
   my $OID_ifPhysAddress = '1.3.6.1.2.1.2.2.1.6';

   my $OID_ifName = '136121311111';
   my $OID_in     = '136121311116';
   my $OID_out    = '1361213111110';
   my $OID_speed  = '1361213111115';
   my $OID_desc  =  '1361213111118';

   my $OID_sysDescr = '1.3.6.1.2.1.1.1';
   my $OID_sysUpTime = '1.3.6.1.2.1.1.3';

   @OID_system = ($OID_sysDescr,$OID_sysUpTime);

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
          -nonblocking => 1,
          -translate   => [-octetstring => 0],
          -version     =>  $switch{'version'},
       );
       if (!defined $session) {
          printf "ERROR: %s.\n", $error;
          exit 1;
       }
       my %table; # Hash to store the results
       my $result = $session->get_bulk_request(
          -varbindlist    => [ $OID_ifTable ],
          -callback       => [ \&table_callback, \%table ],
          -maxrepetitions => 10,
       );
       if (!defined $result) {
          printf "ERROR: %s\n", $session->error();
          $session->close();
          exit 1;
       }
       # Now initiate the SNMP message exchange.
       snmp_dispatcher();
$session->close();
       for my $oid (oid_lex_sort(keys %table)) {
          if (!oid_base_match($OID_ifPhysAddress, $oid)) {
            my @t = split(/\./, $oid);
            my $small_oid = @t[0].@t[1].@t[2].@t[3].@t[4].@t[5].@t[6].@t[7].@t[8].@t[9].@t[10];
            my $port = @t[11];
            my $switch = $switch{'id'};

            if($small_oid eq $OID_ifName) {
            $port_data{$switch}{$port}{"name"} = $table{$oid};
            }elsif($small_oid eq $OID_in) {
           $port_data{$switch}{$port}{"in"} = $table{$oid};
            }elsif($small_oid eq $OID_out) {
           $port_data{$switch}{$port}{"out"} = $table{$oid};
            }elsif($small_oid eq $OID_speed) {
           $port_data{$switch}{$port}{"speed"} = $table{$oid};
            }elsif($small_oid eq $OID_desc) {
           $port_data{$switch}{$port}{"desc"} = $table{$oid};
            }
          }
       }

syslog->log(message => "POOLING STOP ".(time - $switch{'start'}) . "s",type => "11",priority => "9",from => "sw".$switch{'id'});
  print "STOP: Polling $switch{'sysname'} ($switch{'mgtip'}) \n";
}

foreach my $switch (sort keys %port_data) {
  #print "Switch: $switch \n";
    foreach my $port (keys %{ $port_data{$switch} }) {
      #print "Port: $port \n";
my $port_ok = 0;
my $descr = $port_data{$switch}{$port}{'name'};

      #JUNIPER
      if ($descr =~ m/(fe|ge|xe|et)-/ && $descr !~ m/\./) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      #Cisco
      elsif ($descr =~ m/^Gi[0-9]\/[0-9]/ || $descr =~ m/^Po[0-9]/) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      #Netgear
      elsif ($descr =~ m/^g[0-9]/ || $descr =~ m/^l[0-9]/) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      #linux eth
      elsif ($descr =~ m/^eth[0-9]/ && $descr !~ m/\./) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      #linux eth
      elsif ($descr =~ m/^switch[0-9]/) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      else {
        $port_ok = 0;
      }
if($port_ok == 1) {
        my $if_name = $port_data{$switch}{$port}{'name'};
        my $if_speed = $port_data{$switch}{$port}{'speed'};
        my $if_desc = $port_data{$switch}{$port}{'desc'};
        my $if_in = $port_data{$switch}{$port}{'in'};
        my $if_out = $port_data{$switch}{$port}{'out'};

        #LETS CHECK IF THIS IS A NEW PORT, IF CREATE IT, IF NOT UPDATE
        $sql2 = "SELECT ports.id,ports.ifHighSpeed,switches.name, switches.id AS swid FROM ports JOIN switches WHERE ports.switch_id = '$switch' AND ports.ifName = '$if_name' AND switches.id = ports.switch_id";
        #print $sql2 ."\n";
        $sth2 = $dbh->prepare($sql2);

        $sth2->execute or die "SQL Error: $DBI::errstr\n";

        while (my $ref = $sth2->fetchrow_hashref()) {
          my $id = $ref->{'id'};
          my $sw_id = $ref->{'swid'};
          my $switch_name = $ref->{'name'};
          my $port_speed = $ref->{'ifHighSpeed'};

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

if($port_speed != $if_speed) {
  if($if_speed == 1000) {
  syslog->log(message => "Port: $if_name is up (1000mb/s)",type => "13",priority => "5",from => "sw".$switch);
  }
  elsif($if_speed == 100) {
  syslog->log(message => "Port: $if_name is up (100mb/s)",type => "13",priority => "5",from => "sw".$switch);
  }
  elsif($if_speed == 0) {
  syslog->log(message => "Port: $if_name is down",type => "13",priority => "4",from => "sw".$switch);
  }
  else {
    syslog->log(message => "Port: $if_name is unknown ($if_speed)",type => "13",priority => "5",from => "sw".$switch);
  }
}

    $dbh->do("UPDATE `ports` SET `current_in` =  '$current_bytes_in',`current_out` =  '$current_bytes_out',`ifHighSpeed` = '$if_speed',`updated` =  '$epoc' WHERE  `id` ='$id'");
          }

          $dbh->do("INSERT INTO `lcs`.`ports_poll` (`time`, `switch`, `port`, `bytes_in`, `bytes_out`) VALUES ($epoc, '$sw_id', '$id', '$if_in', '$if_out')");
        }

        if($sth2->rows == 0) {
          #ADD
          $epoc = time();
          $dbh->do("INSERT INTO `ports` (switch_id,ifName,ifIndex,ifHighSpeed) VALUES ('$switch', '$if_name','$port','$if_speed')");
          syslog->log(message => "Added $if_name($port)",type => "12",priority => "5",from => "sw".$switch);
        }

          #print "Name: $port_data{$switch}{$port}{'name'}\n";
          #print "Desc: $port_data{$switch}{$port}{'desc'}\n";
          #print "Speed: $port_data{$switch}{$port}{'speed'}\n";
          #print "In: $port_data{$switch}{$port}{'in'}\n";
          #print "Out: $port_data{$switch}{$port}{'out'}\n";
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


   sub table_callback
   {
      my ($session, $table) = @_;

      my $list = $session->var_bind_list();

      if (!defined $list) {
         printf "ERROR: %s\n", $session->error();
         return;
      }

      # Loop through each of the OIDs in the response and assign
      # the key/value pairs to the reference that was passed with
      # the callback.  Make sure that we are still in the table
      # before assigning the key/values.

      my @names = $session->var_bind_names();
      my $next  = undef;

      while (@names) {
         $next = shift @names;
         if (!oid_base_match($OID_ifTable, $next)) {
            return; # Table is done.
         }
         $table->{$next} = $list->{$next};
      }

      # Table is not done, send another request, starting at the last
      # OBJECT IDENTIFIER in the response.  No need to include the
      # calback argument, the same callback that was specified for the
      # original request will be used.

      my $result = $session->get_bulk_request(
         -varbindlist    => [ $next ],
         -maxrepetitions => 10,
      );

      if (!defined $result) {
         printf "ERROR: %s.\n", $session->error();
      }
      return;
   }

   sub cleandeadswitches() {
     #Clean the database of dead switches
     our $deadswitch = $dbh->prepare("select ports.id, switches.id AS swid from ports JOIN switches WHERE switches.latency_ms IS NULL AND ports.switch_id = switches.id") or die "Couldn't prepare deadswitch";
     $deadswitch->execute() or die "Couldn't get switch";

       while (my $ref = $deadswitch->fetchrow_hashref()) {
         my $id = $ref->{'id'};
         my $swid = $ref->{'swid'};
         $epoc = time();
         $dbh->do("UPDATE `ports` SET `ifHighSpeed` =  NULL,`current_in` =  NULL,`current_out` =  NULL,`updated` =  '$epoc' WHERE  `id` ='$id'");
         $dbh->do("UPDATE `switches` SET latency_ms` `cpu_use` =  NULL,`uptime` =  NULL,`updated` =  '$epoc' WHERE  `id` ='$swid'");
       }
   }
