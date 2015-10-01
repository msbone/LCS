#!/usr/bin/perl
use DBI;
package syslog;

require "/lcs/include/config.pm";
# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";


sub log { #type, priority, message, from
  my $class = shift;
  my $self = bless {}, $class;
  my %args = @_;

  my $time = time;

my $type = $args{type};
my $priority = $args{priority};
my $message = $args{message};
my $from = $args{from};

  $dbh->do("INSERT INTO syslog (`time`,`priority`,`message`, `from`, `type`) VALUES ('".$time."','".$priority."','".$message."','".$from."','".$type."')");
}
