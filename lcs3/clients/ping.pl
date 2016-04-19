#!/usr/bin/perl
use Net::Oping;
use LWP::Simple;
use JSON;
use Net::RabbitMQ;
        my $mq = Net::RabbitMQ->new();
        $mq->connect("localhost", { user => "guest", password => "guest" });
        $mq->channel_open(1);

while(true) {

$devices = decode_json(get("http://localhost/api/devices/simple"));

if(scalar($devices) < 0) {
    print "No switch found, sleep\n";
    sleep(10);
    next;
}

$ping = Net::Oping->new;
$ping->timeout(1.0);
$ping->ttl(22);

foreach my $device ( @{$devices} ){
my $switch = $device->{'id'};
my $ip = $device->{'ipv4'};
$ping->host_add($ip);
$ip_to_switch{$ip} = $switch;
}

my $result = $ping->ping();
  die $ping->get_error if (!defined($result));


while (my ($ip, $latency) = each %$result) {
    my $switch = $ip_to_switch{$ip};
    next if (!defined($switch));

    $latency //= "NULL";
    $epoc = time();

my %rec_hash = ('id'=>$switch, 'latency'=>$latency,'time'=>$epoc);



    print "Switch: $switch : $latency at $epoc\n";
    $mq->publish(1, "events", encode_json \%rec_hash);
}
    print "Work done\n";
sleep (1);

}