use Net::Ping;
use warnings;
use Net::Telnet;
package stuff;


sub ping {

  my $class = shift;
  my %args = @_;

  $host = $args{ip};;
  $tryes = $args{tryes};;

my $p=Net::Ping->new('icmp');

$failed = 0;
$success = 0;


while ($failed < $tryes and $success == 0) {
  if ($p->ping($host, "1")){
    $success = 1;
  } else {
    $failed++;
    print "No responding to ICMP $failed \n";
  }
}

$p->close();
if ($success == 0) {
  return 0;
}else {
  return 1;

}
}

1;
