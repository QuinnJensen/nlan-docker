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
	./easyrsa build-client-full nlan-client nopass
	./easyrsa build-server-full nlan-hub nopass
	cp -p pki/ca.crt ..
	cp -p pki/dh.pem ../dh2048.pem
	cp -p pki/private/nlan-client.key ..
	cp -p pki/private/nlan-hub.key ..
	cp -p pki/issued/nlan-client.crt ..
	cp -p pki/issued/nlan-hub.crt ..
	cd ..
	/bin/sed -e s/nlan-hub/$hub_ip/g < _nlan-client.conf > nlan-client.conf
	tar cvfz nlan-client.tar.gz -C .. nlan/nlan-client.{conf,key,crt,sh} nlan/ca.crt
	;;
hub)
	if [ ! -e /etc/openvpn/nlan/nlan-hub.crt ] ; then
		echo RUN "init hub" FIRST
		exit 1
	fi
	echo RUN HUB
	cd /etc/openvpn/nlan
	openvpn nlan-hub.conf
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
	openvpn nlan-client.conf
	;;

*)
	echo usage: $0 "{init-hub <hub-ip> | hub | client <client-nlan-ip>}"
	;;
esac
