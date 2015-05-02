#!/usr/bin/perl
use DBI;
use SNMP;
use RRDs;

require "/lcs/include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

my @values = ('ifName','ifHighSpeed','ifHCOutOctets','ifHCInOctets');

our $qswitch = $dbh->prepare(<<"EOF")
select * from switches WHERE ip IS NOT NULL AND configured = '1'
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

#JUNIPER
if ($descr =~ m/(fe|ge|xe|et)-/ && $descr !~ m/\./) {
$ifs{$descr} = $table->{$key};
print $descr ."\n";
}
#Cisco
if ($descr =~ m/^Gi[0-9]\/[0-9]/ || $descr =~ m/^Po[0-9]/) {
$ifs{$descr} = $table->{$key};
print $descr ."\n";
}
#Netgear
if ($descr =~ m/^g[0-9]/ || $descr =~ m/^l[0-9]/) {
$ifs{$descr} = $table->{$key};
print $descr ."\n";
}
#linux eth
if ($descr =~ m/^eth[0-9]/) {
$ifs{$descr} = $table->{$key};
print $descr ."\n";
}

  }

  foreach my $key (keys %ifs) {
    my @vals = ();
    foreach my $val (@values) {
      if (!defined($ifs{$key}{$val})) {
        print "Missing data $key\n";
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
      my $rrd_file = "/lcs/web/rrd/$id.rrd";

      $epoc = time();
      RRDs::update $rrd_file, "-t", "input:output", "N:$vals[3]:$vals[2]";
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
      $dbh->do("INSERT INTO `ports` (switch_id,ifName) VALUES ('$switch{'id'}', '$vals[0]')");
      my $rrd_file = "/lcs/web/rrd/$dbh->{mysql_insertid}.rrd";
      RRDs::create $rrd_file, "--step","60", "--start","$epoc", "DS:input:COUNTER:10080:U:U", "DS:output:COUNTER:10080:U:U", "RRA:AVERAGE:0.5:1:10080";
      my $ERR=RRDs::error;
 die "ERROR while creating $rrd_file: $ERR\n" if $ERR;
      RRDs::update $rrd_file, "-t", "input:output", "N:$vals[3]:$vals[2]";
    }
  }
  print "STOP: Polling $switch{'sysname'} took " . (time - $switch{'start'}) . "s \n";
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
