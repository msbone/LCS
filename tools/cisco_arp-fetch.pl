#! /usr/local/bin/perl
   use strict;
   use warnings;
   use Net::SNMP qw(:snmp);
   use lib '/lcs/include';
   require "/lcs/include/config.pm";
   use DBI;
   my $OID_arp = '1.3.6.1.2.1.4.22.1.2';

   my $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
   my $sql = "SELECT ip,name,id FROM switches WHERE switches.model = '3560g'";
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
      -varbindlist    => [ $OID_arp ],
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

   # Print the results, specifically formatting ifPhysAddress.

   for my $oid (oid_lex_sort(keys %table)) {
     my $mac = unpack 'H*', $table{$oid};
     $mac =~ s/(..)(?=.)/$1:/g;
     my @t = split(/\./, $oid);
     my $ip = $t[11].".".$t[12].".".$t[13].".".$t[14];
     my $sql1 = "SELECT mac FROM mac_table WHERE mac = '$mac'";
     my $sth1 = $dbh->prepare($sql1);
       $sth1->execute or die "SQL Error: $DBI::errstr\n";
       print $mac." - ".$ip." \n";
     while (my $ref1 = $sth1->fetchrow_hashref()) {
     if($mac eq $ref1->{"mac"}) {
       $dbh->do("UPDATE  `lcs`.`mac_table` SET  `ip` =  '$ip' WHERE  `mac_table`.`mac` =  '$mac'");
     }
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
         if (!oid_base_match($OID_arp, $next)) {
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
