#!/usr/bin/perl -w
use lib '/lcs/include';

use dlink;
use ciscoconf;
use stuff;
use Net::Netmask;
use DBI;

my $start_run = time();

require "/lcs/include/config.pm";

stuff->log(message => "started run.pl");

#THE SCRIPT OF ALL SCRIPTS
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select netlist.subnet, netlist.id AS netid, netlist.vlan, switches.*, coreswitches.name AS distroname, coreswitches.model AS distromodel, coreswitches.ip as distroip from switches JOIN coreswitches, netlist WHERE netlist.id = switches.net_id AND switches.distro_id = coreswitches.id AND switches.model = 'dgs24' AND switches.configured = 0 ORDER BY switches.distro_id";

$sth = $dbh->prepare($sql);
$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {

  $distro_name = $ref->{'distroname'};
  $distro_model = $ref->{'distromodel'};
  $distro_ip = $ref->{'distroip'};

  $connected_port = $ref->{'distro_port'};

  if($distro_model eq "3560g") {
    stuff->log(message => "Starting magic on $ref->{'name'}");
    my $distro = ciscoconf->connect(ip => $distro_ip,username => $lcs::config::ios_user,password => $lcs::config::ios_pass,hostname => $distro_name, enable_password => $lcs::config::ios_pass);
    stuff->log(message => "Connected to $distro_name");
    #THIS SHOULD MAKE IT WAIT FOR THE PORT IS UP, IF THE SWITCH IS ACCTUAL CONNECTED, IF NOT THE PORT IS UP OSPF WILL NOT REDISTUBUTE THE ROUTE
    $distro -> setup_port(port => $connected_port);
    stuff->log(message => "Port $connected_port on $distro_name setup in config mode");
    sleep(3);
    if($distro -> portstatus(port => $connected_port) ==  0) {
      stuff->log(message => "The port $connected_port on $distro_name is not up. Switch $ref->{'name'}");
      print "PORT IS NOT UP, NEXT SWITCH!";
      next;
    }
    print "We will start to ping the interface on $distro_name \n";
    $respond = stuff->ping(ip => "10.90.90.1",tryes => "35");

    if ($respond == 0) {
      print "\n The port $connected_port on $distro_name is not up, or there is a routing problem\n";
      stuff->log(message => "$distro_name is having a routing problem");
      next;
    }
    stuff->log(message => "We will start to ping 10.90.90.90");
    print "We will start to ping 10.90.90.90 \n";
    $respond = stuff->ping(ip => "10.90.90.90",tryes => "5");

    if ($respond == 0)
    {
      print "No able to ping $ref->{'name'}, check that the switch is connected and in default config\n";
      stuff->log(message => "No able to ping $ref->{'name'}, check that the switch is connected and in default config");
      next;
    }
    #DO THE DLINK MAGIC
    $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => $ref->{'name'});
    stuff->log(message => "Connected to $ref->{'name'}");
    sleep(1);
    $dlink->setIP(ip => "10.90.90.90", gateway => "10.90.90.1", subnetmask => "255.255.255.0");
    #REMEMBER TO EDIT THIS
    sleep(1);
    $dlink->sendConfig(tftp => $lcs::config::tftp_ip,file => "config.bin");
    stuff->log(message => "Sending config to $ref->{'name'} from $lcs::config::tftp_ip");
    sleep(7);
    $dlink->close;
    undef $dlink;

    print "The switch should now reboot, lets wait \n";
    stuff->log(message => "$ref->{'name'} is now rebooting");
    sleep(2);
    $respond = stuff->ping(ip => "10.90.90.90",tryes => "120");

    if ($respond == 0)
    {
      print "No able to ping $ref->{'name'}, the switch is not up after config push \n";
      stuff->log(message => "No able to ping $ref->{'name'}, the switch is not up after config push");
      next;
    }
    print "Switch is back online, we now set password then new IP \n";
    stuff->log(message => "$ref->{'name'} is back online, we now set password then new IP");
    $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => $ref->{'name'});
    $dlink->setPassword(password => $lcs::config::dlink_pass);
    sleep(5);
    $block = new Net::Netmask ($ref->{'ip'}, $ref->{'subnet'});

    $dlink->setIP(ip => $ref->{'ip'}, gateway => $block->nth(1), subnetmask => $block->mask());
    sleep(5);
    $dlink->close;
    stuff->log(message => "$ref->{'name'} do now have correct ip and password");
    $distro -> setvlan(port => $connected_port,vlan => $ref->{'vlan'}, desc => $ref->{'name'});
    undef $distro;
    stuff->log(message => "$connected_port is not set to vlan $ref->{'vlan'} for the switch $ref->{'name'}");
  }else {
    stuff->log(message => "The core on switch $ref->{'name'} is not a cisco 3560G, WE SKIP");
  }
}

  print "We will wait 1 minute \n";
  sleep(60);

#The switches is now done with is job, lets check that the switches acctual have got their IP befor we give it green light
$sth->execute or die "SQL Error: $DBI::errstr\n";

my $switches = 0;
my $failed = 0;

while (my $ref = $sth->fetchrow_hashref()) {
  print "We will start to ping $ref->{'name'} - $ref->{'ip'}\n";
  $respond = stuff->ping(ip => $ref->{'ip'},tryes => "5");

  if ($respond == 0)
  {
    #TODO ADD LOG STUFF
    print "No able to ping $ref->{'name'}\n";
    $failed++;
  }
  else {
    print "Switch $ref->{'name'} is online\n";
    $dbh->do("UPDATE `switches` SET  `configured` = 1 WHERE id = '".$ref->{'id'}."'");
    $switches++;
  }
}

#Lets save the config on all success switches
print "Starting to save config on success switches \n";
$sql = "select * from switches WHERE model = 'dgs24' AND configured = 1";

$sth = $dbh->prepare($sql);
$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  print "We will start to ping $ref->{'name'} \n";
  $respond = stuff->ping(ip => $ref->{'ip'},tryes => "8");

  if ($respond == 0)
  {
    print "No able to ping $ref->{'name'} ($ref->{'ip'}), skipping \n";
  }else {
    $dlink = dlink->connect(ip => $ref->{'ip'},username => "admin",password => $lcs::config::dlink_pass, name => $ref->{'name'});
    $dlink -> save();
    $dlink->close;
    undef $dlink;
  }
}

my $end_run = time();
my $run_time = $end_run - $start_run;

print "\nConfig done for $switches switches in $run_time sec \n $failed switches failed \n";
stuff->log(message => "$failed switches failed");
stuff->log(message => "Config done for $switches switches in $run_time sec");
