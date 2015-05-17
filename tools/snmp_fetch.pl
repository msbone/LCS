#!/usr/bin/perl
use DBI;
use SNMP;
use RRDs;
use Time::HiRes qw(time);
use POSIX qw(strftime);
SNMP::initMib();
require "/lcs/include/config.pm";

# Connect to the database.
$dbh = DBI->connect("dbi:mysql:$lcs::config::db_name",$lcs::config::db_username,$lcs::config::db_password) or die "Connection Error: $DBI::errstr\n";

#Clean the database of dead switches
our $deadswitch = $dbh->prepare(<<"EOF")
select ports.id, switches.id AS swid from ports JOIN switches WHERE switches.latency_ms IS NULL AND ports.switch_id = switches.id
EOF
  or die "Couldn't prepare deadswitch";

  $deadswitch->execute()
    or die "Couldn't get switch";

  while (my $ref = $deadswitch->fetchrow_hashref()) {
    my $id = $ref->{'id'};
    my $swid = $ref->{'swid'};
    my $rrd_file = "/lcs/web/rrd/$id.rrd";
    $epoc = time();
    RRDs::update $rrd_file, "-t", "input:output", "N:U:U";
    $dbh->do("UPDATE `ports` SET `ifHighSpeed` =  NULL,`current_in` =  NULL,`current_out` =  NULL,`updated` =  '$epoc' WHERE  `id` ='$id'");
    $dbh->do("UPDATE `switches` SET `cpu_use` =  NULL,`uptime` =  NULL,`updated` =  '$epoc' WHERE  `id` ='$swid'");
  }

my @values = ('ifName','ifHighSpeed','ifHCOutOctets','ifHCInOctets', 'ifIndex');

our $qswitch = $dbh->prepare(<<"EOF")
select * from switches WHERE ip IS NOT NULL AND configured = '1' AND latency_ms IS NOT NULL AND snmp_version IS NOT NULL
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
      'community' => "hjemmesnmp",
      'version' => $ref->{'snmp_version'},
      'model' => $ref->{'model'}
    };
  }
}

sub syscall
{
  my %switch = %{$_[0]};

  my $vars = $_[1];
  my ($sysname,$sysdescr,$cpu,$uptime) = (undef,undef,undef,undef);
  for my $var (@$vars) {
    #DEBUG LINE
    #print "$var->[0] | - | $var->[2] \n";
    if ($var->[0] eq "sysName") {
      $sysname = $var->[2];
    } elsif ($var->[0] eq "sysDescr") {
      $sysdescr = $var->[2];
    }elsif ($var->[0] eq "sysUpTimeInstance") {
      $uptime = $var->[2]/ 6000 ;
      $uptime = sprintf "%.2f", $uptime;
    }
     elsif ($var->[0] eq "enterprises.9.2.1.56.0" || $var->[0] eq "ssCpuUser") {
      if($var->[2] =~ m/^[0-9]*$/) {
      $cpu = $var->[2];
    }
    }
  }
  my $id = $switch{'id'};
  if(defined $cpu) {
  $dbh->do("UPDATE `switches` SET `desc` =  '$sysdescr',`cpu_use` =  '$cpu',`uptime` =  '$uptime' WHERE  `id` ='$id'");
}
else {
  $dbh->do("UPDATE `switches` SET `desc` =  '$sysdescr',`cpu_use` =  NULL,`uptime` =  '$uptime' WHERE  `id` ='$id'");
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
#print $descr ."\n";
}
#Cisco
elsif ($descr =~ m/^Gi[0-9]\/[0-9]/ || $descr =~ m/^Po[0-9]/) {
$ifs{$descr} = $table->{$key};
#print $descr ."\n";
}
#Netgear
elsif ($descr =~ m/^g[0-9]/ || $descr =~ m/^l[0-9]/) {
$ifs{$descr} = $table->{$key};
#print $descr ."\n";
}
#linux eth
elsif ($descr =~ m/^eth[0-9]/ && $descr !~ m/\./) {
$ifs{$descr} = $table->{$key};
#print $descr ."\n";
}
#linux eth
elsif ($descr =~ m/^switch[0-9]/) {
$ifs{$descr} = $table->{$key};
#print $descr ."\n";
}
else {
  #print "Port not added: ".$descr ."\n";
}
  }

  foreach my $key (keys %ifs) {
    my @vals = ();
    foreach my $val (@values) {
      if (!defined($ifs{$key}{$val})) {
        #print "Missing data $key\n";
      }
      push @vals, $ifs{$key}{$val};
    }
    #LETS CHECK IF THIS IS A NEW PORT, IF CREATE IT, IF NOT UPDATE
    $sql2 = "SELECT ports.id,switches.name, switches.id AS swid FROM ports JOIN switches WHERE ports.switch_id = '$switch{'id'}' AND ports.ifName = '$vals[0]' AND switches.id = ports.switch_id";
    $sth2 = $dbh->prepare($sql2);

    $sth2->execute or die "SQL Error: $DBI::errstr\n";

    while (my $ref = $sth2->fetchrow_hashref()) {
      my $id = $ref->{'id'};
      my $sw_id = $ref->{'swid'};
      my $switch_name = $ref->{'name'};
      my $rrd_file = "/lcs/web/rrd/$id.rrd";

      $epoc = time();
      RRDs::update $rrd_file, "-t", "input:output", "N:$vals[3]:$vals[2]";
      $dbh->do("INSERT INTO `lcs`.`ports_poll` (`time`, `switch`, `port`, `bytes_in`, `bytes_out`) VALUES ($epoc, '$sw_id', '$id', '$vals[3]', '$vals[2]');");
      #UPDATE THE DATABASE WITH THE LASTEST DATA
      my ($start,$step,$names,$data) = RRDs::fetch $rrd_file, "AVERAGE","--start","-60";
      for my $line (@$data) {
        $dbh->do("UPDATE `ports` SET `ifHighSpeed` =  '$vals[1]',`current_in` =  '@$line[0]',`current_out` =  '@$line[1]',`updated` =  '$start' WHERE  `id` ='$id'");
        last();
      }
    }

    if($sth2->rows == 0) {
      #ADD
      $epoc = time();
      $dbh->do("INSERT INTO `ports` (switch_id,ifName,ifIndex) VALUES ('$switch{'id'}', '$vals[0]','$vals[4]')");
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
            Version => $switch{'version'});
my @vars = ();
push @vars, [ "sysName", 0];
push @vars, [ "sysDescr", 0];
push @vars, [ "sysUpTime", 0];
if($switch{'model'} eq "c3560") {
push @vars, [ ".1.3.6.1.4.1.9.2.1.56", 0];
}
elsif($switch{'model'} eq "edgerouter") {
push @vars, [ "ssCpuUser", 0];
}
my $varlist = SNMP::VarList->new(@vars);
    #Henter switch info
    $s->get($varlist, [ \&syscall, \%switch ]);
    #Henter port info
    $s->gettable('ifXTable',callback => [\&callback, \%switch]);
    #Henter mac table
    #TODO MAGIC
}
  print "Added " . @switches. "\n";
  SNMP::MainLoop(5);
