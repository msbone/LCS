#!/usr/bin/perl -w
require "/lcs/include/ciscoconf.pm";

use dlink;
use ciscoconf;
use stuff;
use Net::Netmask;

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 2) {
  print "\nUsage: singleswitch.pl ip_address/cidr new_password  \n";
  exit;
}

$ip=$ARGV[0];
$password=$ARGV[1];

$block = new Net::Netmask ($ip);

$netmask = $block->mask();
$router = $block->nth(1);
$ip_address = substr $ip, 0, -3;

print "\n To use this script your machine must have the IP 10.90.90.91/24 \n";
print "Make sure the switch is in factory settings and is done with boot \n Press enter to start \n";
<STDIN>;
print "We will start to ping 10.90.90.90 \n";
$respond = stuff->ping(ip => "10.90.90.90",tryes => "5");

if ($respond == 0)
{
  print "No able to ping 10.90.90.90, check your connection \n";
  exit;
}
  print "Responds to ping, all good \n";
  #DO THE DLINK MAGIC
  $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => " ");
  sleep(1);
  $dlink->setIP(ip => "10.90.90.90", gateway => "10.90.90.91", subnetmask => "255.255.255.0");
  #REMEMBER TO EDIT THIS
  sleep(1);
  $dlink->sendConfig(tftp => "213.184.213.21",file => "config.bin");
  sleep(10);
  $dlink->close;
  undef $dlink;

  print "The switch should now reboot, lets wait \n";
  sleep(5);
  $respond = stuff->ping(ip => "10.90.90.90",tryes => "120");

  if ($respond == 0)
  {
    print "No able to ping 10.90.90.90, the switch is not up after config push, \n";
    exit;
  }
  print "Switch is back online, we now set password then new IP \n";
  $dlink = dlink->connect(ip => "10.90.90.90",username => "admin",password => "admin", name => " ");
  $dlink->setPassword(password => $password);
  sleep(2);
  $dlink->setIP(ip => $ip_address, gateway => $router, subnetmask => $netmask);
  sleep(2);
  $dlink->close;
