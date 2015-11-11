#!/usr/bin/perl -w
use lib '/lcs/include';

use cisco;
use Net::FTP;
use Mtik;

require "/lcs/include/config.pm";
my $newest_os = "6.33";


#Set default gateway, so we can use API and FTP
my $distro = ciscoconf->connect(ip => "10.13.37.110",username => "ole",password => "Dataparty15",hostname => "TEST", enable_password => "Dataparty15");
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
      or die "Cannot connect to some.host.name: $@";
      $ftp->login("admin",'')
            or die "Cannot login ", $ftp->message;
            $ftp->binary;

#Check if switch is running a old firmware
my %attrs;
my %queries;
my($retval,@results) = Mtik::mtik_query("/system/package/print", \%attrs, \%queries);
if($results[0]{version} ne $newest_os) {
  print "Not correct OS, running: ".$results[0]{version} ."\n";
  $ftp->put("/lcs/AC/mikrotik-firmware/routeros-mipsbe-6.33.npk", "routeros-mipsbe-6.33.npk") or die "put failed: " . $ftp->message;
  print "Uploaded \n"
}
#Upload the config, then restart
$ftp->put("/lcs/AC/mikrotik-config/default.rsc", "config.rsc") or die "put failed: " . $ftp->message;

my %attrs1;
$attrs1{"no-defaults"} = "yes";
$attrs1{"run-after-reset"} = "config.rsc";

Mtik::mtik_cmd("/system/reset-configuration", \%attrs1);

Mtik::logout;
