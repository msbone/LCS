#!/usr/bin/perl
use DBI;
use Net::Netmask;
package make_dhcp;

require "config.pm";

sub make_dhcp_config {
  my $class = shift;
  my %args = @_;

open (DHCPD, ">$lcs::config::isc_dhcp_dir/dhcpd.conf") or die "Can't write to file '$lcs::config::isc_dhcp_dir/dhcpd.conf' [$!]\n";

my $dhcp_conf;
my $hostname = $lcs::config::eventname.".".$lcs::config::domain;

my $date=localtime;


$srv_nett = new Net::Netmask ($lcs::config::server_nett);
$srv_netmask = $srv_nett->mask();
$srv_subnet = $srv_nett->base();

if($lcs::config::unifi_controller_ip ne "") {
  $unifi_config = "
  option space ubnt;
  option ubnt.unifi-address code 1 = ip-address;

  class \"ubnt\" {
    match if substring (option vendor-class-identifier, 0, 4) = \"ubnt\";
    option vendor-class-identifier \"ubnt\";
    vendor-option-space ubnt;
    option ubnt.unifi-address $lcs::config::unifi_controller_ip;
  }
  ";
}

$dhcp_conf = <<"EOF";
#MADE WITH make_dhcp.pl at $date\n#DO NOT EDIT MANUAL, YOUR CHANGES WILL BE OVERWRITTEN\n
option domain-name "$hostname";
option domain-name-servers $lcs::config::pri_dns_v4, $lcs::config::sec_dns_v4;
default-lease-time 3600;
max-lease-time 7200;
authoritative;

ddns-update-style interim;
include "/etc/dhcp/ddns-keys/rndc.key";

$unifi_config

subnet $srv_subnet netmask $srv_netmask {}

EOF

  # Connect to the database.
  $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
  $sql = "select * from netlist WHERE dhcp = 1";
  $sth = $dbh->prepare($sql);
  $sth->execute or die "SQL Error: $DBI::errstr\n";

  while (my $ref = $sth->fetchrow_hashref()) {
    $network = $ref->{'network'}."/".$ref->{'subnet'};
    $reserved_ips = $ref->{'dhcp_reserved'};
    $name = lc($ref->{'name'});
    $desc = "- " . $ref->{'desc'};

    $block = new Net::Netmask ($network);

    $netmask = $block->mask();
    $subnet = $block->base();
    $router = $block->nth(1);

    if($reserved_ips == 0) {
      $first_ip = $block->nth(2);
    }
    else {
      $first_ip = $block->nth($reserved_ips+2);
    }

    $last_ip = $block->nth(-2);

    $dhcp_conf .= "
    #$ref->{'name'} $desc

    zone $name.$hostname {
      primary 127.0.0.1;
      key DHCP_UPDATER;
    }

    subnet $subnet  netmask $netmask {
      authoritative;
      option routers $router;
      option domain-name \"$name.$hostname\";
      ddns-domainname  \"$name.$hostname\";
      range $first_ip $last_ip;
      ignore client-updates;
    }
    ";
  }

  print DHCPD $dhcp_conf;
  close (DHCPD);
  print "Generated $lcs::config::isc_dhcp_dir/dhcpd.conf\n";

}
