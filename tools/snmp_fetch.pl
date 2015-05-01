#!/usr/bin/perl
use DBI;
use SNMP;
use RRDs;

require "/lcs/include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

my @values = ('ifName','ifHighSpeed','ifHCOutOctets','ifHCInOctets');

our $qswitch = $dbh->prepare(<<"EOF")
select * from switches WHERE ip IS NOT NULL
EOF
  or die "Couldn't prepare qswitch";
my @switches = ();

sub populate_switches
{
  @switches = ();
  $qswitch->execute()
    or die "Couldn't get switch";

  while (my $ref = $qswitch->fetchrow_hashref()) {
    push @switches, {
      'sysname' => $ref->{'name'},
      'id' => $ref->{'id'},
      'mgtip' => $ref->{'ip'},
      'community' => "hjemmesnmp"
    };
  }
}

sub callback
{
  my %switch = %{$_[0]};
  my $table = $_[1];

  my %ifs = ();

  foreach my $key (keys %{$table}) {
    my $descr = $table->{$key}->{'ifName'};
    $ifs{$descr} = $table->{$key};
  }

  foreach my $key (keys %ifs) {
    my @vals = ();
    foreach my $val (@values) {
      if (!defined($ifs{$key}{$val})) {
        die "Missing data \n";
      }
      push @vals, $ifs{$key}{$val};
    }
    #LETS CHECK IF THIS IS A NEW PORT, IF CREATE IT, IF NOT UPDATE
    $sql2 = "SELECT ports.id,switches.name FROM ports JOIN switches WHERE ports.switch_id = '$switch{'id'}' AND ports.ifName = '$vals[0]' AND switches.id = ports.switch_id";
    $sth2 = $dbh->prepare($sql2);

    $sth2->execute or die "SQL Error: $DBI::errstr\n";

    while (my $ref = $sth2->fetchrow_hashref()) {
      my $id = $ref->{'id'};
      my $switch_name = $ref->{'name'};
      my $title = "$switch_name - $vals[0]";
      my $rrd_file = "/lcs/web/rrd/$id.rrd";

      $epoc = time();
      RRDs::update $rrd_file, "-t", "input:output", "N:$vals[3]:$vals[2]";
      CreateGraph($id,"hour",$title);

      #UPDATE THE DATABASE WITH THE LASTEST DATA
      my ($start,$step,$names,$data) = RRDs::fetch $rrd_file, "AVERAGE","--start","-60";
      for my $line (@$data) {
        $dbh->do("UPDATE `ports` SET `ifHighSpeed` =  $vals[1],`current_in` =  '@$line[0]',`current_out` =  '@$line[1]',`updated` =  '$start' WHERE  `id` =$id");
        last();
      }
    }

    if($sth2->rows == 0) {
      #ADD
      $epoc = time();
      my $rrd_file = "/lcs/web/rrd/$dbh->{mysql_insertid}.rrd";
      $dbh->do("INSERT INTO `ports` (switch_id,ifName,ifHighSpeed, ifHCInOctets, ifHCOutOctets, updated) VALUES ('$switch{'id'}', '$vals[0]', '$vals[1]', '$vals[2]', '$vals[3]', '$epoc')");
      RRDs:create $rrd_file, "--step 300", "--start $epoc", "DS:input:COUNTER:10080:U:U", "DS:output:COUNTER:10080:U:U", "RRA:AVERAGE:0.5:1:10080";
      RRDs::update $rrd_file, "-t", "input:output", "N:$vals[3]:$vals[2]"
    }
  }
  print "STOP: Polling $switch{'sysname'} took " . (time - $switch{'start'}) . "s \n";
}

sub CreateGraph {
# creates graph
# inputs: $_[0]: interface id
#	        $_[1]: interval (ie, hour, day, week, month)
#	        $_[2]: title
my $image_location = "/lcs/web/rrd/$_[0]-$_[1].png";
my $rrd_file = "/lcs/web/rrd/$_[0].rrd";
RRDs::graph $image_location,
"-s -1$_[1]",
"-t $_[2]",
"-h", "150", "-w", "650",
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

  populate_switches();
  for my $refswitch (@switches) {
    my %switch = %{$refswitch};
    print "START: Polling $switch{'sysname'} ($switch{'mgtip'}) \n";
    $switch{'start'} = time;
    my $s = new SNMP::Session(DestHost => $switch{'mgtip'},
            Community => $switch{'community'},
            Version => '2');
    $s->gettable('ifXTable',callback => [\&callback, \%switch]);
  }
  print "Added " . @switches. "\n";
  SNMP::MainLoop(5);
