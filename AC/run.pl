#!/usr/bin/perl -w
use lib '/lcs/include';
use strict;
use warnings;

use dlink;
use cisco;
use stuff;
use Net::Netmask;
use DBI;
use Net::FTP;
use Mtik;

my $start_run = time();
stuff->log(message => "Started run-v2.pl");

require "/lcs/include/config.pm";

#THE SCRIPT OF ALL SCRIPTS
my $dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
my $sql = "SELECT netlist.subnet, netlist.id AS netid, netlist.vlan, switches.*, coreswitches.name AS distroname, coreswitches.model AS distromodel, coreswitches.ip AS distroip
FROM switches
JOIN switches AS coreswitches, netlist
WHERE netlist.id = switches.net_id
AND switches.connected_to = coreswitches.id
AND switches.configured =0
AND coreswitches.type = 2
ORDER BY switches.connected_to, switches.connected_port
";

my $sth = $dbh->prepare($sql);
$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {

  my $distro_name = $ref->{'distroname'};
  my $distro_model = $ref->{'distromodel'};
  my $distro_ip = $ref->{'distroip'};
  my $switch_name = $ref->{'name'};
  my $switch_model = $ref->{'model'};
  my $connected_port = $ref->{'connected_port'};
  my $switch_id = $ref->{'id'};
  stuff->log(message => "Starting magic", switch => $switch_name);

  if($ref->{'distroip'} ne  $distro_ip && $ref->{'distroip'} ne ""){
  stuff->log(message => "Changed distro from $distro_name to $ref->{'distroname'}", switch => "");
  sleep(10);
  }

if($distro_model eq "3560g") {
my $distro = ciscoconf->connect(ip => $distro_ip,username => $lcs::config::ios_user,password => $lcs::config::ios_pass,hostname => $distro_name, enable_password => $lcs::config::ios_pass);
stuff->log(message => "Connected to $distro_name", switch => $switch_name);
$distro -> setup_port(port => $connected_port, model => $switch_model);
stuff->log(message => "Port $connected_port on $distro_name setup in config mode for $switch_model", switch => $switch_name);
sleep(10);
if($distro -> portstatus(port => $connected_port) ==  0) {
  stuff->log(message => "The port $connected_port on $distro_name is not up.", switch => $switch_name);
  print "PORT IS NOT UP, NEXT SWITCH!";
$distro -> setvlan(port => $connected_port,vlan => "666", desc => "AC FAILED HERE");
$distro -> shut_port(port => $connected_port);
next;
}
  stuff->log(message => "We will start to ping the interface on $distro_name", switch => $switch_name);
  my $respond = stuff->ping(ip => $switch_model,tryes => "35", gw => 1);

  if ($respond == 0) {
    print "\n The port $connected_port on $distro_name is not up, or there is a routing problem\n";
    stuff->log(message => "$distro_name is having a routing problem, or has fallen down", switch => $switch_name);
$distro -> setvlan(port => $connected_port,vlan => "666", desc => "DLINKAC FAILED HERE");
$distro -> shut_port(port => $connected_port);
next;
  }
    if($switch_model eq "dgs24") {
  stuff->log(message => "We will start to ping default ip", switch => $switch_name);
  print "We will start to ping default ip \n";
  $respond = stuff->ping(ip => $switch_model,tryes => "5");

  if ($respond == 0)
  {
    print "No able to ping $ref->{'name'}, check that the switch is connected and in default config\n";
    stuff->log(message => "No able to ping, check that the switch is connected and in default config", switch => $switch_name);
$distro -> setvlan(port => $connected_port,vlan => "666", desc => "DLINKAC FAILED HERE");
$distro -> shut_port(port => $connected_port);
next;
  }
  #DO THE DLINK MAGIC
  my $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => $ref->{'name'});
  stuff->log(message => "Connected to switch", switch => $switch_name);
  sleep(1);
  #Commented on vatnelan 2015 høst, was giving timeouts
  #$dlink->setIP(ip => "10.90.90.90", gateway => "10.90.90.1", subnetmask => "255.255.255.0"); sleep(1);
  #Check if this is C1 (SDOK) or B1 (VLAN)
print $dlink->getHWversion();
my $switch_version = $dlink->getHWversion();
  if($switch_version eq "C1") {
    stuff->log(message => "HW version C1", switch => $switch_name);
    $dlink->sendConfig(tftp => $lcs::config::tftp_ip,file => "C1.bin");
  }
  elsif($switch_version eq "B1") {
    stuff->log(message => "HW version B1", switch => $switch_name);
    $dlink->sendConfig(tftp => $lcs::config::tftp_ip,file => "B1.bin");
  }
  else {
    stuff->log(message => "Switch is not supported $switch_version, quit", switch => $switch_name);
$distro -> setvlan(port => $connected_port,vlan => "666", desc => "DLINKAC FAILED HERE");
$distro -> shut_port(port => $connected_port);
next;
  }
  stuff->log(message => "Sending config from $lcs::config::tftp_ip", switch => $switch_name);
  sleep(7);
  $dlink->close;
  undef $dlink;
  print "The switch should now reboot, lets wait \n";
  stuff->log(message => "rebooting...", switch => $switch_name);
  sleep(2);
  $respond = stuff->ping(ip => "10.90.90.90",tryes => "120");
  if ($respond == 0)
  {
    print "No able to ping $ref->{'name'}, the switch is not up after config push \n";
    stuff->log(message => "No able to ping, the switch is not up after config push", switch => $switch_name);
$distro -> shut_port(port => $connected_port);
next;
  }
  print "Switch is back online, we now set password then new IP \n";
  stuff->log(message => "Switch is back online, we now set password then new IP", switch => $switch_name);
  $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => $switch_name);
  $dlink->setPassword(password => $lcs::config::dlink_pass);
  sleep(5);
  my $block = new Net::Netmask ($ref->{'ip'}, $ref->{'subnet'});

  $dlink->setIP(ip => $ref->{'ip'}, gateway => $block->nth(1), subnetmask => $block->mask());
  sleep(5);
  $dlink->close;
}elsif($switch_model eq "mtik") {
  #Set default gateway, so we can use API and FTP
my $distro = ciscoconf->connect(ip => $distro_ip,username => $lcs::config::ios_user,password => $lcs::config::ios_pass,hostname => $distro_name, enable_password => $lcs::config::ios_pass);  
$distro ->gateway_mikrotik();
  #Connect the API
  $Mtik::debug = 2;
  my($mtik_host) = '192.168.88.1';
  my($mtik_username) = 'admin';
  my($mtik_password) = '';
  print "Logging in to Mtik: $mtik_host\n";
  Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");
  #Connect the FTP
  my $ftp = Net::FTP->new("192.168.88.1", Debug => 0)
        or die "Cannot connect to mtik: $@";
        $ftp->login("admin",'')
              or die "Cannot login ", $ftp->message;
              $ftp->binary;
  #Check if switch is running an old firmware
  my %attrs;
  my %queries;
  my($retval,@results) = Mtik::mtik_query("/system/package/print", \%attrs, \%queries);
  if($results[0]{version} ne $lcs::config::mtik_version) {
  print "Not correct OS, running: ".$results[0]{version} ."\n";
  $ftp->put("/lcs/AC/mikrotik-firmware/routeros-mipsbe-6.37.1.npk", "routeros-mipsbe-6.37.1.npk") or die "put failed: " . $ftp->message;
  print "Uploaded \n"
  }
  else {
    print "Running $results[0]{version}";
  }
  #Upload the config, then restart
  $ftp->put("/lcs/AC/mikrotik-config/sw-$switch_id.rsc", "config.rsc") or die "put failed: " . $ftp->message;

  my %attrs1;
  $attrs1{"no-defaults"} = "yes";
  $attrs1{"run-after-reset"} = "config.rsc";

  Mtik::mtik_cmd("/system/reset-configuration", \%attrs1);

  Mtik::logout;

  print "Done with mtik";
} else {
  stuff->log(message => "The switch is not supported, WE SKIP", switch => $switch_name);
}
stuff->log(message => "Switch should have correct ip ($ref->{'ip'})", switch => $switch_name);
$distro -> setvlan(port => $connected_port,vlan => $ref->{'vlan'}, desc => $ref->{'name'});
undef $distro;
stuff->log(message => "$connected_port is now set to vlan $ref->{'vlan'} on $distro_name", switch => $switch_name);

}else {
  stuff->log(message => "The core is not supported, WE SKIP", switch => $switch_name);
}
}
