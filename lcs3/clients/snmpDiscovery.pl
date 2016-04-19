#!/usr/bin/perl
use DBI;
use Time::HiRes qw(time);
use Net::SNMP qw(:snmp);
use Data::Dumper qw(Dumper);


# Connect to the database.
$dbh = DBI->connect("dbi:mysql:lcs","root","Dataparty16") or die "Connection Error: $DBI::errstr\n";
my $OID_ifTable = '1.3.6.1.2.1.31.1.1.1.1';

our $qswitch = $dbh->prepare(<<"EOF")
SELECT  d.*, p.latencyMs, p.time pingTime
        FROM    devices d LEFT OUTER JOIN
        (SELECT  ping.deviceId,MAX(time) MaxDate FROM ping GROUP BY ping.deviceId)
        MaxDates ON d.id = MaxDates.deviceId LEFT OUTER JOIN
        ping p ON MaxDates.deviceId = p.deviceId
        AND MaxDates.MaxDate = p.time WHERE configured = true AND p.latencyMs IS NOT NULL
EOF
or die "Couldn't prepare qswitch";


my @port_data = ();
my @switches = ();
populate_switches();

for my $refswitch (@switches) {
  my %switch = %{$refswitch};
  $switch{'start'} = time;
print "START: discovery $switch{'sysname'} ($switch{'mgtip'}) \n";

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
            my @t = split(/\./, $oid);
            my $small_oid = @t[0].@t[1].@t[2].@t[3].@t[4].@t[5].@t[6].@t[7].@t[8].@t[9].@t[10];
            my $port = @t[11];
            my $switch = $switch{'id'};

            if(oid_base_match($OID_ifTable,$oid)) {
            $port_data{$switch}{$port}{"name"} = $table{$oid};
            }
       }

  print "STOP: discovery $switch{'sysname'} ($switch{'mgtip'}) \n";
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
      #Mikrotik
      elsif ($descr =~ m/^(ether|sfp|sfp-sfpplus)[0-9]/) {
      $port_ok = 1;
      #print $descr ."\n";
      }
	#Dlink
      elsif ($descr =~ m/^Slot[0-9]\/[0-9]/) {
      $port_ok = 1;
      #print $descr ."\n";
      }
      else {
        $port_ok = 0;
      #print $descr ."\n";
      }
if($port_ok == 1) {
        my $if_name = $port_data{$switch}{$port}{'name'};

        #if_name and $switch

        $sql2 = "SELECT ports.id, ports.ifIndex FROM ports JOIN devices WHERE ports.deviceId = '$switch' AND ports.name = '$if_name' AND devices.id = ports.deviceId";
        $sth2 = $dbh->prepare($sql2);

        $sth2->execute or die "SQL Error: $DBI::errstr\n";

        if($sth2->rows == 0) {
          $epoc = time();
          $dbh->do("INSERT INTO `ports` (deviceId,name,ifIndex,created) VALUES ('$switch', '$if_name','$port','$epoc')");
        print "Added : $port_data{$switch}{$port}{'name'}\n";
        } else {
        while (my $ref = $sth2->fetchrow_hashref()) {
        if($ref->{'ifIndex'} == null) {
        $dbh->do("UPDATE `lcs`.`ports` SET `ifIndex`='$port' WHERE `id`='".$ref->{'id'}."'");
        print "Added ifIndex on: $port_data{$switch}{$port}{'name'}\n";
        }
        }
        }
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
         'mgtip' => $ref->{'ipv4'},
         'community' => "teknisk16",
         'version' => "2",
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