#!/usr/bin/perl -w

logent("entry ARGS " . join(" ", @ARGV) . " ENV " . join(" ", map { "$_=$ENV{$_}" } keys %ENV));

my $dev = $ENV{"dev"};
my $bridge = "nl0";

die unless $dev;

my $tag = shift;

for ($tag) {
	m/up/ && do {
		do_sys("/sbin/brctl addbr $bridge", 1);
		do_sys("/sbin/brctl addif $bridge $dev", 1);
		do_sys("/sbin/ip l set $dev up", 1);
		do_sys("/sbin/ip l set $bridge up", 1);
		my $ip = `cat nlan-client.ip`;
		chomp $ip;
		do_sys("/sbin/ip a add dev $bridge $ip/24", 1);
		exit 0;
	};
	m/down/ && do {
		do_sys("/sbin/ip l set $dev down", 1);
		do_sys("/sbin/ip l set $bridge down", 1);
		do_sys("/sbin/brctl delbr $bridge");

		exit 0;
	};
	die;    
}

# arg0 "tap0"
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
# script_type=up
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

	print "nlan-client.sh: $msg\n";
}
