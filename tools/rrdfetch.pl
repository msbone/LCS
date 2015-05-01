use RRDs;

my ($start,$step,$names,$data) = RRDs::fetch "/lcs/web/rrd/32.rrd", "AVERAGE","--start","-60";
for my $line (@$data) {
  print "  ", scalar localtime($start), " ($start) ";
  $start += $step;
  printf "@$line[0] ";
  printf "@$line[1]";
  print "\n";
  last();
}
