#!/usr/bin/perl
use DBI;
use JSON;

require "/lcs/include/config.pm";

my %json = ();

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";
$sql = "select * from switches WHERE ip IS NOT NULL";
$sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth->fetchrow_hashref()) {
  $json{$ref->{'placement'}} = $ref->{'alive'};
}
my $output = encode_json \%json;
print $output;
