#!/usr/bin/perl
use DBI;
use Net::Netmask;
use Net::Netmask;
package MtikAC;

require "/lcs/include/config.pm";

sub create_config {
  my $class = shift;
  my %args = @_;
  require "/lcs/include/config.pm";


  my $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
  my $sql = "SELECT netlist.subnet, switches.ip, switches.name, switches.id
  FROM switches
  JOIN netlist
  WHERE netlist.id = switches.net_id
  AND switches.configured =0
  AND switches.model = 'mtik'
  ORDER BY switches.name
  ";

  my $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";

  while (my $ref = $sth->fetchrow_hashref()) {

$network_block = new Net::Netmask ($ref->{'ip'}, $ref->{'subnet'});
my $sw_id =  $ref->{'id'};
my $ip_address = $ref->{'ip'};
my $cidr = $network_block->bits();
my $network = $network_block->base();
my $gateway = $network_block->nth(1);
my $password = $lcs::config::mtik_pass;
my $snmp = $lcs::config::snmp_community;
my $pin = "1337";

open(my $fh, '>', '/lcs/AC/mikrotik-config/sw-'.$sw_id.'.rsc');

$config = <<"EOF";
/password old-password="" new-password="$password" confirm-new-password="$password"
/interface ethernet
set [ find default-name=ether2 ] master-port=ether1
set [ find default-name=ether3 ] master-port=ether1
set [ find default-name=ether4 ] master-port=ether1
set [ find default-name=ether5 ] master-port=ether1
set [ find default-name=ether6 ] master-port=ether1
set [ find default-name=ether7 ] master-port=ether1
set [ find default-name=ether8 ] master-port=ether1
set [ find default-name=ether9 ] master-port=ether1
set [ find default-name=ether10 ] master-port=ether1
set [ find default-name=ether11 ] master-port=ether1
set [ find default-name=ether12 ] master-port=ether1
set [ find default-name=ether13 ] master-port=ether1
set [ find default-name=ether14 ] master-port=ether1
set [ find default-name=ether15 ] master-port=ether1
set [ find default-name=ether16 ] master-port=ether1
set [ find default-name=ether17 ] master-port=ether1
set [ find default-name=ether18 ] master-port=ether1
set [ find default-name=ether19 ] master-port=ether1
set [ find default-name=ether20 ] master-port=ether1
set [ find default-name=ether21 ] master-port=ether1
set [ find default-name=ether22 ] master-port=ether1
set [ find default-name=ether23 ] master-port=ether1
set [ find default-name=ether24 ] master-port=ether1
set [ find default-name=sfp1 ] master-port=ether1 name=sfp1-slave-local
/snmp community
set [ find default=yes ] name=$snmp
/interface ethernet switch port
set 1 isolation-leakage-profile-override=2
set 2 isolation-leakage-profile-override=2
set 3 isolation-leakage-profile-override=2
set 4 isolation-leakage-profile-override=2
set 5 isolation-leakage-profile-override=2
set 6 isolation-leakage-profile-override=2
set 7 isolation-leakage-profile-override=2
set 8 isolation-leakage-profile-override=2
set 9 isolation-leakage-profile-override=2
set 10 isolation-leakage-profile-override=2
set 11 isolation-leakage-profile-override=2
set 12 isolation-leakage-profile-override=2
set 13 isolation-leakage-profile-override=2
set 14 isolation-leakage-profile-override=2
set 15 isolation-leakage-profile-override=2
set 16 isolation-leakage-profile-override=2
set 17 isolation-leakage-profile-override=2
set 18 isolation-leakage-profile-override=2
set 19 isolation-leakage-profile-override=2
set 20 isolation-leakage-profile-override=2
set 21 isolation-leakage-profile-override=2
set 22 isolation-leakage-profile-override=2
set 23 isolation-leakage-profile-override=2
/interface ethernet switch port-isolation
add forwarding-type=bridged port-profile=2 ports=ether1 protocol-type=dhcpv4 registration-status="" traffic-type="" type=dst
/ip address
add address=$ip_address/$cidr comment="default configuration" interface=ether1 network=$network
/ip route
add distance=1 gateway=$gateway
/lcd
set backlight-timeout=never default-screen=informative-slideshow read-only-mode=yes touch-screen=disabled
/lcd pin
set pin-number=$pin
/lcd screen
set 0 disabled=yes
set 1 disabled=yes
set 2 disabled=yes
/snmp
set enabled=yes
/system clock
set time-zone-name=Europe/Oslo
/system identity
set name=SWITCH
/system routerboard settings
set protected-routerboot=disabled
/tool romon port
set [ find default=yes ] cost=100 forbid=no interface=all secrets=""
/system package
disable advanced-tools
disable dhcp
disable hotspot
disable mpls
disable ppp
disable routing
disable wireless-cm2
disable wireless-fp
disable ipv6
enable system
enable security
enable routeros-mipsbe
EOF

print $fh $config;
close $fh;
print "done with $sw_id\n";
}
}

1;
