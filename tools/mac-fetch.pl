#! /usr/local/bin/perl
   use strict;
   use warnings;
   use lib '/lcs/include';
   require "/lcs/include/config.pm";
   use DBI;
   use Net::SNMP qw(:snmp);
   use Data::Dumper;
   use Mtik;

our $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

#Get the Mikrotik forward database from Mikrotik Switches
Mtik_fdb();
#Get the Dlink forward database from Dlink Switches
Dlink_fdb();
#Get the Mikrotik arp from Mikrotik coreswitches
Mtik_arp();
#Get the Cisco arp from Cisco coreswitches
Cisco_arp();

#functions under here
   sub Cisco_arp {
     my $OID_arp = '1.3.6.1.2.1.4.22.1.2';
     my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = '3560g'";
     my $sth = $dbh->prepare($sql);
       $sth->execute or die "SQL Error: $DBI::errstr\n";
     while (my $ref = $sth->fetchrow_hashref()) {
     my ($session, $error) = Net::SNMP->session(
        -hostname    => shift || $ref->{'ip'},
        -community   => shift || $lcs::config::snmp_community,
        -nonblocking => 1,
        -translate   => [-octetstring => 0],
        -version     => 'snmpv2c',
     );
     if (!defined $session) {
        printf "ERROR: %s.\n", $error;
        exit 1;
     }
     my %table;
     my $result = $session->get_bulk_request(
        -varbindlist    => [ $OID_arp ],
        -callback       => [ \&table_callback, \%table ],
        -maxrepetitions => 10,
     );
     if (!defined $result) {
        printf "ERROR: %s\n", $session->error();
        $session->close();
        exit 1;
     }
     snmp_dispatcher();
     $session->close();
     for my $oid (oid_lex_sort(keys %table)) {
       my $mac = unpack 'H*', $table{$oid};
       $mac =~ s/(..)(?=.)/$1:/g;
       $mac = lc $mac;
       my @t = split(/\./, $oid);
       my $ip = lc $t[11].".".$t[12].".".$t[13].".".$t[14];
       my $sql1 = "SELECT mac FROM mac_table WHERE mac = '$mac'";
       my $sth1 = $dbh->prepare($sql1);
         $sth1->execute or die "SQL Error: $DBI::errstr\n";
       while (my $ref1 = $sth1->fetchrow_hashref()) {
       if($mac eq $ref1->{"mac"}) {
         $dbh->do("UPDATE  `lcs`.`mac_table` SET  `ip` =  '$ip' WHERE  `mac_table`.`mac` =  '$mac'");
       }}}}
 }

   sub Mtik_arp {
     my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = 'ccr'";
     my $sth = $dbh->prepare($sql);
       $sth->execute or die "SQL Error: $DBI::errstr\n";
     while (my $ref = $sth->fetchrow_hashref()) {
       $Mtik::debug = 2;
       my($mtik_host) = $ref->{'ip'};
       my($switch) = $ref->{'id'};
       my($mtik_username) = $lcs::config::mtik_user_core;
       my($mtik_password) = $lcs::config::mtik_pass_core;
       #print "Logging in to Mtik: $mtik_host ".$ref->{"name"}."\n";
       Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");
       my %attrs;
       my %queries;
       my($retval,@results) = Mtik::mtik_query("/ip/arp/print", \%attrs, \%queries);
       my $found = 0;
     foreach my $test (@results) {
       if($test->{'mac-address'} ne '') {
     my $mac = lc $test->{'mac-address'};
     my $ip = lc $test->{'address'};
     my $port = $test->{'interface'};
     my $sql1 = "SELECT mac FROM mac_table WHERE mac = '$mac'";
     my $sth1 = $dbh->prepare($sql1);
       $sth1->execute or die "SQL Error: $DBI::errstr\n";

     while (my $ref1 = $sth1->fetchrow_hashref()) {
     if($mac eq $ref1->{"mac"}) {
       $dbh->do("UPDATE  `lcs`.`mac_table` SET  `ip` =  '$ip' WHERE  `mac_table`.`mac` =  '$mac'");
       $found = 1;
     }
   }

    if($found  == 0){
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
      my $time = time();
      $dbh->do("INSERT INTO `mac_table` (mac,port,ip,switch,updated) VALUES ('$mac', '$port','$ip', '$switch', '$time')");
      print "Added mac: $mac port: $port IP: $ip \n";
    }
   }
 }
  }
   }

   sub Dlink_fdb {
   my $OID_fdb = '1.3.6.1.2.1.17.7.1.2.2.1.2';
   my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = 'dgs24'";
   my $sth = $dbh->prepare($sql);
     $sth->execute or die "SQL Error: $DBI::errstr\n";

   while (my $ref = $sth->fetchrow_hashref()) {
   my ($session, $error) = Net::SNMP->session(
      -hostname    => shift || $ref->{'ip'},
      -community   => shift || $lcs::config::snmp_community,
      -nonblocking => 1,
      -translate   => [-octetstring => 0],
      -version     => 'snmpv2c',
   );
   if (!defined $session) {
      printf "ERROR: %s.\n", $error;
      exit 1;
   }
   my %table; # Hash to store the results
   my $result = $session->get_bulk_request(
      -varbindlist    => [ $OID_fdb ],
      -callback       => [ \&table_callback, \%table ],
      -maxrepetitions => 10,
   );
   if (!defined $result) {
      printf "ERROR: %s\n", $session->error();
      $session->close();
      exit 1;
   }
   snmp_dispatcher();
   $session->close();
   for my $oid (oid_lex_sort(keys %table)) {
         #print mac_dec_to_hex(substr($oid, 29)) . "\n";
         my $time = time();
         my $mac = lc mac_dec_to_hex(substr($oid, 29));
         my $port = $table{$oid};
         my $switch = $ref->{"id"};
         if($port eq "1") {
           next;
         }
#Get the correct id for this port
my $sql1 = "SELECT ports.id FROM ports WHERE ports.switch_id = $switch AND ports.ifIndex = $port";
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
         my $sql2 = "SELECT switch,port FROM mac_table WHERE mac = '$mac'";
         my $sth2 = $dbh->prepare($sql2);
           $sth2->execute or die "SQL Error: $DBI::errstr\n";

         while (my $ref2 = $sth2->fetchrow_hashref()) {
           $found = "true";
           if($port ne $ref2->{"port"} or $switch ne $ref2->{"switch"}) {
             #Mac moved, update.
              $dbh->do("UPDATE  `lcs`.`mac_table` SET  `switch` =  '".$switch."',`port` =  '".$port."',`updated` =  '".$time."',`ip` =  NULL WHERE  `mac_table`.`mac` =  '$mac'");
                        print "Updated $mac to $switch:$port \n";
           }else {
             #Update the time
             $dbh->do("UPDATE  `lcs`.`mac_table` SET  `updated` =  '".$time."' WHERE  `mac_table`.`mac` =  '$mac'");
           }
         }
         if($found eq "false") {
           #Create the mac
           $dbh->do("INSERT INTO `mac_table` (mac,port,switch,updated) VALUES ('$mac', '$port', '$switch', '$time')");
         }}}
   }

   sub Mtik_fdb {
     my $sql = "SELECT ip,name,id,model FROM switches WHERE switches.model = 'mtik'";
     my $sth = $dbh->prepare($sql);
       $sth->execute or die "SQL Error: $DBI::errstr\n";

     while (my $ref = $sth->fetchrow_hashref()) {
       $Mtik::debug = 2;
       my($mtik_host) = $ref->{'ip'};

    my $mtik_username = "admin";
    my $mtik_password = $lcs::config::mtik_pass;

       #print "Logging in to Mtik: $mtik_host ".$ref->{"name"}."\n";
     Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");
     #Get the fdb table
     my %attrs;
     my %queries;
     my($retval,@results) = Mtik::mtik_query("/interface/ethernet/switch/unicast-fdb/print", \%attrs, \%queries);
     #print Dumper @results;
     foreach my $test (@results) {
     my $time = time();
     my $mac = lc $test->{'mac-address'};
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
     my $sql2 = "SELECT switch,port FROM mac_table WHERE mac = '$mac'";
     my $sth2 = $dbh->prepare($sql2);
       $sth2->execute or die "SQL Error: $DBI::errstr\n";
     while (my $ref2 = $sth2->fetchrow_hashref()) {
       $found = "true";
       if($port ne $ref2->{"port"} or $switch ne $ref2->{"switch"}) {
         #Mac moved, update.
     $dbh->do("UPDATE  `lcs`.`mac_table` SET  `switch` =  '".$switch."',`port` =  '".$port."',`updated` =  '".$time."',`ip` =  NULL WHERE  `mac_table`.`mac` =  '$mac'");
     print "Updated $mac to $switch:$port \n";
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
   }

   sub table_callback
   {
      my ($session, $table) = @_;

      my $list = $session->var_bind_list();

my $OID_fdb = '1.3.6.1.2.1.17.7.1.2.2.1.2';
my $OID_arp = '1.3.6.1.2.1.4.22.1.2';
      if (!defined $list) {
         printf "ERROR: %s\n", $session->error();
         return;
      }
      my @names = $session->var_bind_names();
      my $next  = undef;
      while (@names) {
         $next = shift @names;
         if (!oid_base_match($OID_arp, $next) && !oid_base_match($OID_fdb, $next)) {
            return; # Table is done.
         }
         $table->{$next} = $list->{$next};
      }
      my $result = $session->get_bulk_request(
         -varbindlist    => [ $next ],
         -maxrepetitions => 10,
      );
      if (!defined $result) {
         printf "ERROR: %s.\n", $session->error();
      }
      return;
   }

   sub mac_dec_to_hex{
     my $dec_mac = "@_";
     my @octets;

     foreach my $octet (split('\.', $dec_mac)){
       push(@octets, sprintf("%02x", $octet));
     }

     return join(':', @octets);
   }
