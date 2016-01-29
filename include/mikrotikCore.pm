package mikrotikCore;

use strict;
use warnings;
use Mtik;
use Data::Dumper;
use Net::SSH::Perl;


my $session;

my $name;

my $coreIp;
my $coreUsername;
my $corePassword;

sub connect {
   my $class = shift;
   my $self = bless {}, $class;
   my %args = @_;

   $Mtik::debug = 2;
   Mtik::login($args{ip},$args{username},$args{password},"8728");

   $name = $args{hostname};
   $coreIp = $args{ip};
   $coreUsername = $args{username};
   $corePassword = $args{password};
   return $self;
}

sub setup_port {
  my $self = shift;
  my %args = @_;

  $self->setAddress(port => $args{port}, ip => "192.168.88.2", netmask => "255.255.255.0");
}

sub setAddress {
  my $self = shift;
  my %args = @_;
  my $id;
  my %attrs;
  my %queries;
  $queries{'interface'} = $args{port};
  my($retval,@results) = Mtik::mtik_query("/ip/address/print", \%attrs, \%queries);
  foreach my $address (@results) {if($args{port} eq $address->{'interface'}) {$id = $address->{'.id'};}}
  if(!length $id) {
    print "Address on port do not exist, creating \n";
   #Add new-address
    my %attrs1;
    $attrs1{"address"} = $args{ip};
    $attrs1{"interface"} = $args{port};
    $attrs1{"netmask"} = $args{netmask};
    $attrs1{"comment"} = "LCS";
    Mtik::mtik_cmd("/ip/address/add", \%attrs1);
  } else {
    print "Address on port exist, editing \n";
    my %attrs1;
    $attrs1{"address"} = $args{ip};
    $attrs1{"interface"} = $args{port};
    $attrs1{"netmask"} = $args{netmask};
    $attrs1{"comment"} = "LCS";
    $attrs1{"numbers"} = $id;
    my($retval,@results) = (Mtik::mtik_cmd("/ip/address/set", \%attrs1));
    print Dumper @results;
  }

sub gateway_edge {
  my $self = shift;
  my %args = @_;
  #As API do not support ""/tools/ssh" we have to ssh manual to the core then run the ssh cmd. Hopefully someone will make this work in the furtue

  my $ssh = Net::SSH::Perl->new($coreIp, use_pty => 0);
     $ssh->login($coreUsername, $corePassword);
     print Dumper($ssh->cmd('system ssh command="ip route add distance=1 gateway=192.168.88.2" user=admin address=192.168.88.1'));


}

}
1;
