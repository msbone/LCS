#!/usr/bin/perl
use DBI;
use RRDs;
use Net::Netmask;

require "/lcs/include/config.pm";
# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

$sql2 = "SELECT ports.id, ports.ifName, switches.name FROM ports JOIN switches WHERE ports.switch_id = switches.id AND switches.model != 'other_nosnmp' AND switches.configured IS NOT NULL AND switches.ip IS NOT NULL";
$sth2 = $dbh->prepare($sql2);

$sth2->execute or die "SQL Error: $DBI::errstr\n";

while (my $ref = $sth2->fetchrow_hashref()) {
  my $id = $ref->{'id'};
  my $switch_name = $ref->{'name'};
  my $if_name = $ref->{'ifName'};
  my $title = "$switch_name - $if_name";
  CreateGraph_inet($id,"hour",$title,"2");
  CreateGraph_inet($id,"day",$title,"2");
  CreateGraph_inet($id,"week",$title,"2");
}

#Totalt inet graph
CreateGraph_inet("total-traffic","hour","Total traffic","2");

$sql = "select id, network, subnet, name FROM netlist WHERE dhcp = 1";
$sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";
while (my $ref = $sth->fetchrow_hashref()) {
  $net_id = $ref->{'id'};
  $network_id = $ref->{'network'};
  $network_subnet = $ref->{'subnet'};
  $network_name = $ref->{'name'};
  $block = new Net::Netmask ($network_id, $network_subnet);

  my $title = "$ref->{'name'} - $block";

  CreateGraph_dhcp($net_id,"hour",$title,"2");
  CreateGraph_dhcp($net_id,"day",$title,"2");
  CreateGraph_dhcp($net_id,"week",$title,"2");
}

CreateGraph_dhcp("0","hour","DHCP LEASES ALL NETWORKS","2");
CreateGraph_dhcp("0","day","DHCP LEASES ALL NETWORKS","2");
CreateGraph_dhcp("0","week","DHCP LEASES ALL NETWORKS","2");

sub CreateGraph_dhcp {
# creates graph
# inputs: $_[0]: network id = 0 for all networks
#	        $_[1]: interval (ie, hour, day, week, month)
#	        $_[2]: title
#	        $_[3]: size
my $image_location = "/lcs/web/rrd/dhcp-$_[0]-$_[1]-$_[3].png";
my $rrd_file = "/lcs/web/rrd/dhcp-$_[0].rrd";

if($_[3] == 3) {
  $height = "300";
  $width = "1200";
} else {
  $height = "175";
  $width = "600";
}

RRDs::graph $image_location,
"-s -1$_[1]",
"-t $_[2] - $_[1]",
"-h", $height, "-w", $width,
"-l 0",
"-a", "PNG",
"DEF:use=$rrd_file:inuse:MAX",
"AREA:use#32CD32:DHCP leases",
"LINE1:use#336600",
"GPRINT:use:MAX:  Max\\: %5.1lf %s",
"GPRINT:use:MIN:  Min\\: %5.1lf %s",
"GPRINT:use:LAST: Current\\: %5.1lf\\n",
"HRULE:0#000000";
if ($ERROR = RRDs::error) { print "$0: unable to generate $_[0] dhcp graph: $ERROR\n"; }
}

sub CreateGraph_inet {
# creates graph
# inputs: $_[0]: interface id
#	        $_[1]: interval (ie, hour, day, week, month)
#	        $_[2]: title
#	        $_[3]: size
my $image_location = "/lcs/web/rrd/$_[0]-$_[1]-$_[3].png";
my $rrd_file = "/lcs/web/rrd/$_[0].rrd";

if($_[3] == 1) {
  $height = "175";
  $width = "300";
}
elsif($_[3] == 3) {
  $height = "300";
  $width = "1200";
} else {
  $height = "175";
  $width = "600";
}

RRDs::graph $image_location,
"-s -1$_[1]",
"-t $_[2] - $_[1]",
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
