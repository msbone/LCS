package mikrotikEdge;

use strict;
use warnings;
use Mtik;
use Data::Dumper;


my $session;

my $name;

sub connect {
   my $class = shift;
   my $self = bless {}, $class;
   my %args = @_;

   $Mtik::debug = 2;
   Mtik::login($args{ip},$args{username},$args{password},"8728");

   $name = $args{hostname};
   return $self;
}
