#!/usr/bin/perl
use DBI;
use Net::Netmask;
package make_dhcp;

require "config.pm";

sub make_dhcp_config {
  my $class = shift;
  my %args = @_;

open (DHCPD, ">$lcs::config::isc_dhcp_dir/dhcpd.conf");

my $dhcp_conf;
my $hostname = $lcs::config::eventname.".".$lcs::config::domain;

my $date=localtime;


$srv_nett = new Net::Netmask ($lcs::config::server_nett);
$srv_netmask = $srv_nett->mask();
$srv_subnet = $srv_nett->base();


$dhcp_conf = <<"EOF";
#MADE WITH make_dhcp.pl at $date\n#DO NOT EDIT MANUAL, YOUR CHANGES WILL BE OVERWRITTEN\n
option domain-name "$hostname";
option domain-name-servers $lcs::config::pri_v4 $lcs::config::sec_dns_v4;
default-lease-time 3600;
max-lease-time 7200;
authoritative;

ddns-update-style interim;
key DHCP_UPDATER {
  algorithm HMAC-MD5.SIG-ALG.REG.INT;
  secret $lcs::config::ddns_key;
}

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
