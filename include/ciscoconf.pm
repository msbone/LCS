use strict;
use warnings;
use Net::Telnet::Cisco;

package ciscoconf;

my $session;

my $name;

sub connect {
   my $class = shift;
   my $self = bless {}, $class;
   my %args = @_;
  $session = Net::Telnet::Cisco->new(Host => $args{ip});
   $session->login($args{username}, $args{password});

     if ($session->enable($args{enable_password}) ) {
  } else {
      warn "Can't enable: " . $session->errmsg;
  }
  $name = $args{hostname};
  return $self;
}

sub setup_port {
my $self = shift;
my %args = @_;
#CLEAN THE ARP CACHE
$session->cmd("clear arp-cache");
#GO TO CONF MODE FOR THIS PORT
$session->cmd("conf t");
$session->cmd("interface gigabit 0/".$args{port});
$session->cmd("no shutdown");
#TURN OFF SWITCHPORT
$session->cmd("no switchport");
#SET IP
$session->cmd("ip address 10.90.90.1 255.255.255.0");
$session->cmd("desc CONFIG");
#GO BACK TO START
$session->cmd("exit");
$session->cmd("exit");

print $name.": port ". $args{port}. " set to CONFIG MODE \n";
}

sub setvlan {
my $self = shift;
my %args = @_;
#Set a port at a vlan
#CLEAN THE ARP CACHE
$session->cmd("clear arp-cache");
#GO TO CONF MODE FOR THIS PORT
$session->cmd("conf t");
$session->cmd("interface gigabit 0/".$args{port});
#TURN ON SWITCHPORT AND MAKE MODE ACCESS
$session->cmd("switchport");
$session->cmd("switchport mode access");
#SET PORT TO VLAN
$session->cmd("switchport access vlan ".$args{vlan});
#SET DESC AT PORT
$session->cmd("desc ".$args{desc});
#MAKE SURE THE PORT IS UP
$session->cmd("no shutdown");
#GO BACK TO START
$session->cmd("exit");
$session->cmd("exit");
print $name.": port ". $args{port}. " set to vlan ".$args{vlan}."\n";
}

1;
