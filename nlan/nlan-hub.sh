#!/usr/bin/perl -w

use Storable;
use JSON;

my $arg_log = join(" ", @ARGV);
my $env_log = join(" ", map { "$_=$ENV{$_}" } sort keys %ENV);

logent("entry ARGS $arg_log ENV $env_log");

my $tag = shift;
my $common_name = $ENV{common_name};
my $remote_ip = $ENV{trusted_ip};
my $store = "/etc/openvpn/nlan.dat";

my $d = retrieve($store) if -e $store;
$d = {} unless $d;

my $now = time();

$d->{$remote_ip} = {} unless $d->{$remote_ip};
my $r = $d->{$remote_ip};

my $uptime_str = "";
my $uptime = 0;
my $prev_state = $r->{state};
$prev_state = "unknown" unless $prev_state;
if ($r->{time} && ($tag eq "down" || $prev_state eq "up")) {
	$uptime = $now - $r->{time};
	my $hours = int($uptime / 3600);
	my $days = int($hours / 24);
	$hours = $hours % 24;
	$uptime_str .= "${days}d" if $days;
	$uptime_str .= "${hours}h" if $hours;
}
$r->{$tag}++;
my $ignore = $prev_state eq "up" && $tag eq "down" && $r->{time} && $now - $r->{time} < 120;
do {
	$r->{args} = $arg_log;
	$r->{env} = $env_log;
	$r->{uptime} = $uptime if $uptime;
	$r->{uptime_str} = $uptime_str if $uptime;
	$r->{time} = $now;
	$r->{localtime} = localtime();
} unless $ignore;
$r->{state} = $tag;

store($d, $store);

# arg0 time} = 
# arg1 "1500"
# arg2 "1574"
# arg3 "init"
# common_name=irobot
# config=/etc/openvpn/irobot.conf
# daemon=1
# daemon_log_redirect=0
# dev=tap0
# _=/etc/init.d/openvpn
# link_mtu=1574
# local_port=0
# proto=udp
# remote_1=192.168.1.10
# remote_port_1=1194
# script_context=init
# dcript_type=up
# tls_id_0=/C=US/ST=UT/L=Orem/O=Joe_User_s_Organization_P.T.Y._L.T.D/OU=Division_division/CN=irobot/name=Joe_User/emailAddress=joe@zdomain.com
# tls_id_1=/C=US/ST=UT/L=Orem/O=Joe_User_s_Organization_P.T.Y._L.T.D./OU=Networking_Division/CN=irobot/name=Joe_User/emailAddress=joe@zdomain.com
# tls_serial_0=1
# tls_serial_1=-1
# trusted_ip=192.168.1.10
# trusted_port=1194
# tun_mtu=1500
# untrusted_ip=192.168.1.10
# untrusted_port=1194

my $n_flag = 0;

sub do_sys {
	my ($cmd, $ignore_err) = @_;
	my $status = 0;

	logent($n_flag ? "-" : "+" . " $cmd");

	$status = system("$cmd") >> 8 unless $n_flag;

	logent("error $status from command") if $status;

	die "error $status from command\n" if $status and not $ignore_err;
}

sub logent {
	my $msg = shift;

	chomp($msg);

	open LOG, "| logger -p daemon.info -t \"$0 $tag\"" or die;

	print LOG "$msg\n";

	close LOG;
}
