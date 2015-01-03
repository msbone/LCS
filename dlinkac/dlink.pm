use strict;
use warnings;
use Net::Telnet;
package dlink;

my $name;
my $t = new Net::Telnet (Timeout => 10,
                      Prompt => '/.28>/');

sub connect {
   my $class = shift;
   my $self = bless {}, $class;
   my %args = @_;

   $name = $args{name};

   $t->open($args{ip});
   $t->login($args{username}, $args{password});
   print "CONNECTED TO SWITCH $name\n";

  return $self;
}

sub sendConfig {
my $self = shift;
my %args = @_;
$t->cmd("download cfg_fromTFTP $args{tftp} $args{file}");
print "Sending config ($args{file} from $args{tftp}) to switch ".$name."\n";
}

sub setIP {
my $self = shift;
my %args = @_;
$t->print("config ipif System ipaddress $args{ip} $args{subnetmask} gateway $args{gateway}");
print "Set IP at switch ".$name." to $args{ip} $args{subnetmask} gateway $args{gateway}\n";
}

sub setPassword {
  my $self = shift;
  my %args = @_;
  $t->print("config account admin password $args{password}");
  print "Set password at switch ".$name." \n";
}

sub save {
my $self = shift;
my %args = @_;
$t->cmd("save");
}

sub cmd {
my $self = shift;
my %args = @_;
$t->cmd($args{cmd});
}

sub close {
my $self = shift;
$t->close;
}

1;
