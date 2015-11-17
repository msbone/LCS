#! /usr/local/bin/perl
   use strict;
   use warnings;
   use Net::SNMP qw(:snmp);
   use lib '/lcs/include';
   require "/lcs/include/config.pm";
   use DBI;
   my $OID_fdb = '1.3.6.1.2.1.17.7.1.2.2.1.2';


   my $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
   my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = 'dgs24'";
   my $sth = $dbh->prepare($sql);
     $sth->execute or die "SQL Error: $DBI::errstr\n";

   while (my $ref = $sth->fetchrow_hashref()) {
   my ($session, $error) = Net::SNMP->session(
      -hostname    => shift || $ref->{'ip'},
      -community   => shift || 'teknisk15',
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

   # Now initiate the SNMP message exchange.
   snmp_dispatcher();
   $session->close();
   for my $oid (oid_lex_sort(keys %table)) {
         print mac_dec_to_hex(substr($oid, 29)) . "\n";

         my $time = time();
         my $mac = mac_dec_to_hex(substr($oid, 29));
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
           print "Added";
         }
   }
}
   exit 0;

   sub table_callback
   {
      my ($session, $table) = @_;

      my $list = $session->var_bind_list();

      if (!defined $list) {
         printf "ERROR: %s\n", $session->error();
         return;
      }
      my @names = $session->var_bind_names();
      my $next  = undef;

      while (@names) {
         $next = shift @names;
         if (!oid_base_match($OID_fdb, $next)) {
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
