#!/usr/bin/perl -w
use strict;
use lib '/lcs/include';
use Data::Dumper;
use vars qw($error_msg $debug);
use Mtik;

$Mtik::debug = 2;

my($mtik_host) = '10.13.37.109';
my($mtik_username) = 'admin';
my($mtik_password) = 'admin';

print "Logging in to Mtik: $mtik_host\n";
Mtik::login($mtik_host,$mtik_username,$mtik_password,"8728");
my %attrs;
my %queries;
my($retval,@results) = Mtik::mtik_query("/system/health/print", \%attrs, \%queries);
print Dumper(@results);

Mtik::logout;
