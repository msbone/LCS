#!/usr/bin/perl -w
use strict;
use lib '/lcs/include';
use Data::Dumper;
use vars qw($error_msg $debug);
use mikrotikCore;

my $distro = mikrotikCore->connect(ip => "10.80.254.2",username => "admin",password => "",hostname => "TestGW");

$distro -> setup_port(port => "ether10");
$distro -> gateway_edge();
