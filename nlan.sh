#!/bin/bash

case "$1" in
init-hub)
	if [ "x$2" == "x" ] ; then
		echo HOST IP ARGUMENT MISSING
		exit 1
	fi
	hub_ip=$2
	echo INIT HUB, IP $2
	set -x
	cd /etc/openvpn
	[ -e nlan ] && rm -rf nlan/*
	tar xvf nlan-pkg.tar.gz
	cd nlan
	make-cadir easy-rsa
	cd easy-rsa
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa --batch build-client-full nlan-client nopass
	./easyrsa --batch build-server-full nlan-hub nopass
	cp -p pki/ca.crt ..
	cp -p pki/dh.pem ../dh2048.pem
	cp -p pki/private/nlan-client.key ..
	cp -p pki/private/nlan-hub.key ..
	cp -p pki/issued/nlan-client.crt ..
	cp -p pki/issued/nlan-hub.crt ..
	cd ..
	/bin/sed -e s/nlan-hub/$hub_ip/g < _nlan-client.conf > nlan-client.conf
	ovpn=nlan-client.ovpn
	(echo client; echo dev tun; echo proto udp)			>  $ovpn
	echo remote $hub_ip 1171					>> $ovpn
	(echo resolv-retry infinite; echo nobind; echo persist-key)	>> $ovpn
	(echo persist-tun; echo comp-lzo; echo verb 1; echo "<ca>")	>> $ovpn
	cat ca.crt							>> $ovpn
	(echo "</ca>"; echo "<cert>")					>> $ovpn
	egrep '^\S.*' nlan-client.crt | /bin/fgrep -v Certificate:	>> $ovpn
	(echo "</cert>"; echo "<key>")					>> $ovpn
	cat nlan-client.key						>> $ovpn
	echo "</key>"							>> $ovpn
	tar cvfz nlan-client.tar.gz -C .. nlan/nlan-client.{conf,ovpn,key,crt,sh} nlan/ca.crt
	;;
hub)
	if [ ! -e /etc/openvpn/nlan/nlan-hub.crt ] ; then
		echo RUN "init hub" FIRST
		exit 1
	fi
	echo RUN HUB
	cd /etc/openvpn/nlan
	openvpn --config nlan-hub.conf $2
	;;
hub-l3)
	if [ ! -e /etc/openvpn/nlan/nlan-hub.crt ] ; then
		echo RUN "init hub" FIRST
		exit 1
	fi
	if [ "x$2" == "x" ] ; then
		echo NLAN SUBNET ARGUMENT MISSING
		exit 1
	fi
	echo RUN HUB-LAYER-3
	cd /etc/openvpn/nlan
	/bin/sed -e s/nlan-subnet/$2/g < _nlan-hub-l3.conf > nlan-hub-l3.conf
	openvpn --config nlan-hub-l3.conf $3
	;;
client)
	if [ ! -e /etc/openvpn/nlan/nlan-client.crt ] ; then
		echo RUN "init hub" FIRST AND EXTRACT CLIENT TARBALL
		exit 1
	fi
	if [ "x$2" == "x" ] ; then
		echo CLIENT IP ARGUMENT MISSING
		exit 1
	fi
	echo RUN CLIENT
	cd /etc/openvpn/nlan
	echo $2 > nlan-client.ip
	openvpn --config nlan-client.conf $3
	;;

*)
	echo usage: $0 "{init-hub <hub-ip> | hub | client <client-nlan-ip> | hub-l3 <nlan-subnet>}"
	;;
esac
