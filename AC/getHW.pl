use lib '/lcs/include';

use dlink;
use cisco;
use stuff;
use Net::Netmask;

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
if ($num_args != 2) {
  print "\nUsage: getHW.pl switch_ip password  \n";
  exit;
}

$ip=$ARGV[0];
$password=$ARGV[1];

$dlink = dlink->connect(ip => $ip,username => "admin",password => $password, name => "TEST");
sleep(1);
print $dlink->getHWversion();
