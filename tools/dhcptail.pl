#! /usr/bin/perl
use POSIX;
use strict;
use warnings;

my %months = (
Jan => "01",
Feb => "02",
Mar => "03",
Apr => "04",
May => "05",
Jun => "06",
Jul => "07",
Aug => "08",
Sep => "09",
Oct => "10",
Nov => "11",
Dec => "12"
);

open(SYSLOG, "tail -n 9999 -F /var/log/syslog |") or die "Unable to tail syslog: $!";
while (<SYSLOG>) {
  /(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d+)\s+(\d+:\d+:\d+).*DHCPACK on (\d+\.\d+\.\d+\.\d+) to (\S+)/ or next;
  my $date = $2 . "-" . $months{$1} . " " . $3;
  my $machine = $5;

  print "$date $4\n";
}
close SYSLOG;
