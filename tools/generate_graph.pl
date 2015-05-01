#!/usr/bin/perl
use DBI;
use RRDs;

require "/lcs/include/config.pm";
# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

#LETS CHECK IF THIS IS A NEW PORT, IF CREATE IT, IF NOT UPDATE
$sql2 = "SELECT ports.id, ports.ifName, switches.name FROM ports JOIN switches WHERE ports.switch_id = switches.id AND switches.model != 'other_nosnmp' AND switches.configured IS NOT NULL AND switches.ip IS NOT NULL";
$sth2 = $dbh->prepare($sql2);

$sth2->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth2->fetchrow_hashref()) {
  my $id = $ref->{'id'};
  my $switch_name = $ref->{'name'};
  my $if_name = $ref->{'ifName'};
  my $title = "$switch_name - $if_name";
  CreateGraph($id,"hour",$title,"2");
  CreateGraph($id,"day",$title,"2");
  CreateGraph($id,"week",$title,"2");
}

sub CreateGraph {
# creates graph
# inputs: $_[0]: interface id
#	        $_[1]: interval (ie, hour, day, week, month)
#	        $_[2]: title
#	        $_[3]: size
my $image_location = "/lcs/web/rrd/$_[0]-$_[1]-$_[3].png";
my $rrd_file = "/lcs/web/rrd/$_[0].rrd";

if($_[3] == 3) {
  $height = "300";
  $width = "1200";
} else {
  $height = "175";
  $width = "600";
}

RRDs::graph $image_location,
"-s -1$_[1]",
"-t $_[2]",
"-h", $height, "-w", $width,
"-l 0",
"-a", "PNG",
"-v bytes/sec",
"DEF:in=$rrd_file:input:AVERAGE",
"DEF:out=$rrd_file:output:AVERAGE",
"CDEF:out_neg=out,-1,*",
"AREA:in#32CD32:Incoming",
"LINE1:in#336600",
"GPRINT:in:MAX:  Max\\: %5.1lf %s",
"GPRINT:in:AVERAGE: Avg\\: %5.1lf %S",
"GPRINT:in:LAST: Current\\: %5.1lf %Sbytes/sec\\n",
"AREA:out_neg#4169E1:Outgoing",
"LINE1:out_neg#0033CC",
"GPRINT:out:MAX:  Max\\: %5.1lf %s",
"GPRINT:out:AVERAGE: Avg\\: %5.1lf %S",
"GPRINT:out:LAST: Current\\: %5.1lf %Sbytes/sec",
"HRULE:0#000000";
if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] traffic graph: $ERROR\n"; }
}
