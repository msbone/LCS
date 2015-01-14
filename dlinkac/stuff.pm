use Net::Ping;
use warnings;
package stuff;

sub log {

  my $class = shift;
  my %args = @_;

  $message = $args{message};
  $switch = $args{switch};

  my $log_name = 'dlink_log.txt';
  open(my $log, '>>', $log_name) or die "\n Could not open file '$log_name' $! \n";

  $datestring = localtime;

if($switch eq "") {
  print $log $datestring.": $message\n";
}
else {
  print $log $datestring.":$switch: $message\n";
}
  close $log;
}

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
